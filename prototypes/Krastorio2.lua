local Utils = require("utility/utils")
local StaticData = require("static-data")
local SharedFunctions = require("prototypes.shared-functions")

if not mods["Krastorio2"] then
    return
end
if data.raw["locomotive"]["kr-nuclear-locomotive"] == nil then
    return -- added locos are optional from the look of it.
end

local nuclearLocoRefPrototype = data.raw["locomotive"]["kr-nuclear-locomotive"]
local nuclearLocoRefRecipe = data.raw["recipe"]["kr-nuclear-locomotive"]
local refCargoWagonPrototype = data.raw["cargo-wagon"]["cargo-wagon"]
local refCargoWagonRecipe = data.raw["recipe"]["cargo-wagon"]
local refFluidWagonPrototype = data.raw["fluid-wagon"]["fluid-wagon"]
local refFluidWagonRecipe = data.raw["recipe"]["fluid-wagon"]

--[[
    A lot of the values for the entity changes, graphics colors and item ordering is taken from the integratin mod at time of creation.
]]
local MakeMkName = function(name, identifier)
    return name .. "-krastorio2-" .. identifier
end

local locoBurnerEffectivityMultiplier = settings.startup["single_train_unit-burner_effectivity_percentage"].value / 100

local improvementTiers = {
    nuclear = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(nuclearLocoRefPrototype, {color = {r = 60, g = 170, b = 25, a = 204}}),
        ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(
            nuclearLocoRefPrototype,
            {
                burner = {
                    fuel_category = nuclearLocoRefPrototype.burner.fuel_category,
                    effectivity = nuclearLocoRefPrototype.burner.effectivity * locoBurnerEffectivityMultiplier,
                    fuel_inventory_size = nuclearLocoRefPrototype.burner.fuel_inventory_size,
                    burnt_inventory_size = nuclearLocoRefPrototype.burner.burnt_inventory_size,
                    smoke = nuclearLocoRefPrototype.burner.smoke
                }
            }
        ),
        ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(refCargoWagonPrototype),
        ["cargo-placement"] = {
            prototypeAttributes = {},
            recipe = Utils.GetRecipeIngredientsAddedTogeather(
                {
                    {
                        {
                            {StaticData.MakeName({locoConfiguration = "double_end", unitType = "cargo", type = "placement"}), 1}
                        },
                        "add",
                        1
                    },
                    {
                        nuclearLocoRefRecipe,
                        "add",
                        2
                    },
                    {
                        refCargoWagonRecipe,
                        "highest",
                        1
                    },
                    {
                        {
                            {"locomotive", 10},
                            {"cargo-wagon", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            unlockTech = "kr-nuclear-locomotive"
        },
        ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(
            nuclearLocoRefPrototype,
            {
                burner = {
                    fuel_category = nuclearLocoRefPrototype.burner.fuel_category,
                    effectivity = nuclearLocoRefPrototype.burner.effectivity * locoBurnerEffectivityMultiplier,
                    fuel_inventory_size = nuclearLocoRefPrototype.burner.fuel_inventory_size,
                    burnt_inventory_size = nuclearLocoRefPrototype.burner.burnt_inventory_size,
                    smoke = nuclearLocoRefPrototype.burner.smoke
                }
            }
        ),
        ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(refFluidWagonPrototype),
        ["fluid-placement"] = {
            prototypeAttributes = {},
            recipe = Utils.GetRecipeIngredientsAddedTogeather(
                {
                    {
                        {
                            {StaticData.MakeName({locoConfiguration = "double_end", unitType = "fluid", type = "placement"}), 1}
                        },
                        "add",
                        1
                    },
                    {
                        nuclearLocoRefRecipe,
                        "add",
                        2
                    },
                    {
                        refFluidWagonRecipe,
                        "highest",
                        1
                    },
                    {
                        {
                            {"locomotive", 10},
                            {"fluid-wagon", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            unlockTech = "kr-nuclear-locomotive"
        }
    }
}

for identifier, improvementDetails in pairs(improvementTiers) do
    for baseName, baseStaticData in pairs(StaticData.entityNames) do
        local improvementTierName = baseStaticData.unitType .. "-" .. baseStaticData.type
        if baseStaticData.type == "placement" then
            if improvementDetails[improvementTierName] ~= nil then
                local placementDetails = improvementDetails[improvementTierName]
                local entityVariant = Utils.DeepCopy(data.raw["locomotive"][baseName])
                entityVariant.name = MakeMkName(entityVariant.name, identifier)
                for key, value in pairs(improvementDetails.generic) do
                    entityVariant[key] = value
                end
                for key, value in pairs(improvementDetails[baseStaticData.unitType .. "-loco"]) do
                    entityVariant[key] = value
                end
                entityVariant.weight = (improvementDetails[baseStaticData.unitType .. "-loco"].weight * 2) + improvementDetails[baseStaticData.unitType .. "-wagon"].weight
                if placementDetails.prototypeAttributes ~= nil then
                    for key, value in pairs(placementDetails.prototypeAttributes) do
                        entityVariant[key] = value
                    end
                end
                entityVariant.pictures.layers[1].tint = improvementDetails.generic.color
                entityVariant.icons[1].tint = improvementDetails.generic.color
                data:extend({entityVariant})

                local itemVariant = Utils.DeepCopy(data.raw["item-with-entity-data"][baseName])
                itemVariant.name = entityVariant.name
                itemVariant.place_result = entityVariant.name
                itemVariant.icons[1].tint = improvementDetails.generic.color
                itemVariant.subgroup = "transport"
                itemVariant.order = "a[train-system]-f[nuclear-locomotive.png]" .. itemVariant.order .. "-" .. identifier
                data:extend({itemVariant})

                local recipeVariant = Utils.DeepCopy(data.raw["recipe"][baseName])
                recipeVariant.name = entityVariant.name
                if placementDetails.recipe.ingredients ~= nil then
                    recipeVariant.result = entityVariant.name
                    recipeVariant.ingredients = placementDetails.recipe.ingredients
                end
                if placementDetails.recipe.normal ~= nil then
                    recipeVariant.normal = {
                        result = entityVariant.name,
                        ingredients = placementDetails.recipe.normal
                    }
                end
                if placementDetails.recipe.expensive ~= nil then
                    recipeVariant.expensive = {
                        result = entityVariant.name,
                        ingredients = placementDetails.recipe.expensive
                    }
                end
                data:extend({recipeVariant})
                table.insert(data.raw["technology"][placementDetails.unlockTech].effects, {type = "unlock-recipe", recipe = entityVariant.name})
            end
        else
            if improvementDetails[improvementTierName] ~= nil then
                local placementName = MakeMkName(baseStaticData.placementStaticData.name, identifier)
                local entityVariant = Utils.DeepCopy(data.raw[baseStaticData.prototypeType][baseName])
                entityVariant.name = MakeMkName(entityVariant.name, identifier)
                for key, value in pairs(improvementDetails.generic) do
                    entityVariant[key] = value
                end
                for key, value in pairs(improvementDetails[improvementTierName]) do
                    entityVariant[key] = value
                end
                if baseStaticData.type == "wagon" then
                    entityVariant.pictures.layers[1].tint = improvementDetails.generic.color
                    entityVariant.icons[1].tint = improvementDetails.generic.color
                    entityVariant.minable.result = placementName
                end
                entityVariant.localised_name = {"entity-name." .. placementName}
                entityVariant.placeable_by = {item = placementName, count = 1}
                data:extend({entityVariant})
            end
        end
    end
end
