local StaticData = {}

StaticData.mu_locomotive = {
    name = "mu_locomotive",
    collision_box = {{-0.6, -0.6}, {0.6, 0.6}},
    selection_box = {{-1, -0.7}, {1, 0.7}},
    connection_distance = 1.8,
    connection_snap_distance = 2,
    joint_distance = 0.4
}

StaticData.mu_cargo_wagon = {
    name = "mu_cargo_wagon",
    collision_box = {{-0.6, -1}, {0.6, 1}},
    selection_box = {{-1, -1.2}, {1, 1.2}},
    connection_distance = 1.8,
    connection_snap_distance = 2,
    joint_distance = 0.8
}

StaticData.mu_placement = {
    name = "mu_placement",
    collision_box = {{-0.6, -3}, {0.6, 3}},
    selection_box = {{-1, -3}, {1, 3}},
    connection_distance = 1.8,
    connection_snap_distance = 2,
    joint_distance = 5.2
}

return StaticData
