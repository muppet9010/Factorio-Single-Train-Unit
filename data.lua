--From Utils while POC
local Utils = require("utility/utils")
local StaticData = require("static-data")

local function EmptyRotatedSprite()
    return {
        direction_count = 1,
        filename = "__core__/graphics/empty.png",
        width = 1,
        height = 1
    }
end

local muLoco = Utils.DeepCopy(data.raw.locomotive.locomotive)
muLoco.name = StaticData.mu_locomotive.name
muLoco.localised_name = {"entity-name." .. StaticData.mu_placement.name}
muLoco.minable.result = nil
 --StaticData.mu_locomotive.name
muLoco.vertical_selection_shift = -0.5
muLoco.pictures = EmptyRotatedSprite()
muLoco.back_light[1].shift[2] = 1.2
muLoco.back_light[2].shift[2] = 1.2
muLoco.front_light[1].shift[2] = -13.5
muLoco.front_light[2].shift[2] = -13.5
muLoco.corpse = nil
muLoco.dying_explosion = nil
muLoco.stop_trigger = nil
muLoco.drive_over_tie_trigger = nil
muLoco.collision_box = StaticData.mu_locomotive.collision_box
muLoco.selection_box = StaticData.mu_locomotive.selection_box
muLoco.joint_distance = StaticData.mu_locomotive.joint_distance
muLoco.connection_distance = StaticData.mu_locomotive.connection_distance
muLoco.connection_snap_distance = StaticData.mu_locomotive.connection_snap_distance
muLoco.weight = muLoco.weight / 5
local muLocoPowerValue, muLocoPowerUnit = Utils.GetValueAndUnitFromString(muLoco.max_power)
muLoco.max_power = (muLocoPowerValue / 2) .. muLocoPowerUnit
muLoco.burner.fuel_inventory_size = 1
muLoco.braking_force = muLoco.braking_force / 4
muLoco.friction_force = muLoco.friction_force / 2

local muCargoWagon = Utils.DeepCopy(data.raw["cargo-wagon"]["cargo-wagon"])
muCargoWagon.name = StaticData.mu_cargo_wagon.name
muCargoWagon.localised_name = {"entity-name." .. StaticData.mu_placement.name}
muCargoWagon.minable.result = StaticData.mu_placement.name
muCargoWagon.vertical_selection_shift = -0.5
muCargoWagon.wheels = EmptyRotatedSprite()
muCargoWagon.back_light = nil
muCargoWagon.stand_by_light = nil
muCargoWagon.collision_box = StaticData.mu_cargo_wagon.collision_box
muCargoWagon.selection_box = StaticData.mu_cargo_wagon.selection_box
muCargoWagon.joint_distance = StaticData.mu_cargo_wagon.joint_distance
muCargoWagon.connection_distance = StaticData.mu_cargo_wagon.connection_distance
muCargoWagon.connection_snap_distance = StaticData.mu_cargo_wagon.connection_snap_distance
muCargoWagon.weight = 1
muCargoWagon.max_health = muLoco.max_health
muCargoWagon.inventory_size = muCargoWagon.inventory_size / 3

local muPlacement = Utils.DeepCopy(data.raw.locomotive.locomotive)
muPlacement.name = StaticData.mu_placement.name
muPlacement.collision_box = StaticData.mu_placement.collision_box
muPlacement.selection_box = StaticData.mu_placement.selection_box
muPlacement.joint_distance = StaticData.mu_placement.joint_distance
muPlacement.connection_distance = StaticData.mu_placement.connection_distance
muPlacement.connection_snap_distance = StaticData.mu_placement.connection_snap_distance
muPlacement.wheels = EmptyRotatedSprite()

data:extend(
    {
        muLoco,
        --[[{
            type = "item-with-entity-data",
            name = StaticData.mu_locomotive.name,
            icon = "__base__/graphics/icons/locomotive.png",
            icon_size = 32,
            subgroup = "transport",
            order = "za1",
            place_result = StaticData.mu_locomotive.name,
            stack_size = 5
        },]]
        muCargoWagon,
        --[[{
            type = "item-with-entity-data",
            name = StaticData.mu_cargo_wagon.name,
            icon = "__base__/graphics/icons/cargo-wagon.png",
            icon_size = 32,
            subgroup = "transport",
            order = "za2",
            place_result = StaticData.mu_cargo_wagon.name,
            stack_size = 5
        },]]
        muPlacement,
        {
            type = "item-with-entity-data",
            name = StaticData.mu_placement.name,
            icon = "__base__/graphics/icons/locomotive.png",
            icon_size = 32,
            subgroup = "transport",
            order = "za0",
            place_result = StaticData.mu_placement.name,
            stack_size = 5
        },
        {
            type = "recipe",
            name = StaticData.mu_placement.name,
            energy_required = 4,
            enabled = false,
            ingredients = {
                {"engine-unit", 40},
                {"electronic-circuit", 20},
                {"steel-plate", 30},
                {"iron-gear-wheel", 5},
                {"iron-plate", 10}
            },
            result = StaticData.mu_placement.name
        }
    }
)

table.insert(
    data.raw["technology"]["railway"].effects,
    {
        type = "unlock-recipe",
        recipe = StaticData.mu_placement.name
    }
)
