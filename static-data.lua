local StaticData = {}
local Constants = require("constants")

StaticData.mu_locomotive = {
    name = "single_train_unit-double_end_loco",
    collision_box = {{-0.6, -0.6}, {0.6, 0.6}},
    selection_box = {{-1, -1}, {1, 1}},
    connection_distance = 1.8,
    connection_snap_distance = 2,
    joint_distance = 0.4
}

StaticData.mu_cargo_wagon = {
    name = "single_train_unit-double_end_cargo_wagon",
    collision_box = {{-0.6, -1}, {0.6, 1}},
    selection_box = {{-1, -1.4}, {1, 1.4}},
    connection_distance = 1.8,
    connection_snap_distance = 2,
    joint_distance = 0.8,
    type = "cargo_wagon"
}
StaticData.mu_cargo_placement = {
    name = "single_train_unit-double_end_loco_cargo_wagon_placement",
    collision_box = {{-0.6, -3}, {0.6, 3}},
    selection_box = {{-1, -3}, {1, 3}},
    connection_distance = 1.8,
    connection_snap_distance = 4,
    joint_distance = 5.2,
    placedStaticData = StaticData.mu_cargo_wagon,
    type = "cargo_wagon",
    itemOrder = "za0",
    icon = Constants.AssetModName .. "/graphics/icons/mu_cargo_wagon.png",
    iconSize = 64,
    iconMipmaps = 4,
    recipeIngredients = {
        {"engine-unit", 40},
        {"electronic-circuit", 20},
        {"steel-plate", 30},
        {"iron-gear-wheel", 5},
        {"iron-plate", 10}
    }
}
StaticData.mu_cargo_wagon.placementStaticData = StaticData.mu_cargo_placement

StaticData.mu_fluid_wagon = {
    name = "single_train_unit-double_end_fluid_wagon",
    collision_box = {{-0.6, -1}, {0.6, 1}},
    selection_box = {{-1, -1.4}, {1, 1.4}},
    connection_distance = 1.8,
    connection_snap_distance = 2,
    joint_distance = 0.8,
    type = "fluid_wagon"
}
StaticData.mu_fluid_placement = {
    name = "single_train_unit-double_end_loco_fluid_wagon_placement",
    collision_box = {{-0.6, -3}, {0.6, 3}},
    selection_box = {{-1, -3}, {1, 3}},
    connection_distance = 1.8,
    connection_snap_distance = 4,
    joint_distance = 5.2,
    placedStaticData = StaticData.mu_fluid_wagon,
    type = "fluid_wagon",
    itemOrder = "za1",
    icon = Constants.AssetModName .. "/graphics/icons/mu_fluid_wagon.png",
    iconSize = 64,
    iconMipmaps = 4,
    recipeIngredients = {
        {"engine-unit", 40},
        {"electronic-circuit", 20},
        {"steel-plate", 30},
        {"iron-gear-wheel", 5},
        {"pipe", 4},
        {"storage-tank", 1}
    }
}
StaticData.mu_fluid_wagon.placementStaticData = StaticData.mu_fluid_placement

return StaticData
