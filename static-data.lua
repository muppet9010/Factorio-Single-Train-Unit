local StaticData = {}
local Constants = require("constants")
local Utils = require("utility/utils")

StaticData.entityNames = {}

local locoDetails = {
    collision_box = {{-0.6, -0.8}, {0.6, 0.8}},
    selection_box = {{-1, -1}, {1, 1}},
    connection_distance = 3,
    connection_snap_distance = 2,
    joint_distance = 0.3
}

local centreWagonDetails = {
    collision_box = {{-0.6, -0.9}, {0.6, 0.9}},
    selection_box = {{-1, -1}, {1, 1}},
    connection_distance = 0,
    connection_snap_distance = 2,
    joint_distance = 0.4
}

local placementDetails = {
    collision_box = {{-0.6, -3.2}, {0.6, 3.2}},
    selection_box = {{-1, -3}, {1, 3}},
    connection_distance = locoDetails.connection_distance,
    connection_snap_distance = locoDetails.connection_snap_distance,
    joint_distance = 7 - locoDetails.connection_distance
}

--[[
    middle wagons and locos reference their placement via "placementStaticData"
    placement references wagons and locos via "placedStaticDataWagon" and "placedStaticDataLoco"
]]
StaticData.mu_cargo_wagon = {
    name = "single_train_unit-double_end_cargo_wagon",
    collision_box = centreWagonDetails.collision_box,
    selection_box = centreWagonDetails.selection_box,
    connection_distance = centreWagonDetails.connection_distance,
    connection_snap_distance = centreWagonDetails.connection_snap_distance,
    joint_distance = centreWagonDetails.joint_distance,
    type = "cargo-wagon"
}
StaticData.mu_cargo_loco = Utils.DeepCopy(locoDetails)
StaticData.mu_cargo_loco.name = "single_train_unit-double_end_cargo_loco"
StaticData.mu_cargo_placement = {
    name = "single_train_unit-double_end_loco_cargo_wagon_placement",
    collision_box = placementDetails.collision_box,
    selection_box = placementDetails.selection_box,
    connection_distance = placementDetails.connection_distance,
    connection_snap_distance = placementDetails.connection_snap_distance,
    joint_distance = placementDetails.joint_distance,
    placedStaticDataWagon = StaticData.mu_cargo_wagon,
    placedStaticDataLoco = StaticData.mu_cargo_loco,
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
StaticData.mu_cargo_loco.placementStaticData = StaticData.mu_cargo_placement
StaticData.entityNames[StaticData.mu_cargo_loco.name] = StaticData.mu_cargo_loco
StaticData.entityNames[StaticData.mu_cargo_wagon.name] = StaticData.mu_cargo_wagon
StaticData.entityNames[StaticData.mu_cargo_placement.name] = StaticData.mu_cargo_placement

StaticData.mu_fluid_wagon = {
    name = "single_train_unit-double_end_fluid_wagon",
    collision_box = centreWagonDetails.collision_box,
    selection_box = centreWagonDetails.selection_box,
    connection_distance = centreWagonDetails.connection_distance,
    connection_snap_distance = centreWagonDetails.connection_snap_distance,
    joint_distance = centreWagonDetails.joint_distance,
    type = "fluid-wagon"
}
StaticData.mu_fluid_loco = Utils.DeepCopy(locoDetails)
StaticData.mu_fluid_loco.name = "single_train_unit-double_end_fluid_loco"
StaticData.mu_fluid_placement = {
    name = "single_train_unit-double_end_loco_fluid_wagon_placement",
    collision_box = placementDetails.collision_box,
    selection_box = placementDetails.selection_box,
    connection_distance = placementDetails.connection_distance,
    connection_snap_distance = placementDetails.connection_snap_distance,
    joint_distance = placementDetails.joint_distance,
    placedStaticDataWagon = StaticData.mu_fluid_wagon,
    placedStaticDataLoco = StaticData.mu_fluid_loco,
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
StaticData.mu_fluid_loco.placementStaticData = StaticData.mu_fluid_placement
StaticData.entityNames[StaticData.mu_fluid_loco.name] = StaticData.mu_fluid_loco
StaticData.entityNames[StaticData.mu_fluid_wagon.name] = StaticData.mu_fluid_wagon
StaticData.entityNames[StaticData.mu_fluid_placement.name] = StaticData.mu_fluid_placement

return StaticData
