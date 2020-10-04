local Utils = require("utility/utils")
local StaticData = require("static-data")
local SharedFunctions = require("prototypes.shared-functions")

if not mods["FactorioExtended-Plus-Transport"] then
    return
end

local mk2LocoRefPrototype = data.raw["locomotive"]["locomotive-mk2"]
local mk3LocoRefPrototype = data.raw["locomotive"]["locomotive-mk3"]
local mk2CargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon-mk2"]
local mk3CargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon-mk3"]
local mk2FluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon-mk2"]
local mk3FluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon-mk3"]
local mk2LocoRefRecipe = data.raw["recipe"]["locomotive-mk2"]
local mk3LocoRefRecipe = data.raw["recipe"]["locomotive-mk3"]
local mk2CargoRefRecipe = data.raw["recipe"]["cargo-wagon-mk2"]
local mk3CargoRefRecipe = data.raw["recipe"]["cargo-wagon-mk3"]
local mk2FluidRefRecipe = data.raw["recipe"]["fluid-wagon-mk2"]
local mk3FluidRefRecipe = data.raw["recipe"]["fluid-wagon-mk3"]

--[[
    A lot of the values for the entity changes, graphics colors and item ordering is taken from the integratin mod at time of creation.
]]
local MakeMkName = function(name, identifier)
    return name .. "-factorio_extended_plus_transport-" .. identifier
end

local improvementTiers = {
    mk2 = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk2LocoRefPrototype, {color = {r = 0.4, g = 0.804, b = 0.667, a = 0.8}}),
        ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk2LocoRefPrototype),
        ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(mk2CargoRefPrototype),
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
                        mk2LocoRefRecipe,
                        "add",
                        2
                    },
                    {
                        mk2CargoRefRecipe,
                        "highest",
                        2
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
            unlockTech = "railway-2"
        },
        ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk2LocoRefPrototype),
        ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(mk2FluidRefPrototype),
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
                        mk2LocoRefRecipe,
                        "add",
                        2
                    },
                    {
                        mk2FluidRefRecipe,
                        "highest",
                        2
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
            unlockTech = "railway-2"
        }
    },
    mk3 = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk3LocoRefPrototype, {color = {r = 0.690, g = 0.75, b = 1, a = 0.8}}),
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
                        2
                    },
                    {
                        {
                            {"locomotive-mk2", 10},
                            {"cargo-wagon-mk2", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            unlockTech = "railway-3"
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
                        2
                    },
                    {
                        {
                            {"locomotive-mk2", 10},
                            {"fluid-wagon-mk2", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            unlockTech = "railway-3"
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
                itemVariant.subgroup = "fb-vehicle"
                itemVariant.order = "j" .. itemVariant.order .. "-" .. mk
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
