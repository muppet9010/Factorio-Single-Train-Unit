local Entity = {}
local Utils = require("utility/utils")
local Logging = require("utility/logging")
local StaticData = require("static-data")

local placementAttemptCircles = false
local writeAllWarnings = false

local LoopDirectionValue = function(value)
    return Utils.LoopIntValueWithinRange(value, 0, 7)
end

Entity.CreateGlobals = function()
    global.entity = global.entity or {}
    global.entity.forces = global.entity.forces or {}
    global.singleTrainUnitIdsWagonsIds = {}
    global.wagonsIdsSingleTrainUnitIds = {}
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

    Entity.RecordSingleUnit(force, wagons)
end

Entity.RecordSingleUnit = function(force, wagons)
    global.entity.forces[force.index] =
        global.entity.forces[force.index] or
        {
            singleTrainUnits = {}
        }
    local forcesEntry = global.entity.forces[force.index]

    forcesEntry.singleTrainUnits[#forcesEntry.singleTrainUnits] = {
        id = #forcesEntry.singleTrainUnits,
        wagons = wagons
    }

    local singleTrainUnitId = #global.singleTrainUnitIdsWagonsIds
    for _, wagon in pairs(wagons) do
        global.singleTrainUnitIdsWagonsIds[singleTrainUnitId] = wagon.unit_number
        global.wagonsIdsSingleTrainUnitIds[wagon.unit_number] = singleTrainUnitId
    end
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

return Entity
