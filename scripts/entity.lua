local Entity = {}
local Utils = require("utility/utils")
local Logging = require("utility/logging")
local StaticData = require("static-data")
local Events = require("utility/events")

local debug_placementAttemptCircles = false -- clear all on map via: /c rendering.clear("single_train_unit")
local debug_writeAllWarnings = false

local LoopDirectionValue = function(value)
    return Utils.LoopIntValueWithinRange(value, 0, 7)
end

Entity.CreateGlobals = function()
    global.entity = global.entity or {}
    global.entity.singleTrainUnits = global.entity.singleTrainUnits or {}
    --[[
    global.entity.singleTrainUnits[singleTrainUnitId] = {
        id = singleTrainUnitId,
        wagons = {
            forwardLoco = ENTITY, middleCargo = ENTITY, rearLoco = ENTITY
        },
        wagonIds = {}
        type = STATICDATA WAGON TYPE
    }
    --]]
    global.entity.wagonIdToSingleTrainUnit = global.entity.wagonIdToSingleTrainUnit or {} -- WagonId to global.entity.singleTrainUnits entry
    global.entity.damageSourcesTick = global.entity.damageSourcesTick or 0
    global.entity.damageSourcesThisTick = global.entity.damageSourcesThisTick or {}

    --Always reset these as we re-populate them as part of OnStartup()
    global.entity.muWagonVariants = {}
    global.entity.muWagonNamesFilter = {}
    global.entity.muWagonPlacementNameFilter = {}
    global.entity.muWagonNamesAndPlacementNameFilter = {}
end

Entity.OnLoad = function()
    if global.entity.muWagonNamesFilter == nil or Utils.IsTableEmpty(global.entity.muWagonNamesFilter) then
        -- If our globals are empty don't register and wait for the recall after globals populated in startup.
        return
    end
    Events.RegisterHandlerEvent(defines.events.on_built_entity, "Entity.OnBuiltEntity_MUPlacement", Entity.OnBuiltEntity_MUPlacement, "Entity.OnBuiltEntity_MUPlacement", global.entity.muWagonPlacementNameFilter)
    Events.RegisterHandlerEvent(defines.events.on_train_created, "Entity.OnTrainCreated", Entity.OnTrainCreated)
    Events.RegisterHandlerEvent(defines.events.on_player_mined_entity, "Entity.OnPlayerMined_MUWagon", Entity.OnPlayerMined_MUWagon, "Entity.OnPlayerMined_MUWagon", global.entity.muWagonNamesFilter)
    Events.RegisterHandlerEvent(defines.events.on_pre_player_mined_item, "Entity.OnPrePlayerMined_MUWagon", Entity.OnPrePlayerMined_MUWagon, "Entity.OnPrePlayerMined_MUWagon", global.entity.muWagonNamesFilter)
    Events.RegisterHandlerEvent(defines.events.on_entity_damaged, "Entity.OnEntityDamaged_MUWagon", Entity.OnEntityDamaged_MUWagon, "Entity.OnEntityDamaged_MUWagon", global.entity.muWagonNamesFilter)
    Events.RegisterHandlerEvent(defines.events.on_entity_died, "Entity.OnEntityDied_MUWagon", Entity.OnEntityDied_MUWagon, "Entity.OnEntityDied_MUWagon", global.entity.muWagonNamesFilter)
    Events.RegisterHandlerEvent(defines.events.on_robot_built_entity, "Entity.OnBuiltEntity_MUPlacement", Entity.OnBuiltEntity_MUPlacement, "Entity.OnBuiltEntity_MUPlacement", global.entity.muWagonNamesAndPlacementNameFilter)
    Events.RegisterHandlerEvent(defines.events.on_robot_mined_entity, "Entity.OnRobotMinedEntity_MUWagons", Entity.OnRobotMinedEntity_MUWagons, "Entity.OnRobotMinedEntity_MUWagons", global.entity.muWagonNamesFilter)
    Events.RegisterHandlerEvent(defines.events.on_player_setup_blueprint, "Entity.OnPlayerSetupBlueprint", Entity.OnPlayerSetupBlueprint)
end

Entity.OnStartup = function(event)
    Entity.OnMigration(event)

    global.entity.muWagonNamesFilter = Entity.GenerateMuWagonNamesFilter()
    global.entity.muWagonPlacementNameFilter = Entity.GenerateMuWagonPlacementNameFilter()
    local placementNameFilterForMerge = Utils.DeepCopy(global.entity.muWagonPlacementNameFilter)
    placementNameFilterForMerge[1].mode = "or"
    global.entity.muWagonNamesAndPlacementNameFilter = Utils.TableMerge({global.entity.muWagonNamesFilter, placementNameFilterForMerge})
    Entity.OnLoad() -- need to update dynmaic filter registration lists
