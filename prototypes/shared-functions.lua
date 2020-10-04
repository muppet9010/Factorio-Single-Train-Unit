local SharedFunctions = {}

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

return SharedFunctions
