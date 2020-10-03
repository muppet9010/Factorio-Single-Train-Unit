local Utils = require("utility/utils")
local StaticData = require("static-data")

if not mods["FactorioExtended-Trains"] then
    return
end

local weightMultiplier = settings.startup["single_train_unit-weight_percentage"].value / 100
local cargoCapacityMultiplier = settings.startup["single_train_unit-wagon_capacity_percentage"].value / 100

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
            max_health = 1500,
            max_speed = 1.5
        },
        ["cargo-loco"] = {
            reversing_power_modifier = 0.8,
            braking_force = 15,
            max_power = "800kW",
            weight = 2250 * weightMultiplier
        },
        ["cargo-wagon"] = {
            inventory_size = 80 * cargoCapacityMultiplier,
            weight = 1200 * weightMultiplier
        },
        ["cargo-placement"] = {
            prototypeAttributes = {},
            recipe = {
                {StaticData.MakeName({locoConfiguration = "double_end", unitType = "cargo", type = "placement"}), 1},
                {"electric-engine-unit", 20},
                {"advanced-circuit", 20},
                {"stainless-steel", 30},
                {"iron-gear-wheel", 20}
            },
            unlockTech = "stainless-steel-trains"
        },
        ["fluid-loco"] = {
            reversing_power_modifier = 0.8,
            braking_force = 15,
            max_power = "800kW",
            weight = 2250 * weightMultiplier
        },
        ["fluid-wagon"] = {
            capacity = 50000 * cargoCapacityMultiplier,
            weight = 1200 * weightMultiplier
        },
        ["fluid-placement"] = {
            prototypeAttributes = {},
            recipe = {
                {StaticData.MakeName({locoConfiguration = "double_end", unitType = "fluid", type = "placement"}), 1},
                {"electric-engine-unit", 20},
                {"advanced-circuit", 20},
                {"stainless-steel", 30},
                {"pipe-1", 4},
                {"storage-tank-1", 1}
            },
            unlockTech = "stainless-steel-trains"
        }
    },
    mk2 = {
        ["generic"] = {
            color = {r = 0, g = 0.68, b = 0.08, a = 0.8},
            max_health = 2000,
            max_speed = 2
        },
        ["cargo-loco"] = {
            reversing_power_modifier = 1,
            braking_force = 20,
            max_power = "1.0MW",
            weight = 2500 * weightMultiplier
        },
        ["cargo-wagon"] = {
            inventory_size = 160 * cargoCapacityMultiplier,
            weight = 1400 * weightMultiplier
        },
        ["cargo-placement"] = {
            prototypeAttributes = {},
            recipe = {
                {MakeMkName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "cargo", type = "placement"}), "mk1"), 2},
                {"electric-engine-unit", 20},
                {"advanced-circuit", 20},
                {"titanium-rod", 30},
                {"iron-gear-wheel", 20}
            },
            unlockTech = "titanium-trains"
        },
        ["fluid-loco"] = {
            reversing_power_modifier = 1,
            braking_force = 20,
            max_power = "1.0MW",
            weight = 2500 * weightMultiplier
        },
        ["fluid-wagon"] = {
            capacity = 75000 * cargoCapacityMultiplier,
            weight = 1400 * weightMultiplier
        },
        ["fluid-placement"] = {
            prototypeAttributes = {},
            recipe = {
                {MakeMkName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "fluid", type = "placement"}), "mk1"), 2},
                {"electric-engine-unit", 20},
                {"advanced-circuit", 20},
                {"titanium-rod", 30},
                {"pipe-2", 4},
                {"storage-tank-2", 1}
            },
            unlockTech = "titanium-trains"
        }
    },
    mk3 = {
        ["generic"] = {
            color = {r = 0.49, g = 0.10, b = 0.76, a = 0.8},
            max_health = 2500,
            max_speed = 2.5
        },
        ["cargo-loco"] = {
            reversing_power_modifier = 1.4,
            braking_force = 25,
            max_power = "1.2MW",
            weight = 3000 * weightMultiplier
        },
        ["cargo-wagon"] = {
            inventory_size = 320 * cargoCapacityMultiplier,
            weight = 1600 * weightMultiplier
        },
        ["cargo-placement"] = {
            prototypeAttributes = {},
            recipe = {
                {MakeMkName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "cargo", type = "placement"}), "mk2"), 2},
                {"electric-engine-unit", 20},
                {"advanced-circuit", 20},
                {"graphene", 30},
                {"iron-gear-wheel", 20}
            },
            unlockTech = "graphene-trains"
        },
        ["fluid-loco"] = {
            reversing_power_modifier = 1.4,
            braking_force = 25,
            max_power = "1.2MW",
            weight = 3000 * weightMultiplier
        },
        ["fluid-wagon"] = {
            capacity = 100000 * cargoCapacityMultiplier,
            weight = 1600 * weightMultiplier
        },
        ["fluid-placement"] = {
            prototypeAttributes = {},
            recipe = {
                {MakeMkName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "fluid", type = "placement"}), "mk2"), 2},
                {"electric-engine-unit", 20},
                {"advanced-circuit", 20},
                {"graphene", 30},
                {"pipe-3", 4},
                {"storage-tank-3", 1}
            },
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
