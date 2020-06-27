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

local UpdateSetting = function(settingName)
    --if settingName == "xxxxx" or settingName == nil then
    --	local x = tonumber(settings.global["xxxxx"].value)
    --end
end

local CreateGlobals = function()
end

local OnLoad = function()
end

local OnStartup = function()
    CreateGlobals()
    OnLoad()
    UpdateSetting(nil)
end

local OnSettingChanged = function(event)
    UpdateSetting(event.setting)
end

local Control = {}

Control.PlaceWagon = function(prototypeName, position, surface, force, direction)
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
        Logging.LogPrint(prototypeName .. " failed to place at " .. Logging.PositionToString(position) .. " with direction: " .. direction, writeAllWarnings)
        return
    end
    return wagon
end

Control.PlaceOrionalLocoBack = function(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection)
    placedEntityDirection = loopIntValueWithinRangeFrom0(placedEntityDirection + 4, 7)
    local placedLoco = surface.create_entity {name = placedEntityName, position = placedEntityPosition, force = force, snap_to_train_stop = false, direction = placedEntityDirection}
    if placedLoco == nil then
        Logging.LogPrint("failed to placed origional " .. placedEntityName .. " back at " .. Logging.PositionToString(placedEntityPosition) .. " with new direction: " .. placedEntityDirection)
        return
    end
    Logging.LogPrint("placed origional " .. placedEntityName .. " back at " .. Logging.PositionToString(placedEntityPosition) .. " with new direction: " .. placedEntityDirection, writeAllWarnings)
    Control.OnBuiltEntity_MUPlacement({created_entity = placedLoco, replaced = true})
end

Control.OnBuiltEntity_MUPlacement = function(event)
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
    local forwardLoco = Control.PlaceWagon(StaticData.mu_locomotive.name, forwardLocoPosition, surface, force, forwardLocoDirection)
    if forwardLoco == nil then
        Logging.LogPrint("failed placing forward loco", writeAllWarnings)
        if event.replaced ~= nil and event.replaced then
            Logging.LogPrint("failed placing forward loco for second orientation, so giving up")
            return
        end
        Control.PlaceOrionalLocoBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection)
        return
    end

    local middleCargo = Control.PlaceWagon(StaticData.mu_cargo_wagon.name, middleCargoPosition, surface, force, middleCargoDirection)
    if middleCargo == nil then
        Logging.LogPrint("failed placing middle cargo wagon", writeAllWarnings)
        forwardLoco.destroy()
        if event.replaced ~= nil and event.replaced then
            Logging.LogPrint("failed placing middle cargo wagon for second orientation, so giving up")
            return
        end
        Control.PlaceOrionalLocoBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection)
        return
    end

    local rearLoco = Control.PlaceWagon(StaticData.mu_locomotive.name, rearLocoPosition, surface, force, rearLocoDirection)
    if rearLoco == nil then
        Logging.LogPrint("failed placing rear loco", writeAllWarnings)
        forwardLoco.destroy()
        middleCargo.destroy()
        if event.replaced ~= nil and event.replaced then
            Logging.LogPrint("failed placing rear loco for second orientation, so giving up")
            return
        end
        Control.PlaceOrionalLocoBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection)
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

script.on_init(OnStartup)
script.on_configuration_changed(OnStartup)
script.on_event(defines.events.on_runtime_mod_setting_changed, OnSettingChanged)
script.on_load(OnLoad)
script.on_event(defines.events.on_built_entity, Control.OnBuiltEntity_MUPlacement, {{filter = "name", name = StaticData.mu_placement.name}})
