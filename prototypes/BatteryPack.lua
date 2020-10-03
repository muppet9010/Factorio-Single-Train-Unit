local Utils = require("utility/utils")
local StaticData = require("static-data")

if not mods["BatteryPack"] then
    return
end

--[[
    The Battery Pack mod makes the placement entitiy as it is a placable entity recipe, but doesn't do the others. So use it as a template and make the missing bits.
]]
local staticDataPlacementNamePrefix = "BatteryPack-"
for _, placementPrototype in pairs(data.raw["locomotive"]) do
    if string.find(placementPrototype.name, staticDataPlacementNamePrefix .. "single_train_unit", 1, true) then
        local staticDataPlacementName, suffixStart = nil, 0
        for _, staticDataName in pairs({StaticData.DoubleEndCargoPlacement.name, StaticData.DoubleEndFluidPlacement.name}) do
            _, suffixStart = string.find(placementPrototype.name, staticDataName, 1, true)
            if suffixStart ~= nil then
                staticDataPlacementName = staticDataName
                suffixStart = suffixStart + 1
                break
            end
        end
        if staticDataPlacementName ~= nil then
            local staticDataPlacement = StaticData.entityNames[staticDataPlacementName]
            if staticDataPlacement ~= nil then
                local staticDataPlacementNameSuffix = string.sub(placementPrototype.name, suffixStart)
                local entityVariant

                for _, baseStaticData in pairs({staticDataPlacement.placedStaticDataLoco, staticDataPlacement.placedStaticDataWagon}) do
                    entityVariant = Utils.DeepCopy(data.raw[baseStaticData.prototypeType][baseStaticData.name])
                    entityVariant.name = staticDataPlacementNamePrefix .. entityVariant.name .. staticDataPlacementNameSuffix
                    if baseStaticData.type == "loco" then
                        entityVariant.burner = placementPrototype.burner
                        entityVariant.working_sound = placementPrototype.working_sound
                        entityVariant.sound_no_fuel = placementPrototype.sound_no_fuel
                    elseif baseStaticData.type == "wagon" then
                        entityVariant.minable.result = placementPrototype.name
                        entityVariant.icons = placementPrototype.icons
                    end
                    entityVariant.localised_name = placementPrototype.localised_name
                    entityVariant.placeable_by = {item = placementPrototype.name, count = 1}
                    data:extend({entityVariant})
                end
            end
        end
    end
end
