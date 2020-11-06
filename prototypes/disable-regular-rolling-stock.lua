local Utils = require("utility/utils")

if not settings.startup["single_train_unit-disable_regular_rollingstock"].value then
    return
end

local HideRollingStockType = function(type)
    for _, entityPrototype in pairs(data.raw[type]) do
        if string.find(entityPrototype.name, "single_train_unit") == nil then
            Utils.RemoveEntitiesRecipesFromTechnologies(entityPrototype, data.raw.recipe, data.raw.technology)
        end
    end
end

HideRollingStockType("locomotive")
HideRollingStockType("cargo-wagon")
HideRollingStockType("fluid-wagon")
