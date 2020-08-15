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

local TryMoveInventoryContents = function(sourceInventory, targetInventory, dropUnmovedOnGround)
    local sourceOwner, itemsNotMoved = nil, false
    for name, count in pairs(sourceInventory.get_contents()) do
        local moved = targetInventory.insert({name = name, count = count})
        if moved > 0 then
            sourceInventory.remove({name = name, count = moved})
        end
        local remaining = count - moved
        if remaining > 0 then
            itemsNotMoved = true
        end
        if dropUnmovedOnGround then
            sourceOwner = sourceOwner or targetInventory.entity_owner
            sourceOwner.surface.spill_item_stack(sourceOwner.position, {name = name, count = remaining}, true, sourceOwner.force, false)
        end
    end
    return not itemsNotMoved
end

Entity.CreateGlobals = function()
    global.entity = global.entity or {}
    global.entity.forces = global.entity.forces or {}
    --[[
    global.entity.forces[force.index].singleTrainUnits = {
        id = singleTrainUnitId,
        wagons = {
            forwardLoco = ENTITY, middleCargo = ENTITY, rearLoco = ENTITY
        },
        type = STATICDATA WAGON TYPE
    } -- Defined when first used and the force entry is generated.
    --]]
    global.entity.wagonIdToSingleTrainUnit = global.entity.wagonIdToSingleTrainUnit or {} -- WagonId to lobal.entity.forces[force.index].singleTrainUnits entry
end

Entity.OnLoad = function()
    local muWagonNamesFilter = {{filter = "name", name = StaticData.mu_cargo_loco.name}, {mode = "or", filter = "name", name = StaticData.mu_cargo_wagon.name}, {mode = "or", filter = "name", name = StaticData.mu_fluid_loco.name}, {mode = "or", filter = "name", name = StaticData.mu_fluid_wagon.name}}

    Events.RegisterEvent(defines.events.on_built_entity, "Entity.OnBuiltEntity_MUPlacement", {{filter = "name", name = StaticData.mu_cargo_placement.name}, {mode = "or", filter = "name", name = StaticData.mu_fluid_placement.name}})
    Events.RegisterHandler(defines.events.on_built_entity, "Entity.OnBuiltEntity_MUPlacement", Entity.OnBuiltEntity_MUPlacement)
    Events.RegisterEvent(defines.events.on_train_created)
    Events.RegisterHandler(defines.events.on_train_created, "Entity.OnTrainCreated", Entity.OnTrainCreated)
    Events.RegisterEvent(defines.events.on_player_mined_entity, "Entity.OnPlayerMined_MUWagon", muWagonNamesFilter)
    Events.RegisterHandler(defines.events.on_player_mined_entity, "Entity.OnPlayerMined_MUWagon", Entity.OnPlayerMined_MUWagon)
    Events.RegisterEvent(defines.events.on_pre_player_mined_item, "Entity.OnPrePlayerMined_MUWagon", muWagonNamesFilter)
    Events.RegisterHandler(defines.events.on_pre_player_mined_item, "Entity.OnPrePlayerMined_MUWagon", Entity.OnPrePlayerMined_MUWagon)
    Events.RegisterEvent(defines.events.on_entity_damaged, "Entity.OnEntityDamaged_MUWagon", muWagonNamesFilter)
    Events.RegisterHandler(defines.events.on_entity_damaged, "Entity.OnEntityDamaged_MUWagon", Entity.OnEntityDamaged_MUWagon)
    Events.RegisterEvent(defines.events.on_entity_died, "Entity.OnEntityDied_MUWagon", muWagonNamesFilter)
    Events.RegisterHandler(defines.events.on_entity_died, "Entity.OnEntityDied_MUWagon", Entity.OnEntityDied_MUWagon)
end

Entity.OnBuiltEntity_MUPlacement = function(event)
    local entity = event.created_entity
    local surface, force, placedEntityName, placedEntityPosition, placedEntityOrientation = entity.surface, entity.force, entity.name, entity.position, entity.orientation
    local placementStaticData = StaticData.entityNames[placedEntityName]
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

    entity.destroy()
    local wagons = {forwardLoco = nil, middleCargo = nil, rearLoco = nil}

    wagons.forwardLoco = Entity.PlaceWagon(locoStaticData.name, forwardLocoPosition, surface, force, forwardLocoDirection)
    if wagons.forwardLoco == nil then
        Entity.PlaceOrionalLocoBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection, wagons, "Front Loco", event.replaced)
        return
    end

    wagons.middleCargo = Entity.PlaceWagon(wagonStaticData.name, middleCargoPosition, surface, force, middleCargoDirection)
    if wagons.middleCargo == nil then
        Entity.PlaceOrionalLocoBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection, wagons, "Middle Cargo Wagon", event.replaced)
        return
    end

    wagons.rearLoco = Entity.PlaceWagon(locoStaticData.name, rearLocoPosition, surface, force, rearLocoDirection)
    if wagons.rearLoco == nil then
        Entity.PlaceOrionalLocoBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection, wagons, "Rear Loco", event.replaced)
        return
    end

    for _, wagon in pairs(wagons) do
        wagon.connect_rolling_stock(defines.rail_direction.front)
        wagon.connect_rolling_stock(defines.rail_direction.back)
    end

    -- Set to blank as cargo & fluid wagons can't have names. We want all parts of the unit to have the same on-hover name.
    wagons.forwardLoco.backer_name = ""
    wagons.rearLoco.backer_name = ""

    Entity.RecordSingleUnit(force, wagons, wagonStaticData.type)
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

