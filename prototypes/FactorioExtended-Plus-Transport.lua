local Utils = require("utility/utils")
local StaticData = require("static-data")

if not mods["FactorioExtended-Plus-Transport"] then
    return
end

local cargoCapacityMultiplier = settings.startup["single_train_unit-wagon_capacity_percentage"].value / 100

local mk2LocoRefPrototype = data.raw["locomotive"]["locomotive-mk2"]
local mk3LocoRefPrototype = data.raw["locomotive"]["locomotive-mk3"]
local mk2CargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon-mk2"]
local mk3CargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon-mk3"]
local mk2FluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon-mk2"]
local mk3FluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon-mk3"]
local mk2LocoRefRecipeIngredients = data.raw["recipe"]["locomotive-mk2"].ingredients
local mk3LocoRefRecipeIngredients = data.raw["recipe"]["locomotive-mk3"].ingredients
local mk2CargoRefRecipeIngredients = data.raw["recipe"]["cargo-wagon-mk2"].ingredients
local mk3CargoRefRecipeIngredients = data.raw["recipe"]["cargo-wagon-mk3"].ingredients
local mk2FluidRefRecipeIngredients = data.raw["recipe"]["fluid-wagon-mk2"].ingredients
local mk3FluidRefRecipeIngredients = data.raw["recipe"]["fluid-wagon-mk3"].ingredients

--[[
    A lot of the values for the entity changes, graphics colors and item ordering is taken from the integratin mod at time of creation.
]]
local MakeMkName = function(name, mk)
    return name .. "-factorio_extended_plus_transport-" .. mk
end

local improvementTiers = {
    mk2 = {
        ["generic"] = {
            color = {r = 0.4, g = 0.804, b = 0.667, a = 0.8},
            max_health = mk2LocoRefPrototype.max_health,
            max_speed = mk2LocoRefPrototype.max_speed,
            air_resistance = mk2LocoRefPrototype.air_resistance,
            equipment_grid = mk2LocoRefPrototype.equipment_grid
        },
        ["cargo-loco"] = {
            reversing_power_modifier = mk2LocoRefPrototype.reversing_power_modifier,
            braking_force = mk2LocoRefPrototype.braking_force
        },
        ["cargo-wagon"] = {
            inventory_size = mk2CargoRefPrototype.inventory_size * cargoCapacityMultiplier,
            friction_force = mk2CargoRefPrototype.friction_force
        },
        ["cargo-placement"] = {
            prototypeAttributes = {},
            recipe = Utils.GetIngredientsAddedTogeather(
                {
                    {
                        {
                            {StaticData.MakeName({locoConfiguration = "double_end", unitType = "cargo", type = "placement"}), 1}
                        },
                        "add",
                        1
                    },
                    {
                        mk2LocoRefRecipeIngredients,
                        "add",
                        2
                    },
                    {
                        mk2CargoRefRecipeIngredients,
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
            unlockTech = "railway-2"
        },
        ["fluid-loco"] = {
            reversing_power_modifier = mk2LocoRefPrototype.reversing_power_modifier,
            braking_force = mk2LocoRefPrototype.braking_force
        },
        ["fluid-wagon"] = {
            capacity = mk2FluidRefPrototype.capacity * cargoCapacityMultiplier,
            friction_force = mk2FluidRefPrototype.friction_force
        },
        ["fluid-placement"] = {
            prototypeAttributes = {},
            recipe = Utils.GetIngredientsAddedTogeather(
                {
                    {
                        {
                            {StaticData.MakeName({locoConfiguration = "double_end", unitType = "fluid", type = "placement"}), 1}
                        },
                        "add",
                        1
                    },
                    {
                        mk2LocoRefRecipeIngredients,
                        "add",
                        2
                    },
                    {
                        mk2FluidRefRecipeIngredients,
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
            unlockTech = "railway-2"
        }
    },
    mk3 = {
        ["generic"] = {
            color = {r = 0.690, g = 0.75, b = 1},
            max_health = mk3LocoRefPrototype.max_health,
            max_speed = mk3LocoRefPrototype.max_speed,
            air_resistance = mk3LocoRefPrototype.air_resistance,
            equipment_grid = mk3LocoRefPrototype.equipment_grid
        },
        ["cargo-loco"] = {
            reversing_power_modifier = mk3LocoRefPrototype.reversing_power_modifier,
            braking_force = mk3LocoRefPrototype.braking_force
        },
        ["cargo-wagon"] = {
            inventory_size = mk3CargoRefPrototype.inventory_size * cargoCapacityMultiplier,
            friction_force = mk3CargoRefPrototype.friction_force
        },
        ["cargo-placement"] = {
            prototypeAttributes = {},
            recipe = Utils.GetIngredientsAddedTogeather(
                {
                    {
                        {
                            {MakeMkName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "cargo", type = "placement"}), "mk2"), 1}
                        },
                        "add",
                        1
                    },
                    {
                        mk3LocoRefRecipeIngredients,
                        "add",
                        2
                    },
                    {
                        mk3CargoRefRecipeIngredients,
                        "highest",
                        1
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
        ["fluid-loco"] = {
            reversing_power_modifier = mk3LocoRefPrototype.reversing_power_modifier,
            braking_force = mk3LocoRefPrototype.braking_force
        },
        ["fluid-wagon"] = {
            capacity = mk3FluidRefPrototype.capacity * cargoCapacityMultiplier,
            friction_force = mk3FluidRefPrototype.friction_force
        },
        ["fluid-placement"] = {
            prototypeAttributes = {},
            recipe = Utils.GetIngredientsAddedTogeather(
                {
                    {
                        {
                            {MakeMkName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "fluid", type = "placement"}), "mk2"), 1}
                        },
                        "add",
                        1
                    },
                    {
                        mk3LocoRefRecipeIngredients,
                        "add",
                        2
                    },
                    {
                        mk3FluidRefRecipeIngredients,
                        "highest",
                        1
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
                recipeVariant.ingredients = placementDetails.recipe
                recipeVariant.result = entityVariant.name
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
