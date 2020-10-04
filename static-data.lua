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
StaticData.DoubleEndCargoWagon = {
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
StaticData.DoubleEndCargoWagon.name = StaticData.MakeName(StaticData.DoubleEndCargoWagon)
StaticData.entityNames[StaticData.DoubleEndCargoWagon.name] = StaticData.DoubleEndCargoWagon

StaticData.DoubleEndCargoLoco = {
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
StaticData.DoubleEndCargoLoco.name = StaticData.MakeName(StaticData.DoubleEndCargoLoco)
StaticData.entityNames[StaticData.DoubleEndCargoLoco.name] = StaticData.DoubleEndCargoLoco

StaticData.DoubleEndCargoPlacement = {
    collision_box = placementDetails.collision_box,
    selection_box = placementDetails.selection_box,
    connection_distance = placementDetails.connection_distance,
    connection_snap_distance = placementDetails.connection_snap_distance,
    joint_distance = placementDetails.joint_distance,
    placedStaticDataWagon = StaticData.DoubleEndCargoWagon,
    placedStaticDataLoco = StaticData.DoubleEndCargoLoco,
    unitType = "cargo",
    type = "placement",
    prototypeType = "locomotive",
    locoConfiguration = "double_end"
}
StaticData.DoubleEndCargoPlacement.name = StaticData.MakeName(StaticData.DoubleEndCargoPlacement)
StaticData.entityNames[StaticData.DoubleEndCargoPlacement.name] = StaticData.DoubleEndCargoPlacement

StaticData.DoubleEndCargoWagon.placementStaticData = StaticData.DoubleEndCargoPlacement
StaticData.DoubleEndCargoLoco.placementStaticData = StaticData.DoubleEndCargoPlacement

StaticData.DoubleEndFluidWagon = {
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
StaticData.DoubleEndFluidWagon.name = StaticData.MakeName(StaticData.DoubleEndFluidWagon)
StaticData.entityNames[StaticData.DoubleEndFluidWagon.name] = StaticData.DoubleEndFluidWagon

StaticData.DoubleEndFluidLoco = {
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
StaticData.DoubleEndFluidLoco.name = StaticData.MakeName(StaticData.DoubleEndFluidLoco)
StaticData.entityNames[StaticData.DoubleEndFluidLoco.name] = StaticData.DoubleEndFluidLoco

StaticData.DoubleEndFluidPlacement = {
    collision_box = placementDetails.collision_box,
    selection_box = placementDetails.selection_box,
    connection_distance = placementDetails.connection_distance,
    connection_snap_distance = placementDetails.connection_snap_distance,
    joint_distance = placementDetails.joint_distance,
    placedStaticDataWagon = StaticData.DoubleEndFluidWagon,
    placedStaticDataLoco = StaticData.DoubleEndFluidLoco,
    unitType = "fluid",
    type = "placement",
    prototypeType = "locomotive",
    locoConfiguration = "double_end"
}
StaticData.DoubleEndFluidPlacement.name = StaticData.MakeName(StaticData.DoubleEndFluidPlacement)
StaticData.entityNames[StaticData.DoubleEndFluidPlacement.name] = StaticData.DoubleEndFluidPlacement

StaticData.DoubleEndFluidWagon.placementStaticData = StaticData.DoubleEndFluidPlacement
StaticData.DoubleEndFluidLoco.placementStaticData = StaticData.DoubleEndFluidPlacement

return StaticData
