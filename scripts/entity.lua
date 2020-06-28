local Entity = {}
local Utils = require("utility/utils")
local Logging = require("utility/logging")
local StaticData = require("static-data")

local placementAttempCircles = false
local writeAllWarnings = false

local loopIntValueWithinRangeFrom0 = function(value, max)
    local min = 0
    if value > max then
        return min - (max - value) - 1
    elseif value < min then
        return max + (value - min) + 1
    else
        return value
    end
end

Entity.PlaceWagon = function(prototypeName, position, surface, force, direction)
    if placementAttempCircles then
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

Entity.PlaceOrionalLocoBack = function(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection)
    placedEntityDirection = loopIntValueWithinRangeFrom0(placedEntityDirection + 4, 7)
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
    local placedEntityDirection = loopIntValueWithinRangeFrom0(Utils.RoundNumberToDecimalPlaces(placedEntityOrientation * 8, 0), 7)
    local locoDistance = (StaticData.mu_placement.joint_distance / 2) - (StaticData.mu_locomotive.joint_distance / 2)
    local forwardLocoOrientation = placedEntityOrientation
    local forwardLocoPosition = Utils.GetPositionForAngledDistance(placedEntityPosition, locoDistance, forwardLocoOrientation * 360)
    local forwardLocoDirection = placedEntityDirection
    local rearLocoOrientation = placedEntityOrientation - 0.5
    local rearLocoPosition = Utils.GetPositionForAngledDistance(placedEntityPosition, locoDistance, rearLocoOrientation * 360)
    local rearLocoDirection = loopIntValueWithinRangeFrom0(placedEntityDirection + 4, 7)
    local middleCargoDirection = placedEntityDirection
    local middleCargoPosition = placedEntityPosition

    entity.destroy()
    local forwardLoco = Entity.PlaceWagon(StaticData.mu_locomotive.name, forwardLocoPosition, surface, force, forwardLocoDirection)
    if forwardLoco == nil then
        Logging.LogPrint("WARNING: " .. "failed placing forward loco", writeAllWarnings)
        if event.replaced ~= nil and event.replaced then
            Logging.LogPrint("ERROR: " .. "failed placing forward loco for second orientation, so giving up")
            return
        end
        Entity.PlaceOrionalLocoBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection)
        return
    end

    local middleCargo = Entity.PlaceWagon(StaticData.mu_cargo_wagon.name, middleCargoPosition, surface, force, middleCargoDirection)
    if middleCargo == nil then
        Logging.LogPrint("WARNING: " .. "failed placing middle cargo wagon", writeAllWarnings)
        forwardLoco.destroy()
        if event.replaced ~= nil and event.replaced then
            Logging.LogPrint("ERROR: " .. "failed placing middle cargo wagon for second orientation, so giving up")
            return
        end
        Entity.PlaceOrionalLocoBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection)
        return
    end

    local rearLoco = Entity.PlaceWagon(StaticData.mu_locomotive.name, rearLocoPosition, surface, force, rearLocoDirection)
    if rearLoco == nil then
        Logging.LogPrint("WARNING: " .. "failed placing rear loco", writeAllWarnings)
        forwardLoco.destroy()
        middleCargo.destroy()
        if event.replaced ~= nil and event.replaced then
            Logging.LogPrint("ERROR: " .. "failed placing rear loco for second orientation, so giving up")
            return
        end
        Entity.PlaceOrionalLocoBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection)
        return
    end

    for _, wagon in pairs({forwardLoco, middleCargo, rearLoco}) do
        if wagon == nil then
            return
        end
        wagon.connect_rolling_stock(defines.rail_direction.front)
        wagon.connect_rolling_stock(defines.rail_direction.back)
    end
end

return Entity
