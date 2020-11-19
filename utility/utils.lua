local Utils = {}
local factorioUtil = require("__core__/lualib/util")
Utils.DeepCopy = factorioUtil.table.deepcopy
Utils.TableMerge = factorioUtil.merge -- Takes an array of tables and returns a new table with copies of their contents

function Utils.Are2EntitiesTheSame(entity1, entity2)
    -- Uses unit number if both support it, otherwise has to compare a lot of attributes to try and work out if they are the same base entity.
    if not entity1.valid or not entity2.valid then
        return false
    end
    if entity1.unit_number ~= nil and entity2.unit_number ~= nil then
        if entity1.unit_number == entity2.unit_number then
            return true
        else
            return false
        end
    else
        if entity1.type == entity2.type and entity1.name == entity2.name and entity1.surface.index == entity2.surface.index and entity1.position.x == entity2.position.x and entity1.position.y == entity2.position.y and entity1.force.index == entity2.force.index and entity1.health == entity2.health then
            return true
        else
            return false
        end
    end
end

function Utils.ReturnAllObjectsInArea(surface, positionedBoundingBox, collisionBoxOnlyEntities, onlyForceAffected, onlyDestructable, onlyKillable, entitiesExcluded)
    -- Expand force affected to support range of opt in or opt out forces.
    local entitiesFound, filteredEntitiesFound = surface.find_entities(positionedBoundingBox), {}
    for k, entity in pairs(entitiesFound) do
        if entity.valid then
            local entityExcluded = false
            if entitiesExcluded ~= nil and #entitiesExcluded > 0 then
                for _, excludedEntity in pairs(entitiesExcluded) do
                    if Utils.Are2EntitiesTheSame(entity, excludedEntity) then
                        entityExcluded = true
                        break
                    end
                end
            end
            if not entityExcluded then
                if (onlyForceAffected == nil) or (entity.force == onlyForceAffected) then
                    if (not onlyDestructable) or (entity.destructible) then
                        if (not onlyKillable) or (entity.health ~= nil) then
                            if (not collisionBoxOnlyEntities) or (Utils.IsCollisionBoxPopulated(entity.prototype.collision_box)) then
                                table.insert(filteredEntitiesFound, entity)
                            end
                        end
                    end
                end
            end
        end
    end
    return filteredEntitiesFound
end

function Utils.KillAllKillableObjectsInArea(surface, positionedBoundingBox, killerEntity, collisionBoxOnlyEntities, onlyForceAffected, entitiesExcluded)
    for k, entity in pairs(Utils.ReturnAllObjectsInArea(surface, positionedBoundingBox, collisionBoxOnlyEntities, onlyForceAffected, true, true, entitiesExcluded)) do
        if killerEntity ~= nil then
            entity.die("neutral", killerEntity)
        else
            entity.die("neutral")
        end
    end
end

function Utils.KillAllObjectsInArea(surface, positionedBoundingBox, killerEntity, onlyForceAffected, entitiesExcluded)
    for k, entity in pairs(Utils.ReturnAllObjectsInArea(surface, positionedBoundingBox, false, onlyForceAffected, false, false, entitiesExcluded)) do
        if entity.destructible then
            if killerEntity ~= nil then
                entity.die("neutral", killerEntity)
            else
                entity.die("neutral")
            end
        else
            entity.destroy({dp_cliff_correction = true, raise_destroy = true})
        end
    end
end

function Utils.DestroyAllKillableObjectsInArea(surface, positionedBoundingBox, collisionBoxOnlyEntities, onlyForceAffected, entitiesExcluded)
    for k, entity in pairs(Utils.ReturnAllObjectsInArea(surface, positionedBoundingBox, collisionBoxOnlyEntities, onlyForceAffected, true, true, entitiesExcluded)) do
        entity.destroy({dp_cliff_correction = true, raise_destroy = true})
    end
end

function Utils.DestroyAllObjectsInArea(surface, positionedBoundingBox, onlyForceAffected, entitiesExcluded)
    for k, entity in pairs(Utils.ReturnAllObjectsInArea(surface, positionedBoundingBox, false, onlyForceAffected, false, false, entitiesExcluded)) do
        entity.destroy({dp_cliff_correction = true, raise_destroy = true})
    end
end

function Utils.IsTableValidPosition(thing)
    if thing.x ~= nil and thing.y ~= nil then
        if type(thing.x) == "number" and type(thing.y) == "number" then
            return true
        else
            return false
        end
    end
    if #thing ~= 2 then
        return false
    end
    if type(thing[1]) == "number" and type(thing[2]) == "number" then
        return true
    else
        return false
    end
end

function Utils.TableToProperPosition(thing)
    if not Utils.IsTableValidPosition(thing) then
        return nil
    elseif thing.x ~= nil and thing.y ~= nil then
        return {x = thing.x, y = thing.y}
    else
        return {x = thing[1], y = thing[2]}
    end
end