end

Entity.OnMigration = function(event)
    local singleTrainUnitModVersion
    if event ~= nil and event.mod_changes ~= nil and event.mod_changes.single_train_unit ~= nil and event.mod_changes.single_train_unit.old_version ~= nil then
        singleTrainUnitModVersion = event.mod_changes.single_train_unit.old_version
    else
        singleTrainUnitModVersion = game.active_mods.single_train_unit
    end

    -- Remove the old forces groupings in global
    if singleTrainUnitModVersion < "19.0.6" and global.entity.forces ~= nil then
        local trainCount = 0
        for _, forceGrouping in pairs(global.entity.forces) do
            for _, stu in pairs(forceGrouping.singleTrainUnits) do
                trainCount = trainCount + 1
                global.entity.singleTrainUnits[trainCount] = stu
                stu.id = trainCount
            end
        end
        global.entity.forces = nil
    end

    -- Populate wagonIds attribute for global singleTrainUnits valid wagons
    if singleTrainUnitModVersion < "19.0.6" then
        for _, singleTrainUnit in pairs(global.entity.singleTrainUnits) do
            if singleTrainUnit.wagonIds == nil then
                singleTrainUnit.wagonIds = {}
                for _, wagon in pairs(singleTrainUnit.wagons) do
                    if wagon.valid then
                        table.insert(singleTrainUnit.wagonIds, wagon.unit_number)
                    end
                end
            end
        end
    end

    -- Remove any invalid global singleTrainUnits - can happen from mods being removed that added unique ones in, etc. So always do it.
    for index, singleTrainUnit in pairs(global.entity.singleTrainUnits) do
        local invalidWagon = false
        for _, wagon in pairs(singleTrainUnit.wagons) do
            if not wagon.valid then
                invalidWagon = true
                break
            end
        end
        if invalidWagon then
            for _, wagonId in pairs(singleTrainUnit.wagonIds) do
                global.entity.wagonIdToSingleTrainUnit[wagonId] = nil
            end
            global.entity.singleTrainUnits[index] = nil
        end
    end

    -- Remove any orphaned global wagonIdToSingleTrainUnit entries - can happen from before the wagonIds where tracked in a single train unit.
    if singleTrainUnitModVersion < "19.0.6" then
        for wagonId, singleTrainUnit in pairs(global.entity.wagonIdToSingleTrainUnit) do
            if global.entity.singleTrainUnits[singleTrainUnit.id] == nil then
                global.entity.wagonIdToSingleTrainUnit[wagonId] = nil
            end
        end
    end

    -- Fix the missing .type on earlier versions
    if singleTrainUnitModVersion < "19.0.4" then
        for index, singleTrainUnit in pairs(global.entity.singleTrainUnits) do
            if singleTrainUnit.wagons == nil or singleTrainUnit.wagons.middleCargo == nil or not singleTrainUnit.wagons.middleCargo.valid then
                global.entity.singleTrainUnits[index] = nil
            elseif singleTrainUnit.type == nil then
                singleTrainUnit.type = StaticData.entityNames[singleTrainUnit.wagons.middleCargo.name].unitType
            end
        end
    end

    -- Fix any damaged loco parts now that only the wagon takes damage
    if singleTrainUnitModVersion < "19.0.5" then
        for index, singleTrainUnit in pairs(global.entity.singleTrainUnits) do
            if singleTrainUnit.wagons.forwardLoco.health <= singleTrainUnit.wagons.forwardLoco.prototype.max_health then
                singleTrainUnit.wagons.forwardLoco.health = singleTrainUnit.wagons.forwardLoco.prototype.max_health
            end
            if singleTrainUnit.wagons.rearLoco.health <= singleTrainUnit.wagons.rearLoco.prototype.max_health then
                singleTrainUnit.wagons.rearLoco.health = singleTrainUnit.wagons.rearLoco.prototype.max_health
            end
        end
    end
end

Entity.GenerateMuWagonNamesFilter = function()
    local filterTable = {}
    for _, prototype in pairs(game.get_filtered_entity_prototypes({{filter = "rolling-stock"}})) do
        for _, staticDataName in pairs({StaticData.DoubleEndCargoLoco.name, StaticData.DoubleEndCargoWagon.name, StaticData.DoubleEndFluidLoco.name, StaticData.DoubleEndFluidWagon.name}) do
            if string.find(prototype.name, staticDataName, 1, true) then
                if #filterTable == 0 then
                    table.insert(filterTable, {filter = "name", name = prototype.name})
                else
                    table.insert(filterTable, {mode = "or", filter = "name", name = prototype.name})
                end
            end
        end
    end
    return filterTable
end

