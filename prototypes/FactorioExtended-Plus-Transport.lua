local Utils = require("utility/utils")
local StaticData = require("static-data")

if not mods["FactorioExtended-Plus-Transport"] then
    return
end

--[[
    A lot of the values for the entity changes, graphics colors and item ordering is taken from the integratin mod at time of creation.
]]
local MakeMkName = function(name, mk)
    return name .. "-factorio_extended_plus-" .. mk
end

local improvementTiers = {
    mk2 = {
        ["generic"] = {
            color = {r = 0.4, g = 0.804, b = 0.667, a = 0.8},
            max_health = 2000,
            max_speed = 1.6,
            air_resistance = 0.005
        },
        ["cargo-loco"] = {
            reversing_power_modifier = 0.8,
            braking_force = 15
        },
        ["cargo-wagon"] = {
            inventory_size = 60 / 2,
            friction_force = 0.25,
            equipment_grid = "car-medium-equipment-grid"
        },
        ["cargo-placement"] = {
            prototypeAttributes = {
                equipment_grid = "car-medium-equipment-grid"
            },
            recipe = {
                {StaticData.MakeName({locoConfiguration = "double_end", unitType = "cargo", type = "placement"}), 2},
                {"advanced-circuit", 20},
                {"steel-plate", 50},
                {"iron-plate", 25}
            },
            unlockTech = "railway-2"
        },
        ["fluid-loco"] = {
            reversing_power_modifier = 0.8,
            braking_force = 15
        },
        ["fluid-wagon"] = {
            capacity = 75000 / 2,
            equipment_grid = "car-medium-equipment-grid"
        },
        ["fluid-placement"] = {
            prototypeAttributes = {
                equipment_grid = "car-medium-equipment-grid"
            },
            recipe = {
                {StaticData.MakeName({locoConfiguration = "double_end", unitType = "fluid", type = "placement"}), 2},
                {"advanced-circuit", 20},
                {"steel-plate", 100},
                {"pipe-mk2", 4}
            },
            unlockTech = "railway-2"
        }
    },
    mk3 = {
        ["generic"] = {
            color = {r = 0.690, g = 0.75, b = 1},
            max_health = 2000,
            max_speed = 2,
            air_resistance = 0.0025
        },
        ["cargo-loco"] = {
            reversing_power_modifier = 1,
            braking_force = 20
        },
        ["cargo-wagon"] = {
            inventory_size = 100 / 2,
            friction_force = 0.01,
            equipment_grid = "car-large-equipment-grid"
        },
        ["cargo-placement"] = {
            prototypeAttributes = {
                equipment_grid = "car-large-equipment-grid"
            },
            recipe = {
                {MakeMkName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "cargo", type = "placement"}), "mk2"), 2},
                {"electric-engine-unit", 40},
                {"processing-unit", 20},
                {"titanium-alloy", 50},
                {"steel-plate", 100}
            },
            unlockTech = "railway-3"
        },
        ["fluid-loco"] = {
            reversing_power_modifier = 1,
            braking_force = 20
        },
        ["fluid-wagon"] = {
            capacity = 175000 / 2,
            equipment_grid = "car-large-equipment-grid"
        },
        ["fluid-placement"] = {
            prototypeAttributes = {
                equipment_grid = "car-large-equipment-grid"
            },
            recipe = {
                {MakeMkName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "fluid", type = "placement"}), "mk2"), 2},
                {"electric-engine-unit", 40},
                {"processing-unit", 20},
                {"titanium-alloy", 50},
                {"steel-plate", 100},
                {"pipe-mk2", 8}
            },
            unlockTech = "railway-3"
        }
    }
}

for _, mk in pairs({"mk2", "mk3"}) do
    for baseName, baseStaticData in pairs(StaticData.entityNames) do
        local entityVariant
        local improvementTierName = baseStaticData.unitType .. "-" .. baseStaticData.type
        if baseStaticData.type == "placement" then
            if improvementTiers[mk][improvementTierName] ~= nil then
                local placementDetails = improvementTiers[mk][improvementTierName]
                entityVariant = Utils.DeepCopy(data.raw["locomotive"][baseName])
                entityVariant.name = MakeMkName(entityVariant.name, mk)
                for key, value in pairs(improvementTiers[mk].generic) do
                    entityVariant[key] = value
                end
                for key, value in pairs(improvementTiers[mk][baseStaticData.unitType .. "-loco"]) do
                    entityVariant[key] = value
                end
                for key, value in pairs(placementDetails.prototypeAttributes) do
                    entityVariant[key] = value
                end
                entityVariant.pictures.layers[1].tint = improvementTiers[mk].generic.color
                entityVariant.icons[1].tint = improvementTiers[mk].generic.color
                data:extend({entityVariant})

                local itemVariant = Utils.DeepCopy(data.raw["item-with-entity-data"][baseName])
                itemVariant.name = entityVariant.name
                itemVariant.place_result = entityVariant.name
                itemVariant.icons[1].tint = improvementTiers[mk].generic.color
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
            if improvementTiers[mk][improvementTierName] ~= nil then
                local placementName = MakeMkName(baseStaticData.placementStaticData.name, mk)
                entityVariant = Utils.DeepCopy(data.raw[baseStaticData.prototypeType][baseName])
                entityVariant.name = MakeMkName(entityVariant.name, mk)
                for key, value in pairs(improvementTiers[mk].generic) do
                    entityVariant[key] = value
                end
                for key, value in pairs(improvementTiers[mk][improvementTierName]) do
                    entityVariant[key] = value
                end
                if baseStaticData.type == "wagon" then
                    entityVariant.pictures.layers[1].tint = improvementTiers[mk].generic.color
                    entityVariant.icons[1].tint = improvementTiers[mk].generic.color
                    entityVariant.minable.result = placementName
                end
                entityVariant.localised_name = {"entity-name." .. placementName}
                entityVariant.placeable_by = {item = placementName, count = 1}
                data:extend({entityVariant})
            end
        end
    end
end