function Utils.ApplyBoundingBoxToPosition(centrePos, boundingBox, orientation)
    if orientation == nil or orientation == 0 or orientation == 1 then
        return {
            left_top = {
                x = centrePos.x + boundingBox.left_top.x,
                y = centrePos.y + boundingBox.left_top.y
            },
            right_bottom = {
                x = centrePos.x + boundingBox.right_bottom.x,
                y = centrePos.y + boundingBox.right_bottom.y
            }
        }
    elseif orientation == 0.25 or orientation == 0.5 or orientation == 0.75 then
        local rotatedPoint1 = Utils.RotatePositionAround0(orientation, boundingBox.left_top)
        local rotatedPoint2 = Utils.RotatePositionAround0(orientation, boundingBox.right_bottom)
        local rotatedBoundingBox = Utils.CalculateBoundingBoxFrom2Points(rotatedPoint1, rotatedPoint2)
        return {
            left_top = {
                x = centrePos.x + rotatedBoundingBox.left_top.x,
                y = centrePos.y + rotatedBoundingBox.left_top.y
            },
            right_bottom = {
                x = centrePos.x + rotatedBoundingBox.right_bottom.x,
                y = centrePos.y + rotatedBoundingBox.right_bottom.y
            }
        }
    else
        game.print("Error: Diagonal orientations not supported by Utils.ApplyBoundingBoxToPosition()")
    end
end

function Utils.RoundPosition(pos, numDecimalPlaces)
    return {x = Utils.RoundNumberToDecimalPlaces(pos.x, numDecimalPlaces), y = Utils.RoundNumberToDecimalPlaces(pos.y, numDecimalPlaces)}
end

function Utils.GetChunkPositionForTilePosition(pos)
    return {x = math.floor(pos.x / 32), y = math.floor(pos.y / 32)}
end

function Utils.GetLeftTopTilePositionForChunkPosition(chunkPos)
    return {x = chunkPos.x * 32, y = chunkPos.y * 32}
end

function Utils.RotatePositionAround0(orientation, position)
    local deg = orientation * 360
    local rad = math.rad(deg)
    local cosValue = math.cos(rad)
    local sinValue = math.sin(rad)
    local rotatedX = (position.x * cosValue) - (position.y * sinValue)
    local rotatedY = (position.x * sinValue) + (position.y * cosValue)
    return {x = rotatedX, y = rotatedY}
end

function Utils.CalculateBoundingBoxFrom2Points(point1, point2)
    local minX = nil
    local maxX = nil
    local minY = nil
    local maxY = nil
    if minX == nil or point1.x < minX then
        minX = point1.x
    end
    if maxX == nil or point1.x > maxX then
        maxX = point1.x
    end
    if minY == nil or point1.y < minY then
        minY = point1.y
    end
    if maxY == nil or point1.y > maxY then
        maxY = point1.y
    end
    if minX == nil or point2.x < minX then
        minX = point2.x
    end
    if maxX == nil or point2.x > maxX then
        maxX = point2.x
    end
    if minY == nil or point2.y < minY then
        minY = point2.y
    end
    if maxY == nil or point2.y > maxY then
        maxY = point2.y
    end
    return {left_top = {x = minX, y = minY}, right_bottom = {x = maxX, y = maxY}}
end

function Utils.ApplyOffsetToPosition(position, offset)
    position = Utils.DeepCopy(position)
    if offset == nil then
        return position
    end
    if offset.x ~= nil then
        position.x = position.x + offset.x
    end
    if offset.y ~= nil then
        position.y = position.y + offset.y
    end
    return position
end

function Utils.GrowBoundingBox(boundingBox, growthX, growthY)
    return {
        left_top = {
            x = boundingBox.left_top.x - growthX,
            y = boundingBox.left_top.y - growthY
        },
        right_bottom = {
            x = boundingBox.right_bottom.x + growthX,
            y = boundingBox.right_bottom.y + growthY
        }
    }
end

function Utils.IsCollisionBoxPopulated(collisionBox)
    if collisionBox == nil then
        return false
    end
    if collisionBox.left_top.x ~= 0 and collisionBox.left_top.y ~= 0 and collisionBox.right_bottom.x ~= 0 and collisionBox.right_bottom.y ~= 0 then
        return true
    else
        return false
    end
end

function Utils.LogisticEquation(index, height, steepness)
    return height / (1 + math.exp(steepness * (index - 0)))
end

function Utils.ExponentialDecayEquation(index, multiplier, scale)
    return multiplier * math.exp(-index * scale)
end

function Utils.RoundNumberToDecimalPlaces(num, numDecimalPlaces)
    local result
    if numDecimalPlaces ~= nil and numDecimalPlaces > 0 then
        local mult = 10 ^ numDecimalPlaces
        result = math.floor(num * mult + 0.5) / mult
    else
        result = math.floor(num + 0.5)
    end
    if result == "nan" then
        result = 0
    end
    return result
end

function Utils.LoopIntValueWithinRange(value, min, max)
    if value > max then
        return min - (max - value) - 1
    elseif value < min then
        return max + (value - min) + 1
    else
        return value
    end
end

function Utils.HandleFloatNumberAsChancedValue(value)
    local intValue = math.floor(value)
    local partialValue = value - intValue
    local chancedValue = intValue
    if partialValue ~= 0 then
        local rand = math.random()
        if rand >= partialValue then
            chancedValue = chancedValue + 1
        end
    end
    return chancedValue
end

function Utils.FuzzyCompareDoubles(num1, logic, num2)
    -- This doesn't guarentee correct on some of the edge cases, but is as close as possible assuming that 1/256 is the variance for the same number (Bilka, Dev on Discord)
    local numDif = num1 - num2
    local variance = 1 / 256
    if logic == "=" then
        if numDif < variance and numDif > -variance then
            return true
        else
            return false
        end
    elseif logic == "!=" then
        if numDif < variance and numDif > -variance then
            return false
        else
            return true
        end
    elseif logic == ">" then
        if numDif > variance then
            return true
        else
            return false
        end
    elseif logic == ">=" then
        if numDif > -variance then
            return true
        else
            return false
        end
    elseif logic == "<" then
        if numDif < -variance then
            return true
        else
            return false
        end
    elseif logic == "<=" then
        if numDif < variance then
            return true
        else
            return false
        end
    end