Entity.GenerateMuWagonPlacementNameFilter = function()
    local filterTable = {}
    for _, prototype in pairs(game.get_filtered_entity_prototypes({{filter = "rolling-stock"}})) do
        for _, staticDataName in pairs({StaticData.DoubleEndCargoPlacement.name, StaticData.DoubleEndFluidPlacement.name}) do
            if string.find(prototype.name, staticDataName, 1, true) then
                if #filterTable == 0 then
                    table.insert(filterTable, {filter = "name", name = prototype.name})
                else
                    table.insert(filterTable, {mode = "or", filter = "name", name = prototype.name})
                end
                Entity.GenerateRecordPlacementStaticDataVariant(staticDataName, prototype.name)
            end
        end
    end
    return filterTable
end

Entity.GenerateRecordPlacementStaticDataVariant = function(baseName, variantName)
    local variantNamePos_start, variantNamePos_end = string.find(variantName, baseName, 1, true)
    local variantNamePrefix, variantNameSuffix = string.sub(variantName, 1, variantNamePos_start - 1), string.sub(variantName, variantNamePos_end + 1)
    local variantPlacement = Utils.DeepCopy(StaticData.entityNames[baseName])
    variantPlacement.name = variantName
    if variantPlacement.placedStaticDataWagon ~= nil then
        local variantPart = Utils.DeepCopy(variantPlacement.placedStaticDataWagon)
        local variantPartName = variantNamePrefix .. variantPart.name .. variantNameSuffix
        if game.get_filtered_entity_prototypes({{filter = "name", name = variantPartName}}) ~= nil then
            variantPart.name = variantPartName
        end
        global.entity.muWagonVariants[variantPart.name] = variantPart
        variantPlacement.placedStaticDataWagon = variantPart
        variantPlacement.placedStaticDataWagon.placementStaticData = variantPlacement
    end
    if variantPlacement.placedStaticDataLoco ~= nil then
        local variantPart = Utils.DeepCopy(variantPlacement.placedStaticDataLoco)
        local variantPartName = variantNamePrefix .. variantPart.name .. variantNameSuffix
        if game.get_filtered_entity_prototypes({{filter = "name", name = variantPartName}}) ~= nil then
            variantPart.name = variantPartName
        end
        global.entity.muWagonVariants[variantPart.name] = variantPart
        variantPlacement.placedStaticDataLoco = variantPart
        variantPlacement.placedStaticDataLoco.placementStaticData = variantPlacement
    end
    global.entity.muWagonVariants[variantPlacement.name] = variantPlacement
end

