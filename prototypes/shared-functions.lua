local SharedFunctions = {}
local StaticData = require("static-data")
local Utils = require("utility/utils")

local weightMultiplier = settings.startup["single_train_unit-weight_percentage"].value / 100
local cargoCapacityMultiplier = settings.startup["single_train_unit-wagon_capacity_percentage"].value / 100

SharedFunctions.GetGenericSettingsFromReference = function(reference, extraAttributes)
    local attributes = {}
    attributes.max_health = reference.max_health
    attributes.max_speed = reference.max_speed
    attributes.equipment_grid = reference.equipment_grid
    attributes.resistances = reference.resistances
    if extraAttributes ~= nil then
        for name, value in pairs(extraAttributes) do
            attributes[name] = value
        end
    end
    return attributes
end

SharedFunctions.GetLocoSettingsFromReference = function(reference, extraAttributes)
    local attributes = {}
    attributes.braking_force = reference.braking_force
    attributes.air_resistance = reference.air_resistance
    attributes.energy_per_hit_point = reference.energy_per_hit_point
    attributes.max_power = reference.max_power
    attributes.reversing_power_modifier = reference.reversing_power_modifier
    attributes.weight = reference.weight * weightMultiplier
    if extraAttributes ~= nil then
        for name, value in pairs(extraAttributes) do
            attributes[name] = value
        end
    end
    return attributes
end

SharedFunctions.GetCargoSettingsFromReference = function(reference, extraAttributes)
    local attributes = {}
    attributes.braking_force = reference.braking_force
    attributes.air_resistance = reference.air_resistance
    attributes.weight = reference.weight * weightMultiplier
    attributes.energy_per_hit_point = reference.energy_per_hit_point
    attributes.inventory_size = reference.inventory_size * cargoCapacityMultiplier
    if extraAttributes ~= nil then
        for name, value in pairs(extraAttributes) do
            attributes[name] = value
        end
    end
    return attributes
end

SharedFunctions.GetFluidSettingsFromReference = function(reference, extraAttributes)
    local attributes = {}
    attributes.braking_force = reference.braking_force
    attributes.air_resistance = reference.air_resistance
    attributes.weight = reference.weight * weightMultiplier
    attributes.energy_per_hit_point = reference.energy_per_hit_point
    attributes.capacity = reference.capacity * cargoCapacityMultiplier
    if extraAttributes ~= nil then
        for name, value in pairs(extraAttributes) do
            attributes[name] = value
        end
    end
    return attributes
end

SharedFunctions.MakeModdedVariations = function(improvementTiers, MakeIdentifierNameFunction, itemDetails)
    --[[
        improvementTiers = {
            [tierName] = {
                type details...
            }
        }
        itemDetails = {subgroup, orderPrefix}
    ]]
    for identifier, improvementDetails in pairs(improvementTiers) do
        for baseName, baseStaticData in pairs(StaticData.entityNames) do
            local improvementTierName = baseStaticData.unitType .. "-" .. baseStaticData.type
            if baseStaticData.type == "placement" then
                if improvementDetails[improvementTierName] ~= nil then
                    local placementDetails = improvementDetails[improvementTierName]
                    local entityVariant = Utils.DeepCopy(data.raw["locomotive"][baseName])
                    entityVariant.name = MakeIdentifierNameFunction(entityVariant.name, identifier)
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
                    itemVariant.subgroup = itemDetails.subgroup
                    itemVariant.order = itemDetails.orderPrefix .. itemVariant.order .. "-" .. identifier
                    data:extend({itemVariant})

                    local recipeVariant = Utils.MakeRecipePrototype(entityVariant.name, entityVariant.name, placementDetails.recipe.enabled, placementDetails.recipe.ingredientLists, placementDetails.recipe.energyLists)
                    data:extend({recipeVariant})
                    table.insert(data.raw["technology"][placementDetails.unlockTech].effects, {type = "unlock-recipe", recipe = entityVariant.name})
                end
            else
                if improvementDetails[improvementTierName] ~= nil then
                    local placementName = MakeIdentifierNameFunction(baseStaticData.placementStaticData.name, identifier)
                    local entityVariant = Utils.DeepCopy(data.raw[baseStaticData.prototypeType][baseName])
                    entityVariant.name = MakeIdentifierNameFunction(entityVariant.name, identifier)
                    for key, value in pairs(improvementDetails.generic) do
                        entityVariant[key] = value
                    end
                    for key, value in pairs(improvementDetails[improvementTierName]) do
                        entityVariant[key] = value
                    end
                    if baseStaticData.type == "wagon" then
                        entityVariant.pictures.layers[1].tint = improvementDetails.generic.color
                        if baseStaticData.unitType == "cargo" then
                            for _, directionLayers in pairs({entityVariant.horizontal_doors.layers, entityVariant.vertical_doors.layers}) do
                                for _, layer in pairs(directionLayers) do
                                    layer.tint = improvementDetails.generic.color
                                end
                            end
                        end
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
end

return SharedFunctions