end

function Utils.IsTableEmpty(table)
    if table == nil or next(table) == nil then
        return true
    else
        return false
    end
end

function Utils.GetTableNonNilLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function Utils.GetFirstTableKey(table)
    return next(table)
end

function Utils.GetFirstTableValue(table)
    return table[next(table)]
end

function Utils.GetFirstTableKeyValue(table)
    return next(table), table[next(table)]
end

function Utils.GetMaxKey(table)
    local max_key = 0
    for k in pairs(table) do
        if k > max_key then
            max_key = k
        end
    end
    return max_key
end

function Utils.GetTableValueByIndexCount(table, indexCount)
    local count = 0
    for _, v in pairs(table) do
        count = count + 1
        if count == indexCount then
            return v
        end
    end
end

function Utils.CalculateBoundingBoxFromPositionAndRange(position, range)
    return {
        left_top = {
            x = position.x - range,
            y = position.y - range
        },
        right_bottom = {
            x = position.x + range,
            y = position.y + range
        }
    }
end

function Utils.CalculateTilesUnderPositionedBoundingBox(positionedBoundingBox)
    local tiles = {}
    for x = positionedBoundingBox.left_top.x, positionedBoundingBox.right_bottom.x do
        for y = positionedBoundingBox.left_top.y, positionedBoundingBox.right_bottom.y do
            table.insert(tiles, {x = math.floor(x), y = math.floor(y)})
        end
    end
    return tiles
end

function Utils.GetDistance(pos1, pos2)
    local dx = pos1.x - pos2.x
    local dy = pos1.y - pos2.y
    return math.sqrt(dx * dx + dy * dy)
end

function Utils.IsPositionInBoundingBox(position, boundingBox, safeTiling)
    -- safeTiling option means that the boundingbox can be tiled without risk of an entity on the border being in 2 result sets, i.e. for use on each chunk.
    if safeTiling == nil or not safeTiling then
        if position.x >= boundingBox.left_top.x and position.x <= boundingBox.right_bottom.x and position.y >= boundingBox.left_top.y and position.y <= boundingBox.right_bottom.y then
            return true
        else
            return false
        end
    else
        if position.x > boundingBox.left_top.x and position.x <= boundingBox.right_bottom.x and position.y > boundingBox.left_top.y and position.y <= boundingBox.right_bottom.y then
            return true
        else
            return false
        end
    end
end

function Utils.GetEntityReturnedToInventoryName(entity)
    if entity.prototype.mineable_properties ~= nil and entity.prototype.mineable_properties.products ~= nil and #entity.prototype.mineable_properties.products > 0 then
        return entity.prototype.mineable_properties.products[1].name
    else
        return entity.name
    end
end

function Utils.TableKeyToArray(aTable)
    local newArray = {}
    for key in pairs(aTable) do
        table.insert(newArray, key)
    end
    return newArray
end

function Utils.TableContentsToJSON(targetTable, name, singleLineOutput)
    -- targetTable is the only mandatory parameter. name if provided will appear as a "name:JSONData" output. singleLineOutput removes all lines and spacing from the output.
    singleLineOutput = singleLineOutput or false
    local tablesLogged = {}
    return Utils._TableContentsToJSON(targetTable, name, singleLineOutput, tablesLogged)
end
function Utils._TableContentsToJSON(targetTable, name, singleLineOutput, tablesLogged, indent, stopTraversing)
    local newLineCharacter = "\r\n"
    indent = indent or 1
    local indentstring = string.rep(" ", (indent * 4))
    if singleLineOutput then
        newLineCharacter = ""
        indentstring = ""
    end
    tablesLogged[targetTable] = "logged"
    local table_contents = ""
    if Utils.GetTableNonNilLength(targetTable) > 0 then
        for k, v in pairs(targetTable) do
            local key, value
            if type(k) == "string" or type(k) == "number" or type(k) == "boolean" then -- keys are always strings
                key = '"' .. tostring(k) .. '"'
            elseif type(k) == "nil" then
                key = '"nil"'
            elseif type(k) == "table" then
                if stopTraversing == true then
                    key = '"CIRCULAR LOOP TABLE"'
                else
                    local subStopTraversing = nil
                    if tablesLogged[k] ~= nil then
                        subStopTraversing = true
                    end
                    key = "{" .. newLineCharacter .. Utils._TableContentsToJSON(k, name, singleLineOutput, tablesLogged, indent + 1, subStopTraversing) .. newLineCharacter .. indentstring .. "}"
                end
            elseif type(k) == "function" then
                key = '"' .. tostring(k) .. '"'
            else
                key = '"unhandled type: ' .. type(k) .. '"'
            end
            if type(v) == "string" then
                value = '"' .. tostring(v) .. '"'
            elseif type(v) == "number" or type(v) == "boolean" then
                value = tostring(v)
            elseif type(v) == "nil" then
                value = '"nil"'
            elseif type(v) == "table" then
                if stopTraversing == true then
                    value = '"CIRCULAR LOOP TABLE"'
                else
                    local subStopTraversing = nil
                    if tablesLogged[v] ~= nil then
                        subStopTraversing = true
                    end
                    value = "{" .. newLineCharacter .. Utils._TableContentsToJSON(v, name, singleLineOutput, tablesLogged, indent + 1, subStopTraversing) .. newLineCharacter .. indentstring .. "}"
                end
            elseif type(v) == "function" then
                value = '"' .. tostring(v) .. '"'
            else
                value = '"unhandled type: ' .. type(v) .. '"'
            end
            if table_contents ~= "" then
                table_contents = table_contents .. "," .. newLineCharacter
            end
            table_contents = table_contents .. indentstring .. tostring(key) .. ":" .. tostring(value)
        end
    else
        table_contents = indentstring .. '"empty"'
    end
    if indent == 1 then
        local resultString = ""
        if name ~= nil then
            resultString = '"' .. name .. '":'
        end
        resultString = resultString .. "{" .. newLineCharacter .. table_contents .. newLineCharacter .. "}"
        return resultString
    else
        return table_contents
    end
