local Entity = require("scripts/entity")
local DisableRegularRollingStock = require("scripts/disable-regular-rolling-stock")

local function CreateGlobals()
    Entity.CreateGlobals()
end

local function OnLoad()
    --Any Remote Interface registration calls can go in here or in root of control.lua
    Entity.OnLoad()
end

local function OnSettingChanged()
end

local function OnStartup(event)
    CreateGlobals()
    OnLoad()
    OnSettingChanged(nil)

    Entity.OnStartup(event)
    DisableRegularRollingStock.OnStartup(event)
end

script.on_init(OnStartup)
script.on_configuration_changed(OnStartup)
script.on_event(defines.events.on_runtime_mod_setting_changed, OnSettingChanged)
script.on_load(OnLoad)
