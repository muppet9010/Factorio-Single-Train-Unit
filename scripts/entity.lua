local Entity = {}
local Utils = require("utility/utils")
local Logging = require("utility/logging")
local StaticData = require("static-data")

local placementAttemptCircles = false
local writeAllWarnings = false

local LoopDirectionValue = function(value)
    return Utils.LoopIntValueWithinRange(value, 0, 7)
end

local MoveInventoryContents = function(sourceInventory, targetInventory, dropUnmovedOnGround)
    local sourceOwner
    for name, count in pairs(sourceInventory.get_contents()) do
        local moved = targetInventory.insert({name = name, count = count})
        if moved > 0 then
            sourceInventory.remove({name = name, count = moved})
        end
        if dropUnmovedOnGround then
            sourceOwner = sourceOwner or targetInventory.entity_owner
            sourceOwner.surface.spill_item_stack(sourceOwner.position, {name = name, count = count - moved}, true, sourceOwner.force, false)
        end
    end
end

Entity.CreateGlobals = function()
    global.entity = global.entity or {}
    Entity.UpgradeGlobals()
    global.entity.forces = global.entity.forces or {}
    --[[
    global.entity.forces[force.index].singleTrainUnits = {
        id = singleTrainUnitId,
        wagons = {
            forwardLoco = ENTITY, middleCargo = ENTITY, rearLoco = ENTITY
        }
    } -- Defined when first used and the force entry is generated.
    --]]
    global.entity.wagonIdToSingleTrainUnit = global.entity.wagonIdToSingleTrainUnit or {} -- WagonId to lobal.entity.forces[force.index].singleTrainUnits entry
    global.entity.minedWagonIds = global.entity.minedWagonIds or {}
end

Entity.UpgradeGlobals = function()
    if global.entity.wagonsIdsSingleTrainUnitIds ~= nil then
        global.entity.wagonIdToSingleTrainUnit = global.entity.wagonsIdsSingleTrainUnitIds
        global.entity.wagonsIdsSingleTrainUnitIds = nil
    end
end

Entity.PlaceWagon = function(prototypeName, position, surface, force, direction)
    if placementAttemptCircles then
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
        Logging.LogPrint("WARNING: " .. prototypeName .. " failed to place at " .. Logging.PositionToString(position) .. " with direction: " .. direction, writeAllWarnings)
        return
    end
    return wagon
end

Entity.PlaceOrionalLocoBack = function(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection, wagons, failedOnName, eventReplaced)
    -- As we failed to place all the expected parts remove any placed. Then place the origional loco placement entity back, but backwards. Calling the replacement process on this reversed placement loco generally works for any standard use cases because Factorio.
    Logging.LogPrint("WARNING: " .. "failed placing " .. failedOnName, writeAllWarnings)
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
    Logging.LogPrint("WARNING: " .. "placed origional " .. placedEntityName .. " back at " .. Logging.PositionToString(placedEntityPosition) .. " with new direction: " .. placedEntityDirection, writeAllWarnings)
    Entity.OnBuiltEntity_MUPlacement({created_entity = placedLoco, replaced = true})
end

Entity.OnBuiltEntity_MUPlacement = function(event)
    local entity = event.created_entity
    local surface = entity.surface
    local force = entity.force
    local placedEntityName = entity.name
    local placedEntityPosition = entity.position
    local placedEntityOrientation = entity.orientation
    local placedEntityDirection = LoopDirectionValue(Utils.RoundNumberToDecimalPlaces(placedEntityOrientation * 8, 0))
    local locoDistance = (StaticData.mu_placement.joint_distance / 2) - (StaticData.mu_locomotive.joint_distance / 2)
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

    wagons.forwardLoco = Entity.PlaceWagon(StaticData.mu_locomotive.name, forwardLocoPosition, surface, force, forwardLocoDirection)
    if wagons.forwardLoco == nil then
        Entity.PlaceOrionalLocoBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection, wagons, "Front Loco", event.replaced)
        return
    end

    wagons.middleCargo = Entity.PlaceWagon(StaticData.mu_cargo_wagon.name, middleCargoPosition, surface, force, middleCargoDirection)
    if wagons.middleCargo == nil then
        Entity.PlaceOrionalLocoBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection, wagons, "Middle Cargo Wagon", event.replaced)
        return
    end

    wagons.rearLoco = Entity.PlaceWagon(StaticData.mu_locomotive.name, rearLocoPosition, surface, force, rearLocoDirection)
    if wagons.rearLoco == nil then
        Entity.PlaceOrionalLocoBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection, wagons, "Rear Loco", event.replaced)
        return
    end

    for _, wagon in pairs(wagons) do
        wagon.connect_rolling_stock(defines.rail_direction.front)
        wagon.connect_rolling_stock(defines.rail_direction.back)
    end

    wagons.forwardLoco.backer_name = ""
    wagons.rearLoco.backer_name = ""

    Entity.RecordSingleUnit(force, wagons)
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
        wagons = wagons
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
        if wagon.name == StaticData.mu_cargo_wagon.name then
            wagon.connect_rolling_stock(defines.rail_direction.front)
            wagon.connect_rolling_stock(defines.rail_direction.back)
        end
    end
end

Entity.OnPlayerMined_MUWagon = function(event)
    local minedWagon, force, player = event.entity, event.entity.force, game.get_player(event.player_index)
    local singleTrainUnit = global.entity.wagonIdToSingleTrainUnit[minedWagon.unit_number]
    global.entity.minedWagonIds[minedWagon.unit_number] = true --This entity has been mined already as it triggered this event.

    for _, wagon in pairs(singleTrainUnit.wagons) do
        if wagon.valid and global.entity.minedWagonIds[wagon.unit_number] == nil then
            global.entity.minedWagonIds[wagon.unit_number] = true
            local minedSuccess = player.mine_entity(wagon, force)
        end
    end

    Entity.DeleteSingleUnitRecord(force, singleTrainUnit.id)
end

Entity.OnPrePlayerMined_MUWagon = function(event)
    --This tries to take all the cargo items, then fuel before the actual MU Wagon entiies get mined. If the train contents are more than the players inventory space this will mean the players inventory fills up and then the game will naturally not try to mine the train entities themselves.
    local minedWagon, force, player = event.entity, event.entity.force, game.get_player(event.player_index)
    local singleTrainUnit = global.entity.wagonIdToSingleTrainUnit[minedWagon.unit_number]
    local playerInventory = player.get_main_inventory()
    MoveInventoryContents(singleTrainUnit.wagons.middleCargo.get_inventory(defines.inventory.cargo_wagon), playerInventory, false)
    MoveInventoryContents(singleTrainUnit.wagons.forwardLoco.get_fuel_inventory(), playerInventory, false)
    MoveInventoryContents(singleTrainUnit.wagons.rearLoco.get_fuel_inventory(), playerInventory, false)
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