end

function Utils.FormatPositionTableToString(positionTable)
    return positionTable.x .. "," .. positionTable.y
end

function Utils.GetTableKeyWithValue(theTable, value)
    for k, v in pairs(theTable) do
        if v == value then
            return k
        end
    end
    return nil
end

function Utils.GetTableKeyWithInnerKeyValue(theTable, key, value)
    for i, innerTable in pairs(theTable) do
        if innerTable[key] ~= nil and innerTable[key] == value then
            return i
        end
    end
    return nil
end

function Utils.GetRandomFloatInRange(lower, upper)
    return lower + math.random() * (upper - lower)
end

function Utils.WasCreativeModeInstantDeconstructionUsed(event)
    if event.instant_deconstruction ~= nil and event.instant_deconstruction == true then
        return true
    else
        return false
    end
end

function Utils.NormaliseChanceList(dataSet, chancePropertyName, skipFillingEmptyChance)
    -- The dataset is a table of entries. Each entry has various keys that are used in the calling scope and ignored by this funciton. It also has a key of the name passed in as the chancePropertyName parameter that defines the chance of this result.
    -- By default the dataSet's total chance (key with name chancePropertyName) is manipulated in to a 0-1 range. But if optional skipFillingEmptyChance is set to true then total chance below 1 will not be scaled up, so that nil results can be had in random selection.
    local totalChance = 0
    for _, v in pairs(dataSet) do
        totalChance = totalChance + v[chancePropertyName]
    end
    local multiplier = 1
    if not skipFillingEmptyChance or (skipFillingEmptyChance and totalChance > 1) then
        multiplier = 1 / totalChance
    end
    for _, v in pairs(dataSet) do
        v[chancePropertyName] = v[chancePropertyName] * multiplier
    end
    return dataSet
end

function Utils.GetRandomEntryFromNormalisedDataSet(dataSet, chancePropertyName)
    local random = math.random()
    local chanceRangeLow = 0
    local chanceRangeHigh
    for _, v in pairs(dataSet) do
        chanceRangeHigh = chanceRangeLow + v[chancePropertyName]
        if random >= chanceRangeLow and random <= chanceRangeHigh then
            return v
        end
        chanceRangeLow = chanceRangeHigh
    end
    return nil
end

function Utils.DisableSiloScript()
    -- OnLoad
    if remote.interfaces["silo_script"] == nil then
        return
    end
    local items = remote.call("silo_script", "get_tracked_items")
    for itemName in pairs(items) do
        remote.call("silo_script", "remove_tracked_item", itemName)
    end
end

function Utils.DisableWinOnRocket()
    -- OnInit
    if remote.interfaces["silo_script"] == nil then
        return
    end
    remote.call("silo_script", "set_no_victory", true)
end

function Utils.ClearSpawnRespawnItems()
    -- OnInit
    if remote.interfaces["freeplay"] == nil then
        return
    end
    remote.call("freeplay", "set_created_items", {})
    remote.call("freeplay", "set_respawn_items", {})
end

function Utils.SetStartingMapReveal(distance)
    -- OnInit
    if remote.interfaces["freeplay"] == nil then
        return
    end
    remote.call("freeplay", "set_chart_distance", distance)
end

function Utils.DisableIntroMessage()
    -- OnInit
    if remote.interfaces["freeplay"] == nil then
        return
    end
    remote.call("freeplay", "set_skip_intro", true)
end

function Utils.PadNumberToMinimumDigits(input, requiredLength)
    local shortBy = requiredLength - string.len(input)
    for i = 1, shortBy do
        input = "0" .. input
    end
    return input
end

function Utils.DisplayNumberPretty(number)
    if number == nil then
        return ""
    end
    local formatted = number
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if (k == 0) then
            break
        end
    end
    return formatted
end

