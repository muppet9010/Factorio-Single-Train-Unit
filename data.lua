--From Utils while POC
local Utils = require("utility/utils")
local StaticData = require("static-data")
local Constants = require("constants")

local refLoco = data.raw.locomotive.locomotive
local refCargoWagon = data.raw["cargo-wagon"]["cargo-wagon"]
local refFluidWagon = data.raw["fluid-wagon"]["fluid-wagon"]

local function EmptyRotatedSprite()
    return {
        direction_count = 1,
        filename = "__core__/graphics/empty.png",
        width = 1,
        height = 1
    }
end

local muLoco = Utils.DeepCopy(refLoco)
muLoco.name = StaticData.mu_locomotive.name
muLoco.localised_name = {"entity-name." .. StaticData.mu_cargo_placement.name}
muLoco.minable.result = nil
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
muLoco.allow_manual_color = false
muLoco.joint_distance = StaticData.mu_locomotive.joint_distance
muLoco.connection_distance = StaticData.mu_locomotive.connection_distance
muLoco.connection_snap_distance = StaticData.mu_locomotive.connection_snap_distance
muLoco.weight = (refLoco.weight + refCargoWagon.weight) / 1.75
muLoco.burner.fuel_inventory_size = 1
muLoco.burner.effectivity = 0.5
muLoco.minimap_representation = nil
muLoco.selected_minimap_representation = nil
table.insert(muLoco.flags, "not-blueprintable")
table.insert(muLoco.flags, "not-deconstructable")

local muCargoWagon = Utils.DeepCopy(refCargoWagon)
muCargoWagon.name = StaticData.mu_cargo_wagon.name
muCargoWagon.localised_name = {"entity-name." .. StaticData.mu_cargo_placement.name}
muCargoWagon.minable.result = StaticData.mu_cargo_placement.name
muCargoWagon.vertical_selection_shift = -0.5
muCargoWagon.wheels = EmptyRotatedSprite()
muCargoWagon.back_light = nil
muCargoWagon.stand_by_light = nil
muCargoWagon.collision_box = StaticData.mu_cargo_wagon.collision_box
muCargoWagon.selection_box = StaticData.mu_cargo_wagon.selection_box
muCargoWagon.allow_manual_color = true
muCargoWagon.joint_distance = StaticData.mu_cargo_wagon.joint_distance
muCargoWagon.connection_distance = StaticData.mu_cargo_wagon.connection_distance
muCargoWagon.connection_snap_distance = StaticData.mu_cargo_wagon.connection_snap_distance
muCargoWagon.weight = 1
muCargoWagon.max_health = muLoco.max_health
muCargoWagon.inventory_size = muCargoWagon.inventory_size / 2
table.insert(muLoco.flags, "not-blueprintable")
table.insert(muLoco.flags, "not-deconstructable")
muCargoWagon.minimap_representation = {
    filename = Constants.AssetModName .. "/graphics/entity/" .. StaticData.mu_cargo_wagon.name .. "-minimap_representation.png",
    flags = {"icon"},
    size = {20, 70},
    scale = 0.5
}
muCargoWagon.selected_minimap_representation = {
    filename = Constants.AssetModName .. "/graphics/entity/" .. StaticData.mu_cargo_wagon.name .. "-selected_minimap_representation.png",
    flags = {"icon"},
    size = {20, 70},
    scale = 0.5
}

local muCargoPlacement = Utils.DeepCopy(refLoco)
muCargoPlacement.name = StaticData.mu_cargo_placement.name
muCargoPlacement.collision_box = StaticData.mu_cargo_placement.collision_box
muCargoPlacement.selection_box = StaticData.mu_cargo_placement.selection_box
muCargoPlacement.joint_distance = StaticData.mu_cargo_placement.joint_distance
muCargoPlacement.connection_distance = StaticData.mu_cargo_placement.connection_distance
muCargoPlacement.connection_snap_distance = StaticData.mu_cargo_placement.connection_snap_distance
muCargoPlacement.wheels = EmptyRotatedSprite()
table.insert(muLoco.flags, "not-blueprintable")
table.insert(muLoco.flags, "not-deconstructable")
muCargoPlacement.minimap_representation = muCargoWagon.minimap_representation
muCargoPlacement.selected_minimap_representation = muCargoWagon.selected_minimap_representation

