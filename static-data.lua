local StaticData = {}

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
    connection_distance = 3,
    connection_snap_distance = 2,
    joint_distance = 4
}

StaticData.MakeName = function(staticData)
    return "single_train_unit-" .. staticData.locoConfiguration .. "-" .. staticData.unitType .. "-" .. staticData.type
end

--[[
    middle wagons and locos reference their placement via "placementStaticData".
    placement references wagons and locos via "placedStaticDataWagon" and "placedStaticDataLoco".
    All final parts have a "type".
]]
StaticData.mu_cargo_wagon = {
    collision_box = centreWagonDetails.collision_box,
    selection_box = centreWagonDetails.selection_box,
    connection_distance = centreWagonDetails.connection_distance,
    connection_snap_distance = centreWagonDetails.connection_snap_distance,
    joint_distance = centreWagonDetails.joint_distance,
    unitType = "cargo",
    type = "wagon",
    prototypeType = "cargo-wagon",
    locoConfiguration = "double_end"
}
StaticData.mu_cargo_wagon.name = StaticData.MakeName(StaticData.mu_cargo_wagon)
StaticData.entityNames[StaticData.mu_cargo_wagon.name] = StaticData.mu_cargo_wagon

StaticData.mu_cargo_loco = {
    collision_box = locoDetails.collision_box,
    selection_box = locoDetails.selection_box,
    connection_distance = locoDetails.connection_distance,
    connection_snap_distance = locoDetails.connection_snap_distance,
    joint_distance = locoDetails.joint_distance,
    unitType = "cargo",
    type = "loco",
    prototypeType = "locomotive",
    locoConfiguration = "double_end"
}
StaticData.mu_cargo_loco.name = StaticData.MakeName(StaticData.mu_cargo_loco)
StaticData.entityNames[StaticData.mu_cargo_loco.name] = StaticData.mu_cargo_loco

StaticData.mu_cargo_placement = {
    collision_box = placementDetails.collision_box,
    selection_box = placementDetails.selection_box,
    connection_distance = placementDetails.connection_distance,
    connection_snap_distance = placementDetails.connection_snap_distance,
    joint_distance = placementDetails.joint_distance,
    placedStaticDataWagon = StaticData.mu_cargo_wagon,
    placedStaticDataLoco = StaticData.mu_cargo_loco,
    unitType = "cargo",
    type = "placement",
    prototypeType = "locomotive",
    locoConfiguration = "double_end"
}
StaticData.mu_cargo_placement.name = StaticData.MakeName(StaticData.mu_cargo_placement)
StaticData.entityNames[StaticData.mu_cargo_placement.name] = StaticData.mu_cargo_placement

StaticData.mu_cargo_wagon.placementStaticData = StaticData.mu_cargo_placement
StaticData.mu_cargo_loco.placementStaticData = StaticData.mu_cargo_placement

StaticData.mu_fluid_wagon = {
    collision_box = centreWagonDetails.collision_box,
    selection_box = centreWagonDetails.selection_box,
    connection_distance = centreWagonDetails.connection_distance,
    connection_snap_distance = centreWagonDetails.connection_snap_distance,
    joint_distance = centreWagonDetails.joint_distance,
    unitType = "fluid",
    type = "wagon",
    prototypeType = "fluid-wagon",
    locoConfiguration = "double_end"
}
StaticData.mu_fluid_wagon.name = StaticData.MakeName(StaticData.mu_fluid_wagon)
StaticData.entityNames[StaticData.mu_fluid_wagon.name] = StaticData.mu_fluid_wagon

StaticData.mu_fluid_loco = {
    collision_box = locoDetails.collision_box,
    selection_box = locoDetails.selection_box,
    connection_distance = locoDetails.connection_distance,
    connection_snap_distance = locoDetails.connection_snap_distance,
    joint_distance = locoDetails.joint_distance,
    unitType = "fluid",
    type = "loco",
    prototypeType = "locomotive",
    locoConfiguration = "double_end"
}
StaticData.mu_fluid_loco.name = StaticData.MakeName(StaticData.mu_fluid_loco)
StaticData.entityNames[StaticData.mu_fluid_loco.name] = StaticData.mu_fluid_loco

StaticData.mu_fluid_placement = {
    collision_box = placementDetails.collision_box,
    selection_box = placementDetails.selection_box,
    connection_distance = placementDetails.connection_distance,
    connection_snap_distance = placementDetails.connection_snap_distance,
    joint_distance = placementDetails.joint_distance,
    placedStaticDataWagon = StaticData.mu_fluid_wagon,
    placedStaticDataLoco = StaticData.mu_fluid_loco,
    unitType = "fluid",
    type = "placement",
    prototypeType = "locomotive",
    locoConfiguration = "double_end"
}
StaticData.mu_fluid_placement.name = StaticData.MakeName(StaticData.mu_fluid_placement)
StaticData.entityNames[StaticData.mu_fluid_placement.name] = StaticData.mu_fluid_placement

StaticData.mu_fluid_wagon.placementStaticData = StaticData.mu_fluid_placement
StaticData.mu_fluid_loco.placementStaticData = StaticData.mu_fluid_placement

return StaticData