function Utils.DisplayTimeOfTicks(inputTicks, displayLargestTimeUnit, displaySmallestTimeUnit)
    -- display time units: hour, minute, second
    if inputTicks == nil then
        return ""
    end
    local negativeSign = ""
    if inputTicks < 0 then
        negativeSign = "-"
        inputTicks = 0 - inputTicks
    end
    local hours = math.floor(inputTicks / 216000)
    local displayHours = Utils.PadNumberToMinimumDigits(hours, 2)
    inputTicks = inputTicks - (hours * 216000)
    local minutes = math.floor(inputTicks / 3600)
    local displayMinutes = Utils.PadNumberToMinimumDigits(minutes, 2)
    inputTicks = inputTicks - (minutes * 3600)
    local seconds = math.floor(inputTicks / 60)
    local displaySeconds = Utils.PadNumberToMinimumDigits(seconds, 2)

    if displayLargestTimeUnit == nil or displayLargestTimeUnit == "" or displayLargestTimeUnit == "auto" then
        if hours > 0 then
            displayLargestTimeUnit = "hour"
        elseif minutes > 0 then
            displayLargestTimeUnit = "minute"
        else
            displayLargestTimeUnit = "second"
        end
    end
    if not (displayLargestTimeUnit == "hour" or displayLargestTimeUnit == "minute" or displayLargestTimeUnit == "second") then
        error("unrecognised displayLargestTimeUnit argument in Utils.MakeLocalisedStringDisplayOfTime")
    end
    if displaySmallestTimeUnit == nil or displaySmallestTimeUnit == "" or displaySmallestTimeUnit == "auto" then
        displaySmallestTimeUnit = "second"
    end
    if not (displaySmallestTimeUnit == "hour" or displaySmallestTimeUnit == "minute" or displaySmallestTimeUnit == "second") then
        error("unrecognised displaySmallestTimeUnit argument in Utils.MakeLocalisedStringDisplayOfTime")
    end

    local timeUnitIndex = {second = 1, minute = 2, hour = 3}
    local displayLargestTimeUnitIndex = timeUnitIndex[displayLargestTimeUnit]
    local displaySmallestTimeUnitIndex = timeUnitIndex[displaySmallestTimeUnit]
    local timeUnitRange = displayLargestTimeUnitIndex - displaySmallestTimeUnitIndex

    if timeUnitRange == 2 then
        return (negativeSign .. displayHours .. ":" .. displayMinutes .. ":" .. displaySeconds)
    elseif timeUnitRange == 1 then
        if displayLargestTimeUnit == "hour" then
            return (negativeSign .. displayHours .. ":" .. displayMinutes)
        else
            return (negativeSign .. displayMinutes .. ":" .. displaySeconds)
        end
    elseif timeUnitRange == 0 then
        if displayLargestTimeUnit == "hour" then
            return (negativeSign .. displayHours)
        elseif displayLargestTimeUnit == "minute" then
            return (negativeSign .. displayMinutes)
        else
            return (negativeSign .. displaySeconds)
        end
    else
        error("time unit range is negative in Utils.MakeLocalisedStringDisplayOfTime")
    end
end

function Utils._CreatePlacementTestEntityPrototype(entityToClone, newEntityName, subgroup, collisionMask)
    -- Doesn't handle mipmaps at all presently. Also ignores any of the extra data in an icons table of "Types/IconData". Think this should just duplicate the target icons table entry.
    local clonedIcon = entityToClone.icon
    local clonedIconSize = entityToClone.icon_size
    if clonedIcon == nil then
        clonedIcon = entityToClone.icons[1].icon
        clonedIconSize = entityToClone.icons[1].icon_size
    end
    return {
        type = "simple-entity",
        name = newEntityName,
        subgroup = subgroup,
        order = "zzz",
        icons = {
            {
                icon = clonedIcon,
                icon_size = clonedIconSize
            },
            {
                icon = "__core__/graphics/cancel.png",
                icon_size = 64,
                scale = (clonedIconSize / 64) * 0.75
            }
        },
        flags = entityToClone.flags,
        selection_box = entityToClone.selection_box,
        collision_box = entityToClone.collision_box,
        collision_mask = collisionMask,
        picture = {
            filename = "__core__/graphics/cancel.png",
            height = 64,
            width = 64
        }
    }
end

function Utils.CreateLandPlacementTestEntityPrototype(entityToClone, newEntityName, subgroup)
    subgroup = subgroup or "other"
    return Utils._CreatePlacementTestEntityPrototype(entityToClone, newEntityName, subgroup, {"water-tile", "colliding-with-tiles-only"})
end

function Utils.CreateWaterPlacementTestEntityPrototype(entityToClone, newEntityName, subgroup)
    subgroup = subgroup or "other"
    return Utils._CreatePlacementTestEntityPrototype(entityToClone, newEntityName, subgroup, {"ground-tile", "colliding-with-tiles-only"})
end

--[[
    NOT NEEDED AS surface.find_non_colliding_position() STARTS IN CENTER AND WORKS OUT - MAYBE DIDN'T IN THE PAST
    function Utils.GetValidPositionForEntityNearPosition(entityName, surface, centerPos, radius, maxAttempts, searchIncrement, allowNonTileCenter)
    local pos
    local attempts = 1
    searchIncrement = searchIncrement or 1
    allowNonTileCenter = allowNonTileCenter or false
    while pos == nil do
        local searchRadius = radius * attempts
        pos = surface.find_non_colliding_position(entityName, centerPos, searchRadius, searchIncrement, not allowNonTileCenter)
        if pos ~= nil then
            return pos
        end
        attempts = attempts + 1
        if attempts > maxAttempts then
            return nil
        end
    end
    return nil
end]]
function Utils.ToBoolean(text)
    if text == nil then
        return nil
    end
    if type(text) == "boolean" then
        return text
    end
    text = string.lower(text)
    if text == "true" then
        return true
    elseif text == "false" then
        return false
    end
    return nil
end

function Utils.RandomLocationInRadius(centrePos, maxRadius, minRadius)
    local angle = math.random(0, 360)
    minRadius = minRadius or 0
    local radiusMultiplier = maxRadius - minRadius
    local distance = minRadius + (math.random() * radiusMultiplier)
    return Utils.GetPositionForAngledDistance(centrePos, distance, angle)
end

function Utils.GetPositionForAngledDistance(startingPos, distance, angle)
    if angle < 0 then
        angle = 360 + angle
    end
    local angleRad = math.rad(angle)
    local newPos = {
        x = (distance * math.sin(angleRad)) + startingPos.x,
        y = (distance * -math.cos(angleRad)) + startingPos.y
    }
    return newPos