Entity.OnBuiltEntity_MUPlacement = function(event)
    local entity = event.created_entity
    --Called from 2 different events with their own filter lists.
    if not Utils.GetTableKeyWithInnerKeyValue(global.entity.muWagonPlacementNameFilter, "name", entity.name) and not Utils.GetTableKeyWithInnerKeyValue(global.entity.muWagonNamesFilter, "name", entity.name) then
        return
    end

    local surface, force, placedEntityName, placedEntityPosition, placedEntityOrientation = entity.surface, entity.force, entity.name, entity.position, entity.orientation
    local placementStaticData = global.entity.muWagonVariants[placedEntityName]
    local builder = event.robot or game.get_player(event.player_index)
    local builderInventory = Utils.GetBuilderInventory(builder)

    -- Is a bot placing blueprint of the actual wagon, not the placement entity.
    if placementStaticData.placedStaticDataWagon == nil then
        placementStaticData = placementStaticData.placementStaticData
        placedEntityName = placementStaticData.name
    end

    local wagonStaticData, locoStaticData = placementStaticData.placedStaticDataWagon, placementStaticData.placedStaticDataLoco
    local placedEntityDirection = LoopDirectionValue(Utils.RoundNumberToDecimalPlaces(placedEntityOrientation * 8, 0))
    local locoDistance = (placementStaticData.joint_distance / 2) - (locoStaticData.joint_distance / 2)

    local forwardLocoOrientation = placedEntityOrientation
    local forwardLocoPosition = Utils.GetPositionForAngledDistance(placedEntityPosition, locoDistance, forwardLocoOrientation * 360)
    local forwardLocoDirection = placedEntityDirection
    local rearLocoOrientation = placedEntityOrientation - 0.5
    local rearLocoPosition = Utils.GetPositionForAngledDistance(placedEntityPosition, locoDistance, rearLocoOrientation * 360)
    local rearLocoDirection = LoopDirectionValue(placedEntityDirection + 4)
    local middleCargoDirection = placedEntityDirection
    local middleCargoPosition = placedEntityPosition

    local fuelInventory, fuelInventoryContents = entity.get_fuel_inventory(), nil
    if fuelInventory ~= nil then
        fuelInventoryContents = fuelInventory.get_contents()
    end
    local health = entity.health
    local fuelRequestProxy = surface.find_entities_filtered {position = entity.position, type = "item-request-proxy"}[1]
    local schedule = entity.train.schedule

    entity.destroy()
    local wagons = {forwardLoco = nil, middleCargo = nil, rearLoco = nil}

    wagons.forwardLoco = Entity.PlaceWagon(locoStaticData.name, forwardLocoPosition, surface, force, forwardLocoDirection)
    if wagons.forwardLoco == nil then
        Entity.PlaceOrionalWagonBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection, wagons, "Front Loco", event.replaced, event, fuelInventoryContents, health, schedule)
        return
    end
    wagons.forwardLoco.train.schedule = schedule

    wagons.middleCargo = Entity.PlaceWagon(wagonStaticData.name, middleCargoPosition, surface, force, middleCargoDirection)
    if wagons.middleCargo == nil then
        Entity.PlaceOrionalWagonBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection, wagons, "Middle Wagon", event.replaced, event, fuelInventoryContents, health, schedule)
        return
    end
    if event.tags ~= nil then
        local cargoInventory = wagons.middleCargo.get_inventory(defines.inventory.cargo_wagon)
        if cargoInventory ~= nil then
            if event.tags["single_train_unit-wagon_inventory_filters"] ~= nil then
                for _, filteredSlot in pairs(event.tags["single_train_unit-wagon_inventory_filters"]) do
                    cargoInventory.set_filter(filteredSlot.index, filteredSlot.name)
                end
            end
            if event.tags["single_train_unit-wagon_inventory_bar"] ~= nil then
                cargoInventory.set_bar(event.tags["single_train_unit-wagon_inventory_bar"])
            end
        end
    end

    wagons.rearLoco = Entity.PlaceWagon(locoStaticData.name, rearLocoPosition, surface, force, rearLocoDirection)
    if wagons.rearLoco == nil then
        Entity.PlaceOrionalWagonBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection, wagons, "Rear Loco", event.replaced, event, fuelInventoryContents, health, schedule)
        return
    end

    -- For nearly vertically aligned placements that are off by a fraction towards the top left to bottom right angle, the locos are created by Factorio both facing the same way, despite opposite directions specified. This is a very edge case, so just detect and rotate the bad one.
    local orientationDiff = wagons.rearLoco.orientation - wagons.forwardLoco.orientation
    if (orientationDiff > -1.25 and orientationDiff < -0.75) or (orientationDiff > -0.25 and orientationDiff < 0.25) or (orientationDiff > 0.75 and orientationDiff < 1.75) then
        local flipLoco = nil
        if (forwardLocoDirection == 0 and wagons.forwardLoco.orientation > 0.25 and wagons.forwardLoco.orientation < 0.75) or (forwardLocoDirection == 4 and (wagons.forwardLoco.orientation < 0.25 or wagons.forwardLoco.orientation > 0.75)) then
            flipLoco = wagons.forwardLoco
        end
        if (rearLocoDirection == 0 and wagons.rearLoco.orientation > 0.25 and wagons.rearLoco.orientation < 0.75) or (rearLocoDirection == 4 and (wagons.rearLoco.orientation < 0.25 or wagons.rearLoco.orientation > 0.75)) then
            flipLoco = wagons.rearLoco
        end
        if flipLoco then
            flipLoco.disconnect_rolling_stock(defines.rail_direction.front)
            flipLoco.disconnect_rolling_stock(defines.rail_direction.back)
            flipLoco.rotate()
        end
    end

    -- Connect to each end just incase during placement it didn't, or we detached them for some reason.
    for _, wagon in pairs(wagons) do
        wagon.connect_rolling_stock(defines.rail_direction.front)
        wagon.connect_rolling_stock(defines.rail_direction.back)
    end
    -- Set to blank as cargo & fluid wagons can't have names. We want all parts of the unit to have the same on-hover name.
    wagons.forwardLoco.backer_name = ""
    wagons.rearLoco.backer_name = ""

    -- Handle Fuel
    if not Utils.IsTableEmpty(fuelInventoryContents) then
        if builder.is_player() and builder.controller_type ~= defines.controllers.character then
            -- In editor mode with instant blueprints so just insert in both ends.
            local fuelName, fuelCount = next(fuelInventoryContents, nil)
            wagons.forwardLoco.get_fuel_inventory().insert({name = fuelName, count = fuelCount})
            wagons.rearLoco.get_fuel_inventory().insert({name = fuelName, count = fuelCount})
        else
            if game.active_mods["Fill4Me"] then
                -- Will insert the same amount of fuel in to both end locos as was placed in to the placement loco assuming fuel in builder inventory allowing. Otherwise will use all available and split between.
                local fuelName, fuelCount = next(fuelInventoryContents, nil)
                if fuelName ~= nil and fuelCount ~= nil and fuelCount > 0 then
                    local fuelAvailable = builderInventory.get_item_count(fuelName) + fuelCount
                    local fuelToInsert = math.ceil(math.min(fuelAvailable / 2, fuelCount))
                    local fuelInserted = 0
                    if fuelToInsert > 0 then
                        fuelInserted = fuelInserted + wagons.forwardLoco.get_fuel_inventory().insert({name = fuelName, count = fuelToInsert})
                    end
                    fuelToInsert = math.floor(math.min(fuelAvailable / 2, fuelCount))
                    if fuelToInsert > 0 then
                        fuelInserted = fuelInserted + wagons.rearLoco.get_fuel_inventory().insert({name = fuelName, count = fuelToInsert})
                    end
                    local fuelUsedFromBuilder = fuelInserted - fuelCount
                    if fuelUsedFromBuilder > 0 then
                        builderInventory.remove({name = fuelName, count = fuelUsedFromBuilder})
                    elseif fuelUsedFromBuilder < 0 then
                        Utils.TryInsertInventoryContents({[fuelName] = 0 - fuelUsedFromBuilder}, builderInventory, true, 1)
                    end
                end
            else
                -- Will spread the fuel from the placement loco across the 2 end locos.
                local fuelAllMoved = Utils.TryInsertInventoryContents(fuelInventoryContents, wagons.forwardLoco.get_fuel_inventory(), false, 0.5)
                if not fuelAllMoved then
                    fuelAllMoved = Utils.TryInsertInventoryContents(fuelInventoryContents, wagons.rearLoco.get_fuel_inventory(), false, 1)
                end
                if not fuelAllMoved then
                    Utils.TryInsertInventoryContents(fuelInventoryContents, builderInventory, true, 1)
                end
            end
        end
    end
    if fuelRequestProxy ~= nil and (not Utils.IsTableEmpty(fuelRequestProxy.item_requests)) then
        surface.create_entity {name = "item-request-proxy", position = wagons.forwardLoco.position, force = wagons.forwardLoco.force, target = wagons.forwardLoco, modules = fuelRequestProxy.item_requests}
        surface.create_entity {name = "item-request-proxy", position = wagons.rearLoco.position, force = wagons.rearLoco.force, target = wagons.rearLoco, modules = fuelRequestProxy.item_requests}
    end

    wagons.middleCargo.health = health

    Entity.RecordSingleUnit(wagons, wagonStaticData.unitType)
