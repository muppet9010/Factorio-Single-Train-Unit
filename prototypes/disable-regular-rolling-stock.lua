local Utils = require("utility/utils")

if not settings.startup["single_train_unit-disable_regular_rollingstock"].value then
    return
end

local DoesRecipeResultsIncludeItemName = function(recipePrototype, itemName)
    for _, recipeBase in pairs({recipePrototype, recipePrototype.normal, recipePrototype.expensive}) do
        if recipeBase ~= nil then
            if recipeBase.result ~= nil and recipeBase.result == itemName then
                return true
            elseif recipeBase.results ~= nil and Utils.GetTableKeyWithInnerKeyValue(recipeBase.results, "name", itemName) ~= nil then
                return true
            end
        end
    end
    return false
end

local RemovePrototypeFromTechnologies = function(entityPrototype)
    local placedByItemName
    if entityPrototype.minable ~= nil and entityPrototype.minable.result ~= nil then
        placedByItemName = entityPrototype.minable.result
    else
        return
    end
    for _, recipePrototype in pairs(data.raw.recipe) do
        if DoesRecipeResultsIncludeItemName(recipePrototype, placedByItemName) then
            recipePrototype.enabled = false
            for _, technologyPrototype in pairs(data.raw.technology) do
                if technologyPrototype.effects ~= nil then
                    for effectIndex, effect in pairs(technologyPrototype.effects) do
                        if effect.type == "unlock-recipe" and effect.recipe ~= nil and effect.recipe == recipePrototype.name then
                            table.remove(technologyPrototype.effects, effectIndex)
                        end
                    end
                end
            end
        end
    end
end

local HideRollingStockType = function(type)
    for _, entityPrototype in pairs(data.raw[type]) do
        if string.find(entityPrototype.name, "single_train_unit") == nil then
            RemovePrototypeFromTechnologies(entityPrototype)
        end
    end
end

HideRollingStockType("locomotive")
HideRollingStockType("cargo-wagon")
HideRollingStockType("fluid-wagon")