end

function Utils.FindWhereLineCrossesCircle(radius, slope, yIntercept)
    local centerPos = {x = 0, y = 0}
    local A = 1 + slope * slope
    local B = -2 * centerPos.x + 2 * slope * yIntercept - 2 * centerPos.y * slope
    local C = centerPos.x * centerPos.x + yIntercept * yIntercept + centerPos.y * centerPos.y - 2 * centerPos.y * yIntercept - radius * radius
    local delta = B * B - 4 * A * C

    if delta < 0 then
        return nil, nil
    else
        local x1 = (-B + math.sqrt(delta)) / (2 * A)

        local x2 = (-B - math.sqrt(delta)) / (2 * A)

        local y1 = slope * x1 + yIntercept

        local y2 = slope * x2 + yIntercept

        local pos1 = {x = x1, y = y1}
        local pos2 = {x = x2, y = y2}
        if pos1 == pos2 then
            return pos1, nil
        else
            return pos1, pos2
        end
    end
end

function Utils.IsPositionWithinCircled(circleCenter, radius, position)
    local deltaX = math.abs(position.x - circleCenter.x)
    local deltaY = math.abs(position.y - circleCenter.y)
    if deltaX + deltaY <= radius then
        return true
    elseif deltaX > radius then
        return false
    elseif deltaY > radius then
        return false
    elseif deltaX ^ 2 + deltaY ^ 2 <= radius ^ 2 then
        return true
    else
        return false
    end
end

Utils.GetValueAndUnitFromString = function(text)
    return string.match(text, "%d+%.?%d*"), string.match(text, "%a+")
end

Utils.TryMoveInventoriesLuaItemStacks = function(sourceInventory, targetInventory, dropUnmovedOnGround, ratioToMove)
    -- Moves the full Lua Item Stacks so handles items with data and other complicated items. Updates the passed in inventory object.
    -- Returns true/false if all items were moved successfully.
    local sourceOwner, itemAllMoved = nil, true
    if dropUnmovedOnGround == nil then
        dropUnmovedOnGround = false
    end
    if ratioToMove == nil then
        ratioToMove = 1
    end
    if sourceInventory == nil or sourceInventory.is_empty() then
        return itemAllMoved
    end
    for index = 1, #sourceInventory do
        local itemStack = sourceInventory[index]
        if itemStack.valid_for_read then
            local toMoveCount = math.ceil(itemStack.count * ratioToMove)
            local itemStackToMove = Utils.DeepCopy(itemStack)
            itemStackToMove.count = toMoveCount
            local movedCount = targetInventory.insert(itemStackToMove)
            local remaining = itemStack.count - movedCount
            if movedCount > 0 then
                itemStack.count = remaining
            end
            if remaining > 0 then
                itemAllMoved = false
                if dropUnmovedOnGround then
                    sourceOwner = sourceOwner or targetInventory.entity_owner or targetInventory.player_owner
                    sourceOwner.surface.spill_item_stack(sourceOwner.position, {name = itemStack.name, count = remaining}, true, sourceOwner.force, false)
                end
            end
        end
    end

    return itemAllMoved
end

Utils.TryTakeGridsItems = function(sourceGrid, targetInventory, dropUnmovedOnGround)
    -- Can only move the item name and count via API, Facotrio doesn't support putting equipment objects in an inventory. Updates the passed in grid object.
    -- Returns true/false if all items were moved successfully.
    if sourceGrid == nil then
        return
    end
    local sourceOwner, itemAllMoved = nil, true
    if dropUnmovedOnGround == nil then
        dropUnmovedOnGround = false
    end
    for _, equipment in pairs(sourceGrid.equipment) do
        local moved = targetInventory.insert({name = equipment.name, count = 1})
        if moved > 0 then
            sourceGrid.take({equipment = equipment})
        end
        if moved == 0 then
            itemAllMoved = false
            if dropUnmovedOnGround then
                sourceOwner = sourceOwner or targetInventory.entity_owner or targetInventory.player_owner
                sourceOwner.surface.spill_item_stack(sourceOwner.position, {name = equipment.name, count = 1}, true, sourceOwner.force, false)
            end
        end
    end
    return itemAllMoved
end

Utils.TryInsertInventoryContents = function(contents, targetInventory, dropUnmovedOnGround, ratioToMove)
    -- Just takes a list of item names and counts that you get from the inventory.get_contents(). Updates the passed in contents object.
    -- Returns true/false if all items were moved successfully.
    if Utils.IsTableEmpty(contents) then
        return
    end
    local sourceOwner, itemAllMoved = nil, true
    if dropUnmovedOnGround == nil then
        dropUnmovedOnGround = false
    end
    if ratioToMove == nil then
        ratioToMove = 1
    end
    for name, count in pairs(contents) do
        local toMove = math.ceil(count * ratioToMove)
        local moved = targetInventory.insert({name = name, count = toMove})
        local remaining = count - moved
        if moved > 0 then
            contents[name] = remaining
        end
        if remaining > 0 then
            itemAllMoved = false
            if dropUnmovedOnGround then
                sourceOwner = sourceOwner or targetInventory.entity_owner or targetInventory.player_owner
                sourceOwner.surface.spill_item_stack(sourceOwner.position, {name = name, count = remaining}, true, sourceOwner.force, false)
            end
        end
    end
    return itemAllMoved
end

