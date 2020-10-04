local Utils = require("utility/utils")
local StaticData = require("static-data")

if not mods["FactorioExtended-Trains"] then
    return
end

local weightMultiplier = settings.startup["single_train_unit-weight_percentage"].value / 100
local cargoCapacityMultiplier = settings.startup["single_train_unit-wagon_capacity_percentage"].value / 100

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
local MakeMkName = function(name, mk)
    return name .. "-factorio_extended_trains-" .. mk
end

local improvementTiers = {
    mk1 = {
        ["generic"] = {
            color = {r = 0.72, g = 0.31, b = 0.02, a = 0.8},
            max_health = mk1LocoRefPrototype.max_health,
            max_speed = mk1LocoRefPrototype.max_speed
        },
        ["cargo-loco"] = {
            reversing_power_modifier = mk1LocoRefPrototype.reversing_power_modifier,
            braking_force = mk1LocoRefPrototype.braking_force,
            max_power = mk1LocoRefPrototype.max_power,
            weight = mk1LocoRefPrototype.weight * weightMultiplier
        },
        ["cargo-wagon"] = {
            inventory_size = mk1CargoRefPrototype.inventory_size * cargoCapacityMultiplier,
            weight = mk1CargoRefPrototype.weight * weightMultiplier
        },
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
        ["fluid-loco"] = {
            reversing_power_modifier = mk1LocoRefPrototype.reversing_power_modifier,
            braking_force = mk1LocoRefPrototype.braking_force,
            max_power = mk1LocoRefPrototype.max_power,
            weight = mk1LocoRefPrototype.weight * weightMultiplier
        },
        ["fluid-wagon"] = {
            capacity = mk1FluidRefPrototype.capacity * cargoCapacityMultiplier,
            weight = mk1FluidRefPrototype.weight * weightMultiplier
        },
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
        ["generic"] = {
            color = {r = 0, g = 0.68, b = 0.08, a = 0.8},
            max_health = mk2LocoRefPrototype.max_health,
            max_speed = mk2LocoRefPrototype.max_speed
        },
        ["cargo-loco"] = {
            reversing_power_modifier = mk2LocoRefPrototype.reversing_power_modifier,
            braking_force = mk2LocoRefPrototype.braking_force,
            max_power = mk2LocoRefPrototype.max_power,
            weight = mk2LocoRefPrototype.weight * weightMultiplier
        },
        ["cargo-wagon"] = {
            inventory_size = mk2CargoRefPrototype.inventory_size * cargoCapacityMultiplier,
            weight = mk2CargoRefPrototype.weight * weightMultiplier
        },
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
        ["fluid-loco"] = {
            reversing_power_modifier = mk2LocoRefPrototype.reversing_power_modifier,
            braking_force = mk2LocoRefPrototype.braking_force,
            max_power = mk2LocoRefPrototype.max_power,
            weight = mk2LocoRefPrototype.weight * weightMultiplier
        },
        ["fluid-wagon"] = {
            capacity = mk2FluidRefPrototype.capacity * cargoCapacityMultiplier,
            weight = mk2FluidRefPrototype.weight * weightMultiplier
        },
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
        ["generic"] = {
            color = {r = 0.49, g = 0.10, b = 0.76, a = 0.8},
            max_health = mk3LocoRefPrototype.max_health,
            max_speed = mk3LocoRefPrototype.max_speed
        },
        ["cargo-loco"] = {
            reversing_power_modifier = mk3LocoRefPrototype.reversing_power_modifier,
            braking_force = mk3LocoRefPrototype.braking_force,
            max_power = mk3LocoRefPrototype.max_power,
            weight = mk3LocoRefPrototype.weight * weightMultiplier
        },
        ["cargo-wagon"] = {
            inventory_size = mk3CargoRefPrototype.inventory_size * cargoCapacityMultiplier,
            weight = mk3CargoRefPrototype.weight * weightMultiplier
        },
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
        ["fluid-loco"] = {
            reversing_power_modifier = mk3LocoRefPrototype.reversing_power_modifier,
            braking_force = mk3LocoRefPrototype.braking_force,
            max_power = mk3LocoRefPrototype.max_power,
            weight = mk3LocoRefPrototype.weight * weightMultiplier
        },
        ["fluid-wagon"] = {
            capacity = mk3FluidRefPrototype.capacity * cargoCapacityMultiplier,
            weight = mk3FluidRefPrototype.weight * weightMultiplier
        },
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
