local StaticData = {}

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
    joint_distance = 0.8
}

StaticData.mu_cargo_placement = {
    name = "single_train_unit-double_end_loco_cargo_wagon_placement",
    collision_box = {{-0.6, -3}, {0.6, 3}},
    selection_box = {{-1, -3}, {1, 3}},
    connection_distance = 1.8,
    connection_snap_distance = 4,
    joint_distance = 5.2
}

StaticData.mu_fluid_wagon = {
    name = "single_train_unit-double_end_fluid_wagon",
    collision_box = {{-0.6, -1}, {0.6, 1}},
    selection_box = {{-1, -1.4}, {1, 1.4}},
    connection_distance = 1.8,
    connection_snap_distance = 2,
    joint_distance = 0.8
}

StaticData.mu_fluid_placement = {
    name = "single_train_unit-double_end_loco_fluid_wagon_placement",
    collision_box = {{-0.6, -3}, {0.6, 3}},
    selection_box = {{-1, -3}, {1, 3}},
    connection_distance = 1.8,
    connection_snap_distance = 4,
    joint_distance = 5.2
}

return StaticData
