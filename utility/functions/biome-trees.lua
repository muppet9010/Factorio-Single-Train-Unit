--[[
    Used to get tile (biome) approperiate trees, rather than just select any old tree. Means they will fit in to the map better, although vanilla forest types don't always fully match the biome they are in.
    Will only nicely handle vanilla tiles and trees, modded tiles will get a random tree if they are a land-ish type tile.
    Require the file and call the desired functions when needed (non _ functions t top of file). No pre-setup required.
]]
local Utils = require("utility/utils")
local Logging = require("utility/logging")

local BiomeTrees = {}
local logNonPositives = false
local logPositives = false
local logData = false

BiomeTrees.GetBiomeTreeName = function(surface, position)
    -- Returns the tree name or nil if tile isn't land type
    BiomeTrees._ObtainRequiredData()
    local tile = surface.get_tile(position)
    local tileData = global.UTILITYBIOMETREES.tileData[tile.name]
    if tileData == nil then
        local tileName = tile.hidden_tile
        tileData = global.UTILITYBIOMETREES.tileData[tileName]
        if tileData == nil then
            if logNonPositives then
                Logging.LogPrint("Failed to get tile data for ''" .. tostring(tile.name) .. "'' and hidden tile '" .. tostring(tileName) .. "'")
            end
            return BiomeTrees._GetTruelyRandomTreeForTileCollision(tile)
        end
    end
    if tileData.type == "water" or tileData.type == "no-trees" then
        return nil
    end

    local rangeInt = math.random(1, #tileData.tempRanges)
    local tempRange = tileData.tempRanges[rangeInt]
    local moistureRange = tileData.moistureRanges[rangeInt]
    local tempScaleMultiplyer = Utils.GetRandomFloatInRange(tempRange[1], tempRange[2])
    local tileTemp = math.max(5, (tempScaleMultiplyer * 35))
    local tileMoisture = Utils.GetRandomFloatInRange(moistureRange[1], moistureRange[2])

    local suitableTrees = {}
    local currentChance = 0
    -- Make sure we find a tree of some type. Start as accurate as possible and then beocme less precise.
    for accuracy = 1, 1.5, 0.1 do
        for _, tree in pairs(global.UTILITYBIOMETREES.treeData) do
            if tileTemp >= tree.tempRange[1] / accuracy and tileTemp <= tree.tempRange[2] * accuracy and tileMoisture >= tree.moistureRange[1] / accuracy and tileMoisture <= tree.moistureRange[2] * accuracy then
                local treeEntry = {
                    chanceStart = currentChance,
                    chanceEnd = currentChance + tree.probability,
                    tree = tree
                }
                table.insert(suitableTrees, treeEntry)
                currentChance = treeEntry.chanceEnd
            end
        end
        if #suitableTrees > 0 then
            if logPositives then
                Logging.LogPrint(#suitableTrees .. " found on accuracy: " .. accuracy)
            end
            break
        end
    end
    if #suitableTrees == 0 then
        if logNonPositives then
            Logging.LogPrint("No tree found for conditions: tile: " .. tileData.name .. "   temp: " .. tileTemp .. "    moisture: " .. tileMoisture)
        end
        return BiomeTrees._GetTruelyRandomTreeForTileCollision(tile)
    end
    if logPositives then
        Logging.LogPrint("trees found for conditions: tile: " .. tileData.name .. "   temp: " .. tileTemp .. "    moisture: " .. tileMoisture)
    end

    local highestChance, treeName, treeFound = suitableTrees[#suitableTrees].chanceEnd, nil, false
    local chanceValue = math.random() * highestChance
    for _, treeEntry in pairs(suitableTrees) do
        if chanceValue >= treeEntry.chanceStart and chanceValue <= treeEntry.chanceEnd then
            treeName = treeEntry.tree.name
            treeFound = true
            break
        end
    end
    if not treeFound then
        return nil
    end

    -- Check the tree type still exists, if not re-generate data and run process again. There's no startup event requried with this method.
    if game.entity_prototypes[treeName] == nil then
        BiomeTrees._ObtainRequiredData(true)
        return BiomeTrees.GetBiomeTreeName(surface, position)
    else
        return treeName
    end
end

BiomeTrees.AddBiomeTreeNearPosition = function(surface, position, distance)
    -- Returns the tree entity if one found and created or nil
    BiomeTrees._ObtainRequiredData()
    local treeType = BiomeTrees.GetBiomeTreeName(surface, position)
    if treeType == nil then
        if logNonPositives then
            Logging.LogPrint("no tree was found")
        end
        return nil
    end
    local newPosition = surface.find_non_colliding_position(treeType, position, distance, 0.2)
    if newPosition == nil then
        if logNonPositives then
            Logging.LogPrint("No position for new tree found")
        end
        return nil
    end
    local newTree = surface.create_entity {name = treeType, position = newPosition, force = "neutral", raise_built = true}
    if newTree == nil then
        Logging.LogPrint("Failed to create tree at found position")
        return nil
    end
    if logPositives then
        Logging.LogPrint("tree added successfully, type: " .. treeType .. "    position: " .. newPosition.x .. ", " .. newPosition.y)
    end
    return newTree
end

BiomeTrees._GetTruelyRandomTreeForTileCollision = function(tile)
    if tile.collides_with("player-layer") then
        -- Is a non-land tile
        return nil
    else
        return global.UTILITYBIOMETREES.randomTrees[math.random(#global.UTILITYBIOMETREES.randomTrees)]
    end
end

BiomeTrees._ObtainRequiredData = function(forceReload)
    if forceReload then
        global.UTILITYBIOMETREES = nil
    end
    global.UTILITYBIOMETREES = global.UTILITYBIOMETREES or {}
    global.UTILITYBIOMETREES.tileData = global.UTILITYBIOMETREES.tileData or BiomeTrees._GetTileData()
    global.UTILITYBIOMETREES.treeData = global.UTILITYBIOMETREES.treeData or BiomeTrees._GetTreeData()
    global.UTILITYBIOMETREES.randomTrees = global.UTILITYBIOMETREES.randomTrees or BiomeTrees._GetRandomTrees()

    if logData then
        Logging.LogPrint(serpent.block(global.UTILITYBIOMETREES.treeData))
        Logging.LogPrint(serpent.block(global.UTILITYBIOMETREES.tileData))
    end
end

BiomeTrees._GetTreeData = function()
    local treeData = {}
    for _, prototype in pairs(game.get_filtered_entity_prototypes({{filter = "type", type = "tree"}, {mode = "and", filter = "autoplace"}})) do
        Logging.LogPrint(prototype.name, logData)
        local autoplace = nil
        for _, peak in pairs(prototype.autoplace_specification.peaks) do
            if peak.temperature_optimal ~= nil then
                autoplace = peak
            end
        end
        if autoplace ~= nil then
            treeData[prototype.name] = {
                name = prototype.name,
                tempRange = {
                    autoplace.temperature_optimal - (autoplace.temperature_range),
                    autoplace.temperature_optimal + (autoplace.temperature_range)
                },
                moistureRange = {
                    autoplace.water_optimal - (autoplace.water_range),
                    autoplace.water_optimal + (autoplace.water_range)
                },
                probability = prototype.autoplace_specification.max_probability
            }
        end
    end
    return treeData
end

BiomeTrees._GetRandomTrees = function()
    local randomTrees = {}
    for treeName in pairs(game.get_filtered_entity_prototypes({{filter = "type", type = "tree"}})) do
        table.insert(randomTrees, treeName)
    end
    return randomTrees
end

BiomeTrees._GetTileData = function()
    local tileDetails = {}
    local function AddTileDetails(tileName, type, range1, range2)
        local tempRanges = {}
        local moistureRanges = {}
        if range1 ~= nil then
            table.insert(tempRanges, {range1[1][1], range1[2][1]})
            table.insert(moistureRanges, {range1[1][2], range1[2][2]})
        end
        if range2 ~= nil then
            table.insert(tempRanges, {range2[1][1], range2[2][1]})
            table.insert(moistureRanges, {range2[1][2], range2[2][2]})
        end
        tileDetails[tileName] = {name = tileName, type = type, tempRanges = tempRanges, moistureRanges = moistureRanges}
    end

    -- Vanilla - 1.0.0
    AddTileDetails("grass-1", "grass", {{0, 0.7}, {1, 1}})
    AddTileDetails("grass-2", "grass", {{0.45, 0.45}, {1, 0.8}})
    AddTileDetails("grass-3", "grass", {{0, 0.6}, {0.65, 0.9}})
    AddTileDetails("grass-4", "grass", {{0, 0.5}, {0.55, 0.7}})
    AddTileDetails("dry-dirt", "dirt", {{0.45, 0}, {0.55, 0.35}})
    AddTileDetails("dirt-1", "dirt", {{0, 0.25}, {0.45, 0.3}}, {{0.4, 0}, {0.45, 0.25}})
    AddTileDetails("dirt-2", "dirt", {{0, 0.3}, {0.45, 0.35}})
    AddTileDetails("dirt-3", "dirt", {{0, 0.35}, {0.55, 0.4}})
    AddTileDetails("dirt-4", "dirt", {{0.55, 0}, {0.6, 0.35}}, {{0.6, 0.3}, {1, 0.35}})
    AddTileDetails("dirt-5", "dirt", {{0, 0.4}, {0.55, 0.45}})
    AddTileDetails("dirt-6", "dirt", {{0, 0.45}, {0.55, 0.5}})
    AddTileDetails("dirt-7", "dirt", {{0, 0.5}, {0.55, 0.55}})
    AddTileDetails("sand-1", "sand", {{0, 0}, {0.25, 0.15}})
    AddTileDetails("sand-2", "sand", {{0, 0.15}, {0.3, 0.2}}, {{0.25, 0}, {0.3, 0.15}})
    AddTileDetails("sand-3", "sand", {{0, 0.2}, {0.4, 0.25}}, {{0.3, 0}, {0.4, 0.2}})
    AddTileDetails("red-desert-0", "desert", {{0.55, 0.35}, {1, 0.5}})
    AddTileDetails("red-desert-1", "desert", {{0.6, 0}, {0.7, 0.3}}, {{0.7, 0.25}, {1, 0.3}})
    AddTileDetails("red-desert-2", "desert", {{0.7, 0}, {0.8, 0.25}}, {{0.8, 0.2}, {1, 0.25}})
    AddTileDetails("red-desert-3", "desert", {{0.8, 0}, {1, 0.2}})
    AddTileDetails("water", "water")
    AddTileDetails("deepwater", "water")
    AddTileDetails("water-green", "water")
    AddTileDetails("deepwater-green", "water")
    AddTileDetails("water-shallow", "water")
    AddTileDetails("water-mud", "water")
    AddTileDetails("out-of-map", "no-trees")
    AddTileDetails("landfill", "desert", {{0, 0}, {0.25, 0.15}}) --same as sand-1
    AddTileDetails("nuclear-ground", "desert", {{0, 0}, {0.25, 0.15}}) --same as sand-1

    return tileDetails
end

return BiomeTrees