end

Entity.PlaceWagon = function(prototypeName, position, surface, force, direction)
    if debug_placementAttemptCircles then
        rendering.draw_circle {
            color = {r = 0, g = 0, b = 1},
            radius = 0.1,
            filled = true,
            target = position,
            surface = surface
        }
    end
    local wagon = surface.create_entity {name = prototypeName, position = position, force = force, snap_to_train_stop = false, direction = direction}
    if wagon == nil then
        Logging.LogPrint("WARNING: " .. prototypeName .. " failed to place at " .. Logging.PositionToString(position) .. " with direction: " .. direction, debug_writeAllWarnings)
        return
    end
    return wagon
end

Entity.PlaceOrionalWagonBack = function(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection, wagons, failedOnName, eventReplaced, event, fuelInventoryContents, health, schedule)
    -- As we failed to place all the expected parts remove any placed. Then place the origional wagon placement entity back, but backwards. Calling the replacement process on this reversed placement wagon generally works for any standard use cases because Factorio.
    local builder = event.robot or game.get_player(event.player_index)
    local builderInventory = Utils.GetBuilderInventory(builder)
    local placementSimpleItemStackTable = {{name = placedEntityName, count = 1, health = health}}

    Logging.LogPrint("WARNING: " .. "failed placing " .. failedOnName .. " - first orientation", debug_writeAllWarnings)
    for _, wagon in pairs(wagons) do
        if wagon ~= nil and wagon.valid then
            wagon.destroy()
        end
    end
    if eventReplaced ~= nil and eventReplaced then
        Logging.LogPrint("ERROR: " .. "failed placing single train unit on this exact bit of track, please try somewhere else.")
        Logging.LogPrint("ERROR: " .. "failed placing " .. failedOnName .. " - second orientation", debug_writeAllWarnings)
        Utils.TryInsertSimpleItems(placementSimpleItemStackTable, builderInventory, true, 1)
        Utils.TryInsertInventoryContents(fuelInventoryContents, builderInventory, true, 1)
        return
    end

    placedEntityDirection = LoopDirectionValue(placedEntityDirection + 4)
    local placedWagon = surface.create_entity {name = placedEntityName, position = placedEntityPosition, force = force, snap_to_train_stop = false, direction = placedEntityDirection}
    if placedWagon ~= nil then
        Utils.TryInsertInventoryContents(fuelInventoryContents, placedWagon.get_fuel_inventory(), true, 1)
        placedWagon.health = health
        placedWagon.train.schedule = schedule
    else
        Logging.LogPrint("ERROR: " .. "failed to place origional " .. placedEntityName .. " back at " .. Logging.PositionToString(placedEntityPosition) .. " with new direction: " .. placedEntityDirection)
        Utils.TryInsertSimpleItems(placementSimpleItemStackTable, builderInventory, true, 1)
        Utils.TryInsertInventoryContents(fuelInventoryContents, builderInventory, true, 1)
        return
    end
    Logging.LogPrint("WARNING: " .. "placed origional " .. placedEntityName .. " back at " .. Logging.PositionToString(placedEntityPosition) .. " with new direction: " .. placedEntityDirection, debug_writeAllWarnings)

    Entity.OnBuiltEntity_MUPlacement({created_entity = placedWagon, replaced = true, robot = event.robot, player_index = event.player_index})
