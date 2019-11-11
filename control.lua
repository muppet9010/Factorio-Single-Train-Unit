local Utils = require("utility/utils")
local Logging = require("utility/logging")
local StaticData = require("static-data")

local function UpdateSetting(settingName)
    --if settingName == "xxxxx" or settingName == nil then
    --	local x = tonumber(settings.global["xxxxx"].value)
    --end
end

local function CreateGlobals()
end

local function OnLoad()
end

local function OnStartup()
    CreateGlobals()
    OnLoad()
    UpdateSetting(nil)
end

local function OnSettingChanged(event)
    UpdateSetting(event.setting)
end

local function PlaceWagon(prototypeName, position, surface, force, orientation)
    rendering.draw_circle {
        color = {r = 0, g = 0, b = 1},
        radius = 0.1,
        filled = true,
        target = position,
        surface = surface
    }
    local wagon = surface.create_entity {name = prototypeName, position = position, force = force, snap_to_train_stop = false}
    if wagon == nil then
        Logging.LogPrint(prototypeName .. " failed to place at " .. Logging.PositionToString(position) .. " with orientation: " .. orientation)
        return
    end
    local orientationDiff = orientation - wagon.orientation
    if orientationDiff > 0.25 or orientationDiff < -0.25 then
        wagon.disconnect_rolling_stock(defines.rail_direction.front)
        wagon.disconnect_rolling_stock(defines.rail_direction.back)
        wagon.rotate()
    end
    return wagon
end

local function OnBuiltEntity_MUPlacement(event)
    local entity = event.created_entity
    local surface = entity.surface
    local force = entity.force
    local locoDistance = (StaticData.mu_placement.joint_distance / 2) - (StaticData.mu_locomotive.joint_distance / 2)
    local forwardLocoOrientation = entity.orientation
    local forwardLocoPosition = Utils.GetPositionForAngledDistance(entity.position, locoDistance, forwardLocoOrientation * 360)
    local rearLocoOrientation = entity.orientation - 0.5
    local rearLocoPosition = Utils.GetPositionForAngledDistance(entity.position, locoDistance, rearLocoOrientation * 360)
    local middleCargoOrientation = entity.orientation
    local middleCargoPosition = entity.position

    entity.destroy()
    local forwardLoco = PlaceWagon(StaticData.mu_locomotive.name, forwardLocoPosition, surface, force, forwardLocoOrientation)
    local rearLoco = PlaceWagon(StaticData.mu_locomotive.name, rearLocoPosition, surface, force, rearLocoOrientation)
    local middleCargo = PlaceWagon(StaticData.mu_cargo_wagon.name, middleCargoPosition, surface, force, middleCargoOrientation)
    for _, wagon in pairs({forwardLoco, rearLoco, middleCargo}) do
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
script.on_event(defines.events.on_built_entity, OnBuiltEntity_MUPlacement, {{filter = "name", name = StaticData.mu_placement.name}})