Entity.PlaceOrionalLocoBack = function(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection, wagons, failedOnName, eventReplaced)
    -- As we failed to place all the expected parts remove any placed. Then place the origional loco placement entity back, but backwards. Calling the replacement process on this reversed placement loco generally works for any standard use cases because Factorio.
    Logging.LogPrint("WARNING: " .. "failed placing " .. failedOnName, debug_writeAllWarnings)
    for _, wagon in pairs(wagons) do
        if wagon ~= nil and wagon.valid then
            wagon.destroy()
        end
    end
    if eventReplaced ~= nil and eventReplaced then
        Logging.LogPrint("ERROR: " .. "failed placing " .. failedOnName .. " for second orientation, so giving up")
        return
    end

    placedEntityDirection = LoopDirectionValue(placedEntityDirection + 4)
    local placedLoco = surface.create_entity {name = placedEntityName, position = placedEntityPosition, force = force, snap_to_train_stop = false, direction = placedEntityDirection}
    if placedLoco == nil then
        Logging.LogPrint("ERROR: " .. "failed to placed origional " .. placedEntityName .. " back at " .. Logging.PositionToString(placedEntityPosition) .. " with new direction: " .. placedEntityDirection)
        return
    end
    Logging.LogPrint("WARNING: " .. "placed origional " .. placedEntityName .. " back at " .. Logging.PositionToString(placedEntityPosition) .. " with new direction: " .. placedEntityDirection, debug_writeAllWarnings)
    Entity.OnBuiltEntity_MUPlacement({created_entity = placedLoco, replaced = true})
end

Entity.RecordSingleUnit = function(force, wagons)
    global.entity.forces[force.index] =
        global.entity.forces[force.index] or
        {
            singleTrainUnits = {}
        }
    local forcesEntry = global.entity.forces[force.index]
    local singleTrainUnitId = #forcesEntry.singleTrainUnits + 1
    forcesEntry.singleTrainUnits[singleTrainUnitId] = {
        id = singleTrainUnitId,
        wagons = wagons,
        type = type
    }
    for _, wagon in pairs(wagons) do
        global.entity.wagonIdToSingleTrainUnit[wagon.unit_number] = forcesEntry.singleTrainUnits[singleTrainUnitId]
    end
end

Entity.DeleteSingleUnitRecord = function(force, singleTrainUnitId)
    local forcesEntry = global.entity.forces[force.index]
    if forcesEntry == nil or forcesEntry.singleTrainUnits[singleTrainUnitId] == nil then
        return
    end
    for _, wagon in pairs(forcesEntry.singleTrainUnits[singleTrainUnitId].wagons) do
        if wagon.valid then
            global.entity.wagonIdToSingleTrainUnit[wagon.unit_number] = nil
        end
    end
    forcesEntry.singleTrainUnits[singleTrainUnitId] = nil
end

Entity.OnTrainCreated = function(event)
    if event.old_train_id_1 == nil and event.old_train_id_2 == nil then
        return
    end
    local carriages = event.train.carriages
    if carriages == nil or #carriages == 0 then
        return
    end

    for i, wagon in pairs(carriages) do
        local wagonStaticData = StaticData.entityNames[wagon.name]
        if wagonStaticData ~= nil and wagonStaticData.placementStaticData ~= nil then
            wagon.connect_rolling_stock(defines.rail_direction.front)
            wagon.connect_rolling_stock(defines.rail_direction.back)
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
    local thisUnitsWagons = Utils.DeepCopy(singleTrainUnit.wagons)
    Entity.DeleteSingleUnitRecord(force, singleTrainUnit.id)
    local thisWagonId = minedWagon.unit_number

    for _, wagon in pairs(thisUnitsWagons) do
        if wagon.valid and wagon.unit_number ~= thisWagonId then
            player.mine_entity(wagon, force)
        end
    end
end

Entity.OnPrePlayerMined_MUWagon = function(event)
    --This tries to take all the cargo items, then fuel before the actual MU Wagon entiies get mined. If the train contents are more than the players inventory space this will mean the players inventory fills up and then the game will naturally not try to mine the train entities themselves.
    local minedWagon = event.entity
    local singleTrainUnit = global.entity.wagonIdToSingleTrainUnit[minedWagon.unit_number]
    if singleTrainUnit == nil then
        return
    end

    local player = game.get_player(event.player_index)
    local playerInventory = player.get_main_inventory()
    if singleTrainUnit.type == "cargo-wagon" then
        TryMoveInventoryContents(singleTrainUnit.wagons.middleCargo.get_inventory(defines.inventory.cargo_wagon), playerInventory, false)
    end
    TryMoveInventoryContents(singleTrainUnit.wagons.forwardLoco.get_fuel_inventory(), playerInventory, false)
    TryMoveInventoryContents(singleTrainUnit.wagons.rearLoco.get_fuel_inventory(), playerInventory, false)
end

Entity.OnEntityDamaged_MUWagon = function(event)
    local damagedWagon = event.entity
    local singleTrainUnit = global.entity.wagonIdToSingleTrainUnit[damagedWagon.unit_number]

    for _, wagon in pairs(singleTrainUnit.wagons) do
        if wagon.valid and wagon.unit_number ~= damagedWagon.unit_number then
            wagon.health = wagon.health - event.final_damage_amount
        end
    end
end

Entity.OnEntityDied_MUWagon = function(event)
    local damagedWagon = event.entity
    local singleTrainUnit = global.entity.wagonIdToSingleTrainUnit[damagedWagon.unit_number]

    for _, wagon in pairs(singleTrainUnit.wagons) do
        if wagon.valid and wagon.unit_number ~= damagedWagon.unit_number then
            wagon.die()
        end
    end

    Entity.DeleteSingleUnitRecord(event.force, singleTrainUnit.id)
end

return Entity