end

Entity.RecordSingleUnit = function(wagons, type)
    local singleTrainUnitId = #global.entity.singleTrainUnits + 1
    global.entity.singleTrainUnits[singleTrainUnitId] = {
        id = singleTrainUnitId,
        wagons = wagons,
        wagonIds = {},
        type = type
    }
    local singleTrainUnit = global.entity.singleTrainUnits[singleTrainUnitId]
    for _, wagon in pairs(wagons) do
        global.entity.wagonIdToSingleTrainUnit[wagon.unit_number] = singleTrainUnit
        table.insert(singleTrainUnit.wagonIds, wagon.unit_number)
    end
end

Entity.DeleteSingleUnitRecord = function(singleTrainUnitId)
    local singleTrainUnit = global.entity.singleTrainUnits[singleTrainUnitId]
    if singleTrainUnit == nil then
        return
    end
    for _, wagonId in pairs(singleTrainUnit.wagonIds) do
        global.entity.wagonIdToSingleTrainUnit[wagonId] = nil
    end
    global.entity.singleTrainUnits[singleTrainUnitId] = nil
end

Entity.OnTrainCreated = function(event)
    -- This is just to protect against the user disconnecting the parts of the single trian unit. It does tend to loop a bit, but as long as no infinite loops we are all good.

    if event.old_train_id_1 ~= nil and event.old_train_id_2 ~= nil then
        -- Is the joining of 2 trains togeather.
        return
    end
    if event.old_train_id_1 == nil and event.old_train_id_2 == nil then
        -- Is the creation of a single new trian.
        return
    end

    local frontCarriage = event.train.front_stock
    local backCarriage = event.train.back_stock
    if frontCarriage == nil or backCarriage == nil then
        return
    end

    -- If this train doesn't have a STU table entry (either not an STU or hasn't been registered yet) don't interfear as it can break other game logic.
    local stu = global.entity.wagonIdToSingleTrainUnit[frontCarriage.unit_number]
    if stu == nil then
        return
    end

    -- Connects to the front or back of the rolling stock direction, not the train direction. The reverse of the connect direction based on the other end of the trains wagon seems to work in testing, but feels a bit janky.
    local frontWagonStaticData = global.entity.muWagonVariants[frontCarriage.name]
    if frontWagonStaticData ~= nil and (frontWagonStaticData.prototypeType == "cargo-wagon" or frontWagonStaticData.prototypeType == "fluid-wagon") then
        local orientationDif = math.abs(frontCarriage.orientation - backCarriage.orientation)
        if orientationDif < 0.25 then
            frontCarriage.connect_rolling_stock(defines.rail_direction.front)
        else
            frontCarriage.connect_rolling_stock(defines.rail_direction.back)
        end
    end

    local backWagonStaticData = global.entity.muWagonVariants[backCarriage.name]
    if backWagonStaticData ~= nil and (backWagonStaticData.prototypeType == "cargo-wagon" or backWagonStaticData.prototypeType == "fluid-wagon") then
        local orientationDif = math.abs(frontCarriage.orientation - backCarriage.orientation)
        if orientationDif < 0.25 then
            backCarriage.connect_rolling_stock(defines.rail_direction.back)
        else
            backCarriage.connect_rolling_stock(defines.rail_direction.front)
        end
    end
end

Entity.OnPlayerMined_MUWagon = function(event)
    local minedWagon, force = event.entity, event.entity.force
    local singleTrainUnit = global.entity.wagonIdToSingleTrainUnit[minedWagon.unit_number]
    if singleTrainUnit == nil then
        return
    end

    local player = game.get_player(event.player_index)
    local playerInventory = player.get_main_inventory()
    local thisUnitsWagons = Utils.DeepCopy(singleTrainUnit.wagons)
    Entity.DeleteSingleUnitRecord(singleTrainUnit.id)
    local thisWagonId = minedWagon.unit_number

    for _, wagon in pairs(thisUnitsWagons) do
        -- Take any grid equipment left over as otherwise it will be lost by this point.
        local wagonGrid = wagon.grid
        if wagonGrid ~= nil then
            Utils.TryTakeGridsItems(wagonGrid, playerInventory, true)
        end
        if wagon.valid and wagon.unit_number ~= thisWagonId then
            player.mine_entity(wagon, force)
        end
    end
