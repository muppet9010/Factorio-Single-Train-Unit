local Utils = require("utility/utils")
local StaticData = require("static-data")
local SharedFunctions = require("prototypes.shared-functions")

if not mods["FactorioExtended-Trains"] then
    return
end

local mk1LocoRefPrototype = data.raw["locomotive"]["locomotive-1"]
local mk2LocoRefPrototype = data.raw["locomotive"]["locomotive-2"]
local mk3LocoRefPrototype = data.raw["locomotive"]["locomotive-3"]
local mk1CargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon-1"]
local mk2CargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon-2"]
local mk3CargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon-3"]
local mk1FluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon-1"]
local mk2FluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon-2"]
local mk3FluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon-3"]
local mk1LocoRefRecipe = data.raw["recipe"]["locomotive-1"]
local mk2LocoRefRecipe = data.raw["recipe"]["locomotive-2"]
local mk3LocoRefRecipe = data.raw["recipe"]["locomotive-3"]
local mk1CargoRefRecipe = data.raw["recipe"]["cargo-wagon-1"]
local mk2CargoRefRecipe = data.raw["recipe"]["cargo-wagon-2"]
local mk3CargoRefRecipe = data.raw["recipe"]["cargo-wagon-3"]
local mk1FluidRefRecipe = data.raw["recipe"]["fluid-wagon-1"]
local mk2FluidRefRecipe = data.raw["recipe"]["fluid-wagon-2"]
local mk3FluidRefRecipe = data.raw["recipe"]["fluid-wagon-3"]

--[[
    A lot of the values for the entity changes, graphics colors and item ordering is taken from the integratin mod at time of creation.
]]
local MakeMkName = function(name, identifier)
    return name .. "-factorio_extended_trains-" .. identifier
end

local improvementTiers = {
    mk1 = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk1LocoRefPrototype, {color = {r = 124, g = 17, b = 15, a = 204}}),
        ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk1LocoRefPrototype),
        ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(mk1CargoRefPrototype),
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
                        mk1LocoRefRecipe,
                        "add",
                        2
                    },
                    {
                        mk1CargoRefRecipe,
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
            unlockTech = "stainless-steel-trains"
        },
        ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk1LocoRefPrototype),
        ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(mk1FluidRefPrototype),
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
                        mk1LocoRefRecipe,
                        "add",
                        2
                    },
                    {
                        mk1FluidRefRecipe,
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
            unlockTech = "stainless-steel-trains"
        }
    },
    mk2 = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk2LocoRefPrototype, {color = {r = 12, g = 76, b = 22, a = 204}}),
        ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk2LocoRefPrototype),
        ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(mk2CargoRefPrototype),
        ["cargo-placement"] = {
            prototypeAttributes = {},
            recipe = Utils.GetRecipeIngredientsAddedTogeather(
                {
                    {
                        {
                            {MakeMkName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "cargo", type = "placement"}), "mk1"), 1}
                        },
                        "add",
                        1
                    },
                    {
                        mk2LocoRefRecipe,
                        "add",
                        2
                    },
                    {
                        mk2CargoRefRecipe,
                        "highest",
                        1
                    },
                    {
                        {
                            {"locomotive-1", 10},
                            {"cargo-wagon-1", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            unlockTech = "titanium-trains"
        },
        ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk2LocoRefPrototype),
        ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(mk2FluidRefPrototype),
        ["fluid-placement"] = {
            prototypeAttributes = {},
            recipe = Utils.GetRecipeIngredientsAddedTogeather(
                {
                    {
                        {
                            {MakeMkName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "fluid", type = "placement"}), "mk1"), 1}
                        },
                        "add",
                        1
                    },
                    {
                        mk2LocoRefRecipe,
                        "add",
                        2
                    },
                    {
                        mk2FluidRefRecipe,
                        "highest",
                        1
                    },
                    {
                        {
                            {"locomotive-1", 10},
                            {"fluid-wagon-1", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            unlockTech = "titanium-trains"
        }
    },
    mk3 = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk3LocoRefPrototype, {color = {r = 113, g = 22, b = 88, a = 204}}),
        ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk3LocoRefPrototype),
        ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(mk3CargoRefPrototype),
        ["cargo-placement"] = {
            prototypeAttributes = {},
            recipe = Utils.GetRecipeIngredientsAddedTogeather(
                {
                    {
                        {
                            {MakeMkName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "cargo", type = "placement"}), "mk2"), 1}
                        },
                        "add",
                        1
                    },
                    {
                        mk3LocoRefRecipe,
                        "add",
                        2
                    },
                    {
                        mk3CargoRefRecipe,
                        "highest",
                        1
                    },
                    {
                        {
                            {"locomotive-2", 10},
                            {"cargo-wagon-2", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            unlockTech = "graphene-trains"
        },
        ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk3LocoRefPrototype),
        ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(mk3FluidRefPrototype),
        ["fluid-placement"] = {
            prototypeAttributes = {},
            recipe = Utils.GetRecipeIngredientsAddedTogeather(
                {
                    {
                        {
                            {MakeMkName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "fluid", type = "placement"}), "mk2"), 1}
                        },
                        "add",
                        1
                    },
                    {
                        mk3LocoRefRecipe,
                        "add",
                        2
                    },
                    {
                        mk3FluidRefRecipe,
                        "highest",
                        1
                    },
                    {
                        {
                            {"locomotive-2", 10},
                            {"fluid-wagon-2", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            unlockTech = "graphene-trains"
        }
    }
}

for mk, improvementDetails in pairs(improvementTiers) do
    for baseName, baseStaticData in pairs(StaticData.entityNames) do
        local improvementTierName = baseStaticData.unitType .. "-" .. baseStaticData.type
        if baseStaticData.type == "placement" then
            if improvementDetails[improvementTierName] ~= nil then
                local placementDetails = improvementDetails[improvementTierName]
                local entityVariant = Utils.DeepCopy(data.raw["locomotive"][baseName])
                entityVariant.name = MakeMkName(entityVariant.name, mk)
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
                itemVariant.subgroup = "fb-trains"
                itemVariant.order = "a-c" .. itemVariant.order .. "-" .. mk
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
                local placementName = MakeMkName(baseStaticData.placementStaticData.name, mk)
                local entityVariant = Utils.DeepCopy(data.raw[baseStaticData.prototypeType][baseName])
                entityVariant.name = MakeMkName(entityVariant.name, mk)
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
