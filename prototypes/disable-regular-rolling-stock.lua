local Utils = require("utility/utils")

if not settings.startup["single_train_unit-disable_regular_rollingstock"].value then
    return
end

local whitelistSetting = Utils.SplitStringOnCharacters(settings.startup["single_train_unit-disable_regular_rollingstock_whitelist"].value, ",", true)
local vehicleWagonList = {["vehicle-wagon"] = true, ["loaded-vehicle-wagon-car"] = true, ["loaded-vehicle-wagon-tarp"] = true, ["loaded-vehicle-wagon-tank"] = true, ["loaded-vehicle-wagon-tank-H"] = true, ["loaded-vehicle-wagon-tank-L"] = true}
local entityNameWhitelist = Utils.TableMerge({whitelistSetting, vehicleWagonList})

if mods["space-exploration"] ~= nil then
    -- Space Exploration needs an item type locomotive for science. So if its not going to be available, make an item only version be.
    if entityNameWhitelist["locomotive"] == nil then
        entityNameWhitelist["locomotive"] = true
        data.raw["item-with-entity-data"]["locomotive"].place_result = nil
        data.raw["item-with-entity-data"]["locomotive"].localised_name = {"entity-name.locomotive"}
        data.raw["item-with-entity-data"]["locomotive"].localised_description = {"item-description.single_train_unit-non_placeable_locomotive"}
    end
end

local HideRollingStockType = function(type)
    for _, entityPrototype in pairs(data.raw[type]) do
        if string.find(entityPrototype.name, "single_train_unit") == nil and entityNameWhitelist[entityPrototype.name] ~= true then
            Utils.RemoveEntitiesRecipesFromTechnologies(entityPrototype, data.raw.recipe, data.raw.technology)
        end
    end
end

HideRollingStockType("locomotive")
HideRollingStockType("cargo-wagon")
HideRollingStockType("fluid-wagon")