end

Entity.OnPrePlayerMined_MUWagon = function(event)
    -- This tries to take all the other contents (cargo items, fuel, grid) of the train than the part you mined first. If the mined entity contents are more than the players inventory space this will mean the players inventory fills up and then the game will naturally not try to mine the train entities themselves. So we fill it up from other parts first to let the game behave naturally.
    local minedWagon = event.entity
    local singleTrainUnit = global.entity.wagonIdToSingleTrainUnit[minedWagon.unit_number]
    if singleTrainUnit == nil then
        return
    end
    local minedWagonStaticData = global.entity.muWagonVariants[minedWagon.name]
    local player = game.get_player(event.player_index)
    local playerInventory = player.get_main_inventory()

    local cargoAllMoved, firstCargoStack, cargoWagonInventory = true, nil, nil
    if singleTrainUnit.type == "cargo" then
        cargoWagonInventory = singleTrainUnit.wagons.middleCargo.get_inventory(defines.inventory.cargo_wagon)
        if cargoWagonInventory ~= nil then
            local cargoWagonInventoryContents = cargoWagonInventory.get_contents()
            for name, count in pairs(cargoWagonInventoryContents) do
                local itemPrototype = game.item_prototypes[name]
                if itemPrototype.type == "item" then
                    firstCargoStack = {name = name, count = math.min(itemPrototype.stack_size, count)}
                    break
                end
            end
            cargoAllMoved = Utils.TryMoveInventoriesLuaItemStacks(cargoWagonInventory, playerInventory)
        end
    end
    if not cargoAllMoved then
        return
    elseif minedWagonStaticData.unitType == "cargo" and minedWagonStaticData.type == "wagon" and firstCargoStack ~= nil then
        -- You are mining the wagon part, so put 1 stack back to block the final entity mine if we fill up from other parts of the train.
        local inserted = cargoWagonInventory.insert(firstCargoStack)
        playerInventory.remove({name = firstCargoStack.name, count = inserted})
    end

    local fuelAllMoved
    fuelAllMoved = Utils.TryMoveInventoriesLuaItemStacks(singleTrainUnit.wagons.forwardLoco.get_fuel_inventory(), playerInventory)
    if not fuelAllMoved then
        return
    end
    fuelAllMoved = Utils.TryMoveInventoriesLuaItemStacks(singleTrainUnit.wagons.rearLoco.get_fuel_inventory(), playerInventory)
    if not fuelAllMoved then
        return
    end

    local gridAllMoved
    for _, wagon in pairs(singleTrainUnit.wagons) do
        local wagonGrid = wagon.grid
        if wagonGrid ~= nil then
            gridAllMoved = Utils.TryTakeGridsItems(wagonGrid, playerInventory)
            if not gridAllMoved then
                return
            end
        end
    end
end

Entity.GetDamageCauseString = function(event)
    local causeString
    if event.cause == nil then
        causeString = "unknown"
    else
        causeString = event.cause.name
        if event.cause.type == "character" and event.cause.player then
            causeString = causeString .. "_" .. event.cause.player.name
        elseif event.cause.unit_number then
            causeString = causeString .. "_" .. event.cause.unit_number
        end
    end
    causeString = causeString .. "-" .. event.damage_type.name
    return causeString
end

Entity.OnEntityDamaged_MUWagon = function(event)
    local damagedWagon = event.entity
    local singleTrainUnit = global.entity.wagonIdToSingleTrainUnit[damagedWagon.unit_number]
    if singleTrainUnit == nil then
        return
    end
    local cargoWagon = singleTrainUnit.wagons.middleCargo

    if global.entity.damageSourcesTick ~= event.tick then
        global.entity.damageSourcesTick = event.tick
        global.entity.damageSourcesThisTick = {}
    end
    local damageName = Entity.GetDamageCauseString(event)
    local damageToDo = event.final_damage_amount
    -- This damageToDo is to handle variable damage from the same thing affecting multiple parts, however, it does mean that dual damaging weapons (explosive rockets, cluster grenades, etc) will only do their single most max damage and not the damage from each part.
    global.entity.damageSourcesThisTick[singleTrainUnit] = global.entity.damageSourcesThisTick[singleTrainUnit] or {}
    local thisTrainsDamageSourcesThisTick = global.entity.damageSourcesThisTick[singleTrainUnit]
    if thisTrainsDamageSourcesThisTick[damageName] == nil then
        thisTrainsDamageSourcesThisTick[damageName] = damageToDo
    else
        if thisTrainsDamageSourcesThisTick[damageName] < event.final_damage_amount then
            damageToDo = event.final_damage_amount - thisTrainsDamageSourcesThisTick[damageName]
            thisTrainsDamageSourcesThisTick[damageName] = event.final_damage_amount
        else
            damageToDo = 0
        end
    end

    damagedWagon.health = damagedWagon.health + event.final_damage_amount
    cargoWagon.health = cargoWagon.health - damageToDo
    if cargoWagon.health == 0 then
        if event.cause ~= nil then
            cargoWagon.die(event.force, event.cause)
        else
            cargoWagon.die(event.force)
        end
    end
