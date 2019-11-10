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
    local wagon = surface.create_entity {name = prototypeName, position = position, force = force}
    if wagon == nil then
        Logging.LogPrint(prototypeName .. " failed to place at " .. Logging.PositionToString(position) .. " with orientation: " .. orientation)
        return
    end
    local orientationDiff = orientation - wagon.orientation
    if orientationDiff > 0.25 or orientationDiff < -0.25 then
        wagon.rotate()
    end
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
    local cargoOrientation = entity.orientation
    local cargoPosition = entity.position
    entity.destroy()
    PlaceWagon(StaticData.mu_locomotive.name, forwardLocoPosition, surface, force, forwardLocoOrientation)
    PlaceWagon(StaticData.mu_locomotive.name, rearLocoPosition, surface, force, rearLocoOrientation)
    PlaceWagon(StaticData.mu_cargo_wagon.name, cargoPosition, surface, force, cargoOrientation)
end

script.on_init(OnStartup)
script.on_configuration_changed(OnStartup)
script.on_event(defines.events.on_runtime_mod_setting_changed, OnSettingChanged)
script.on_load(OnLoad)
script.on_event(defines.events.on_built_entity, OnBuiltEntity_MUPlacement, {{filter = "name", name = StaticData.mu_placement.name}})