Utils.TryInsertSimpleItems = function(contents, targetInventory, dropUnmovedOnGround, ratioToMove)
    -- Takes a table of SimpleItemStack and inserts them in to an inventory. Updates the passed in contents object.
    -- Returns true/false if all items were moved successfully.
    if contents == nil or #contents == 0 then
        return
    end
    local sourceOwner, itemAllMoved = nil, true
    if dropUnmovedOnGround == nil then
        dropUnmovedOnGround = false
    end
    if ratioToMove == nil then
        ratioToMove = 1
    end
    for index, simpleItemStack in pairs(contents) do
        local toMove = math.ceil(simpleItemStack.count * ratioToMove)
        local moved = targetInventory.insert({name = simpleItemStack.name, count = toMove, health = simpleItemStack.health, durability = simpleItemStack.durablilty, ammo = simpleItemStack.ammo})
        local remaining = simpleItemStack.count - moved
        if moved > 0 then
            contents[index].count = remaining
        end
        if remaining > 0 then
            itemAllMoved = false
            if dropUnmovedOnGround then
                sourceOwner = sourceOwner or targetInventory.entity_owner or targetInventory.player_owner
                sourceOwner.surface.spill_item_stack(sourceOwner.position, {name = simpleItemStack.name, count = remaining}, true, sourceOwner.force, false)
            end
        end
    end
    return itemAllMoved
end

Utils.GetBuilderInventory = function(builder)
    if builder.is_player() then
        return builder.get_main_inventory()
    elseif builder.type ~= nil and builder.type == "construction-robot" then
        return builder.get_inventory(defines.inventory.robot_cargo)
    else
        return builder
    end
end

Utils.EmptyRotatedSprite = function()
    return {
        direction_count = 1,
        filename = "__core__/graphics/empty.png",
        width = 1,
        height = 1
    }
end

Utils.TrackBestFuelCount = function(trackingTable, itemName, itemCount)
    --[[
        The "trackingTable" argument should be an empty table created in the calling function. It should be passed in to each calling of this function to track the best fuel.
        The function returns true when the fuel is a new best and false when its not. Returns nil if the item isn't a fuel type.
        This function will set trackingTable to have the below entry. Query these keys in calling function:
            trackingTable {
                fuelName = STRING,
                fuelCount = INT,
                fuelValue = INT,
            }
    --]]
    local itemPrototype = game.item_prototypes[itemName]
    local fuelValue = itemPrototype.fuel_value
    if fuelValue == nil then
        return nil
    end
    if trackingTable.fuelValue == nil or fuelValue > trackingTable.fuelValue then
        trackingTable.fuelName = itemName
        trackingTable.fuelCount = itemCount
        trackingTable.fuelValue = fuelValue
        return true
    end
    if trackingTable.fuelName == itemName and itemCount > trackingTable.fuelCount then
        trackingTable.fuelCount = itemCount
        return true
    end
    return false
end

Utils.MakeRecipePrototype = function(recipeName, resultItemName, enabled, ingredientLists, energyLists)
    --[[
        Takes tables of the various recipe types (normal, expensive and ingredients) and makes the required recipe prototypes from them. Only makes the version if the ingredientsList includes the type. So supplying just energyLists types doesn't make new versions.
        ingredientLists is a table with optional tables for "normal", "expensive" and "ingredients" tables within them. Often generatered by Utils.GetRecipeIngredientsAddedTogeather().
        energyLists is a table with optional keys for "normal", "expensive" and "ingredients". The value of the keys is the energy_required value.
    ]]
    local recipePrototype = {
        type = "recipe",
        name = recipeName
    }
    if ingredientLists.ingredients ~= nil then
        recipePrototype.energy_required = energyLists.ingredients
        recipePrototype.enabled = enabled
        recipePrototype.result = resultItemName
        recipePrototype.ingredients = ingredientLists.ingredients
    end
    if ingredientLists.normal ~= nil then
        recipePrototype.normal = {
            energy_required = energyLists.normal or energyLists.ingredients,
            enabled = enabled,
            result = resultItemName,
            ingredients = ingredientLists.normal
        }
    end
    if ingredientLists.expensive ~= nil then
        recipePrototype.expensive = {
            energy_required = energyLists.expensive or energyLists.ingredients,
            enabled = enabled,
            result = resultItemName,
            ingredients = ingredientLists.expensive
        }
    end
    return recipePrototype
end