end

Entity.OnEntityDied_MUWagon = function(event)
    local damagedWagon = event.entity
    local singleTrainUnit = global.entity.wagonIdToSingleTrainUnit[damagedWagon.unit_number]
    if singleTrainUnit == nil then
        return
    end

    for _, wagon in pairs(singleTrainUnit.wagons) do
        if wagon.valid and wagon.unit_number ~= damagedWagon.unit_number then
            wagon.die()
        end
    end

    Entity.DeleteSingleUnitRecord(singleTrainUnit.id)
end

Entity.OnRobotMinedEntity_MUWagons = function(event)
    -- Try to move the various contents in to the robot picking up the item. In some cases the items will fall on the ground from the construction robot, but marked for decon, etc. This is vanilla behaviour, i.e rocks.
    local minedWagon, buffer = event.entity, event.buffer
    local singleTrainUnit = global.entity.wagonIdToSingleTrainUnit[minedWagon.unit_number]
    if singleTrainUnit == nil then
        return
    end

    Utils.TryMoveInventoriesLuaItemStacks(singleTrainUnit.wagons.forwardLoco.get_fuel_inventory(), buffer)
    Utils.TryMoveInventoriesLuaItemStacks(singleTrainUnit.wagons.rearLoco.get_fuel_inventory(), buffer)
    for _, wagon in pairs(singleTrainUnit.wagons) do
        local wagonGrid = wagon.grid
        if wagonGrid ~= nil then
            Utils.TryTakeGridsItems(wagonGrid, buffer)
        end
    end

    local thisUnitsWagons = Utils.DeepCopy(singleTrainUnit.wagons)
    Entity.DeleteSingleUnitRecord(singleTrainUnit.id)
    local thisWagonId = minedWagon.unit_number

    for _, wagon in pairs(thisUnitsWagons) do
        if wagon.valid and wagon.unit_number ~= thisWagonId then
            wagon.destroy()
        end
    end
end

Entity.OnPlayerSetupBlueprint = function(event)
    -- We could try and work out what parts relate to which single train units. Then use this to set the schedule fuel uniquely per single train unit. But we don't as seems a lot of effort for real edge cases.
    local player = game.get_player(event.player_index)
    local blueprint = player.blueprint_to_setup
    if not blueprint.valid_for_read then
        return
    end
    local entities = blueprint.get_blueprint_entities()
    if entities == nil then
        return
    end
    local placementWagons, fuelTrackingTable, schedule = {}, {}, nil
    for index, entity in pairs(entities) do
        local staticData = global.entity.muWagonVariants[entity.name]
        if staticData ~= nil then
            if staticData.type == "loco" then
                if entity.items ~= nil then
                    for itemName, itemCount in pairs(entity.items) do
                        Utils.TrackBestFuelCount(fuelTrackingTable, itemName, itemCount)
                    end
                end
                if schedule == nil and entity.schedule then
                    -- We apply the same schedule found to all Single Train Units in the BP.
                    schedule = entity.schedule
                end
                entities[index] = nil
            elseif staticData.type == "wagon" then
                entity.name = staticData.placementStaticData.name
                if schedule ~= nil then
                    entity.schedule = schedule
                end
                table.insert(placementWagons, entity)
                if entity.inventory ~= nil then
                    entity.tags = entity.tags or {}
                    if entity.inventory.filters ~= nil then
                        entity.tags["single_train_unit-wagon_inventory_filters"] = entity.inventory.filters
                    end
                    if entity.inventory.bar ~= nil then
                        entity.tags["single_train_unit-wagon_inventory_bar"] = entity.inventory.bar
                    end
                end
            end
        end
    end
    if not Utils.IsTableEmpty(fuelTrackingTable) then
        for _, entity in pairs(placementWagons) do
            entity.items = entity.items or {}
            entity.items[fuelTrackingTable.fuelName] = fuelTrackingTable.fuelCount
        end
    end
    blueprint.set_blueprint_entities(entities)
end

return Entity
