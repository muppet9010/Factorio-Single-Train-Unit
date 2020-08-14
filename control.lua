local StaticData = require("static-data")
local Entity = require("scripts/entity")

local function CreateGlobals()
    Entity.CreateGlobals()
end

local function OnLoad()
    --Any Remote Interface registration calls can go in here or in root of control.lua
end

local function OnSettingChanged(event)
    --if event == nil or event.setting == "xxxxx" then
    --	local x = tonumber(settings.global["xxxxx"].value)
    --end
end

local function OnStartup()
    CreateGlobals()
    OnLoad()
    OnSettingChanged(nil)
end

script.on_init(OnStartup)
script.on_configuration_changed(OnStartup)
script.on_event(defines.events.on_runtime_mod_setting_changed, OnSettingChanged)
script.on_load(OnLoad)
script.on_event(defines.events.on_built_entity, Entity.OnBuiltEntity_MUPlacement, {{filter = "name", name = StaticData.mu_placement.name}})
script.on_event(defines.events.on_train_created, Entity.OnTrainCreated)
script.on_event(defines.events.on_player_mined_entity, Entity.OnPlayerMined_MUWagon, {{filter = "name", name = StaticData.mu_locomotive.name}, {mode = "or", filter = "name", name = StaticData.mu_cargo_wagon.name}})
script.on_event(defines.events.on_pre_player_mined_item, Entity.OnPrePlayerMined_MUWagon, {{filter = "name", name = StaticData.mu_locomotive.name}, {mode = "or", filter = "name", name = StaticData.mu_cargo_wagon.name}})
script.on_event(defines.events.on_entity_damaged, Entity.OnEntityDamaged_MUWagon, {{filter = "name", name = StaticData.mu_locomotive.name}, {mode = "or", filter = "name", name = StaticData.mu_cargo_wagon.name}})
script.on_event(defines.events.on_entity_died, Entity.OnEntityDied_MUWagon, {{filter = "name", name = StaticData.mu_locomotive.name}, {mode = "or", filter = "name", name = StaticData.mu_cargo_wagon.name}})