local muCargoPlacementItem = {
    type = "item-with-entity-data",
    name = StaticData.mu_cargo_placement.name,
    icon = Constants.AssetModName .. "/graphics/icons/mu_cargo_wagon.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "train-transport",
    order = "za0",
    place_result = StaticData.mu_cargo_placement.name,
    stack_size = 5
}
local muCargoPlacementRecipe = {
    type = "recipe",
    name = StaticData.mu_cargo_placement.name,
    energy_required = 6,
    enabled = false,
    ingredients = {
        {"engine-unit", 40},
        {"electronic-circuit", 20},
        {"steel-plate", 30},
        {"iron-gear-wheel", 5},
        {"iron-plate", 10}
    },
    result = StaticData.mu_cargo_placement.name
}

local muFluidWagon = Utils.DeepCopy(refFluidWagon)
muFluidWagon.name = StaticData.mu_fluid_wagon.name
muFluidWagon.localised_name = {"entity-name." .. StaticData.mu_fluid_placement.name}
muFluidWagon.minable.result = StaticData.mu_fluid_placement.name
muFluidWagon.vertical_selection_shift = -0.5
muFluidWagon.wheels = EmptyRotatedSprite()
muFluidWagon.back_light = nil
muFluidWagon.stand_by_light = nil
muFluidWagon.collision_box = StaticData.mu_fluid_wagon.collision_box
muFluidWagon.selection_box = StaticData.mu_fluid_wagon.selection_box
muFluidWagon.allow_manual_color = true
muFluidWagon.joint_distance = StaticData.mu_fluid_wagon.joint_distance
muFluidWagon.connection_distance = StaticData.mu_fluid_wagon.connection_distance
muFluidWagon.connection_snap_distance = StaticData.mu_fluid_wagon.connection_snap_distance
muFluidWagon.weight = 1
muFluidWagon.max_health = muLoco.max_health
muFluidWagon.capacity = muFluidWagon.capacity / 2
table.insert(muLoco.flags, "not-blueprintable")
table.insert(muLoco.flags, "not-deconstructable")
muFluidWagon.minimap_representation = {
    filename = Constants.AssetModName .. "/graphics/entity/" .. StaticData.mu_fluid_wagon.name .. "-minimap_representation.png",
    flags = {"icon"},
    size = {20, 70},
    scale = 0.5
}
muFluidWagon.selected_minimap_representation = {
    filename = Constants.AssetModName .. "/graphics/entity/" .. StaticData.mu_fluid_wagon.name .. "-selected_minimap_representation.png",
    flags = {"icon"},
    size = {20, 70},
    scale = 0.5
}

local muFluidPlacement = Utils.DeepCopy(refLoco)
muFluidPlacement.name = StaticData.mu_fluid_placement.name
muFluidPlacement.collision_box = StaticData.mu_fluid_placement.collision_box
muFluidPlacement.selection_box = StaticData.mu_fluid_placement.selection_box
muFluidPlacement.joint_distance = StaticData.mu_fluid_placement.joint_distance
muFluidPlacement.connection_distance = StaticData.mu_fluid_placement.connection_distance
muFluidPlacement.connection_snap_distance = StaticData.mu_fluid_placement.connection_snap_distance
muFluidPlacement.wheels = EmptyRotatedSprite()
table.insert(muLoco.flags, "not-blueprintable")
table.insert(muLoco.flags, "not-deconstructable")
muFluidPlacement.minimap_representation = muFluidWagon.minimap_representation
muFluidPlacement.selected_minimap_representation = muFluidWagon.selected_minimap_representation

local muFluidPlacementItem = {
    type = "item-with-entity-data",
    name = StaticData.mu_fluid_placement.name,
    icon = Constants.AssetModName .. "/graphics/icons/mu_fluid_wagon.png",
    icon_size = 64,
    icon_mipmaps = 4,
    subgroup = "train-transport",
    order = "za1",
    place_result = StaticData.mu_fluid_placement.name,
    stack_size = 5
}
local muFluidPlacementRecipe = {
    type = "recipe",
    name = StaticData.mu_fluid_placement.name,
    energy_required = 6,
    enabled = false,
    ingredients = {
        {"engine-unit", 40},
        {"electronic-circuit", 20},
        {"steel-plate", 30},
        {"iron-gear-wheel", 5},
        {"iron-plate", 10}
    },
    result = StaticData.mu_fluid_placement.name
}

data:extend(
    {
        muLoco,
        muCargoWagon,
        muCargoPlacement,
        muCargoPlacementItem,
        muCargoPlacementRecipe,
        muFluidWagon,
        muFluidPlacement,
        muFluidPlacementItem,
        muFluidPlacementRecipe
    }
)

table.insert(
    data.raw["technology"]["railway"].effects,
    {
        type = "unlock-recipe",
        recipe = StaticData.mu_cargo_placement.name
    }
)
table.insert(
    data.raw["technology"]["railway"].effects,
    {
        type = "unlock-recipe",
        recipe = StaticData.mu_fluid_placement.name
    }
)
