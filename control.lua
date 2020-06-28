local StaticData = require("static-data")
local Entity = require("scripts/entity")

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

script.on_init(OnStartup)
script.on_configuration_changed(OnStartup)
script.on_event(defines.events.on_runtime_mod_setting_changed, OnSettingChanged)
script.on_load(OnLoad)
script.on_event(defines.events.on_built_entity, Entity.OnBuiltEntity_MUPlacement, {{filter = "name", name = StaticData.mu_placement.name}})