Utils.GetRecipeIngredientsAddedTogeather = function(recipeIngredientHandlingTables)
    --[[
        Is for handling a mix of recipes and ingredient list. Supports recipe ingredients, normal and expensive.
        Returns the widest range of types fed in as a table of result tables (nil for non required returns): {ingredients, normal, expensive}
        Takes a table (list) of entries. Each entry is a table (list) of recipe/ingredients, handling type and ratioMultiplier (optional), i.e. {{ingredients1, "add"}, {recipe1, "add", 0.5}, {ingredients2, "highest", 2}}
        handling types:
            - add: adds the ingredients from a list to the total
            - subtract: removes the ingredients in this list from the total
            - highest: just takes the highest counts of each ingredients across the 2 lists.
        ratioMultiplier item counts for recipes are rounded up. Defaults to ration of 1 if not provided.
    ]]
    local ingredientsTable, ingredientTypes = {}, {}
    for _, recipeIngredientHandlingTable in pairs(recipeIngredientHandlingTables) do
        if recipeIngredientHandlingTable[1].normal ~= nil then
            ingredientTypes.normal = true
        end
        if recipeIngredientHandlingTable[1].expensive ~= nil then
            ingredientTypes.expensive = true
        end
    end
    if Utils.IsTableEmpty(ingredientTypes) then
        ingredientTypes.ingredients = true
    end

    for ingredientType in pairs(ingredientTypes) do
        local ingredientsList = {}
        for _, recipeIngredientHandlingTable in pairs(recipeIngredientHandlingTables) do
            local ingredients  --try to find the correct ingredients for our desired type, if not found just try all of them to find one to use. Assume its a simple ingredient list last.
            if recipeIngredientHandlingTable[1][ingredientType] ~= nil then
                ingredients = recipeIngredientHandlingTable[1][ingredientType].ingredients or recipeIngredientHandlingTable[1][ingredientType]
            elseif recipeIngredientHandlingTable[1]["ingredients"] ~= nil then
                ingredients = recipeIngredientHandlingTable[1]["ingredients"]
            elseif recipeIngredientHandlingTable[1]["normal"] ~= nil then
                ingredients = recipeIngredientHandlingTable[1]["normal"].ingredients
            elseif recipeIngredientHandlingTable[1]["expensive"] ~= nil then
                ingredients = recipeIngredientHandlingTable[1]["expensive"].ingredients
            else
                ingredients = recipeIngredientHandlingTable[1]
            end
            local handling, ratioMultiplier = recipeIngredientHandlingTable[2], recipeIngredientHandlingTable[3]
            if ratioMultiplier == nil then
                ratioMultiplier = 1
            end
            for _, details in pairs(ingredients) do
                local name, count = details[1] or details.name, math.ceil((details[2] or details.amount) * ratioMultiplier)
                if handling == "add" then
                    ingredientsList[name] = (ingredientsList[name] or 0) + count
                elseif handling == "subtract" then
                    if ingredientsList[name] ~= nil then
                        ingredientsList[name] = ingredientsList[name] - count
                    end
                elseif handling == "highest" then
                    if count > (ingredientsList[name] or 0) then
                        ingredientsList[name] = count
                    end
                end
            end
        end
        ingredientsTable[ingredientType] = {}
        for name, count in pairs(ingredientsList) do
            if ingredientsList[name] > 0 then
                table.insert(ingredientsTable[ingredientType], {name, count})
            end
        end
    end
    return ingredientsTable
end

Utils.GetRecipeAttribute = function(recipe, attributeName, recipeCostType, defaultValue)
    --[[
        Returns the attributeName for the recipeCostType if available, otherwise the inline ingredients version.
        recipeType defaults to the no cost type if not supplied. Values are: "ingredients", "normal" and "expensive".
    --]]
    recipeCostType = recipeCostType or "ingredients"
    if recipeCostType == "ingredients" and recipe[attributeName] ~= nil then
        return recipe[attributeName]
    elseif recipe[recipeCostType] ~= nil and recipe[recipeCostType][attributeName] ~= nil then
        return recipe[recipeCostType][attributeName]
    end

    if recipe[attributeName] ~= nil then
        return recipe[attributeName]
    elseif recipe["normal"] ~= nil and recipe["normal"][attributeName] ~= nil then
        return recipe["normal"][attributeName]
    elseif recipe["expensive"] ~= nil and recipe["expensive"][attributeName] ~= nil then
        return recipe["expensive"][attributeName]
    end

    return defaultValue -- may well be nil
end

Utils.DoesRecipeResultsIncludeItemName = function(recipePrototype, itemName)
    for _, recipeBase in pairs({recipePrototype, recipePrototype.normal, recipePrototype.expensive}) do
        if recipeBase ~= nil then
            if recipeBase.result ~= nil and recipeBase.result == itemName then
                return true
            elseif recipeBase.results ~= nil and Utils.GetTableKeyWithInnerKeyValue(recipeBase.results, "name", itemName) ~= nil then
                return true
            end
        end
    end
    return false
end

Utils.RemoveEntitiesRecipesFromTechnologies = function(entityPrototype, recipes, technolgies)
    --[[
        From the provided technology list remove all provided recipes from being unlocked that create an item that can place a given entity prototype.
        Returns a table of the technologies affected or a blank table if no technologies are affected.
    ]]
    local technologiesChanged = {}
    local placedByItemName
    if entityPrototype.minable ~= nil and entityPrototype.minable.result ~= nil then
        placedByItemName = entityPrototype.minable.result
    else
        return technologiesChanged
    end
    for _, recipePrototype in pairs(recipes) do
        if Utils.DoesRecipeResultsIncludeItemName(recipePrototype, placedByItemName) then
            recipePrototype.enabled = false
            for _, technologyPrototype in pairs(technolgies) do
                if technologyPrototype.effects ~= nil then
                    for effectIndex, effect in pairs(technologyPrototype.effects) do
                        if effect.type == "unlock-recipe" and effect.recipe ~= nil and effect.recipe == recipePrototype.name then
                            table.remove(technologyPrototype.effects, effectIndex)
                            table.insert(technologiesChanged, technologyPrototype)
                        end
                    end
                end
            end
        end
    end
    return technologiesChanged
end

Utils.SplitStringOnCharacters = function(text, splitCharacters, returnAskey)
    local list = {}
    local results = text:gmatch("[^" .. splitCharacters .. "]*")
    for phrase in results do
        phrase = Utils.StringTrim(phrase)
        if phrase ~= nil and phrase ~= "" then
            if returnAskey ~= nil and returnAskey == true then
                list[phrase] = true
            else
                table.insert(list, phrase)
            end
        end
    end
    return list
end

Utils.StringTrim = function(text)
    -- trim6 from http://lua-users.org/wiki/StringTrim
    return string.match(text, "^()%s*$") and "" or string.match(text, "^%s*(.*%S)")
end

return Utils
