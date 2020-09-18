local Utils = require("utility/utils")
local StaticData = require("static-data")
local Constants = require("constants")

local refLoco = data.raw.locomotive.locomotive
local refCargoWagon = data.raw["cargo-wagon"]["cargo-wagon"]
local refFluidWagon = data.raw["fluid-wagon"]["fluid-wagon"]

local function MakeMULocoPrototype(thisStaticData, prototypeData)
    local placementStaticData = thisStaticData.placementStaticData
    local muLoco = Utils.DeepCopy(refLoco)
    muLoco.name = thisStaticData.name
    muLoco.localised_name = {"entity-name." .. placementStaticData.name}
    muLoco.minable.result = nil
    muLoco.vertical_selection_shift = -0.5
    muLoco.pictures = Utils.EmptyRotatedSprite()
    muLoco.drawing_box = {{-4, -4}, {-3, -3}} -- see nothing of the wheels
    muLoco.back_light[1].shift[2] = 1.2
    muLoco.back_light[2].shift[2] = 1.2
    muLoco.front_light[1].shift[2] = -13.5
    muLoco.front_light[2].shift[2] = -13.5
    muLoco.corpse = nil
    muLoco.dying_explosion = nil
    muLoco.stop_trigger = nil
    muLoco.drive_over_tie_trigger = nil
    muLoco.collision_box = thisStaticData.collision_box
    muLoco.selection_box = thisStaticData.selection_box
    muLoco.allow_manual_color = false
    muLoco.joint_distance = thisStaticData.joint_distance
    muLoco.connection_distance = thisStaticData.connection_distance
    muLoco.connection_snap_distance = thisStaticData.connection_snap_distance
    muLoco.weight = prototypeData.weight
    muLoco.burner.fuel_inventory_size = prototypeData.burner_fuel_inventory_size
    muLoco.burner.effectivity = prototypeData.burner_effectivity
    muLoco.minimap_representation = nil
    muLoco.selected_minimap_representation = nil
    muLoco.placeable_by = {item = placementStaticData.name, count = 1}
    muLoco.alert_when_damaged = false
    table.insert(muLoco.flags, "not-blueprintable")
    table.insert(muLoco.flags, "not-deconstructable")
    table.insert(muLoco.flags, "placeable-off-grid")
    data:extend({muLoco})
end

local function MakeMUWagonPrototype(thisStaticData, prototypeData)
    local placementStaticData = thisStaticData.placementStaticData
    local itsLocoPrototype = data.raw["locomotive"][placementStaticData.placedStaticDataLoco.name]
    local muWagon
    if thisStaticData.type == "cargo-wagon" then
        muWagon = Utils.DeepCopy(refCargoWagon)
        muWagon.inventory_size = muWagon.inventory_size / 2
    elseif thisStaticData.type == "fluid-wagon" then
        muWagon = Utils.DeepCopy(refFluidWagon)
        muWagon.capacity = muWagon.capacity / 2
        muWagon.tank_count = 1
    end
    muWagon.name = thisStaticData.name
    muWagon.localised_name = {"entity-name." .. placementStaticData.name}
    muWagon.minable.result = placementStaticData.name
    muWagon.vertical_selection_shift = -0.5
    muWagon.wheels = Utils.EmptyRotatedSprite()
    muWagon.back_light = nil
    muWagon.stand_by_light = nil
    muWagon.collision_box = thisStaticData.collision_box
    muWagon.selection_box = thisStaticData.selection_box
    muWagon.allow_manual_color = true
    muWagon.joint_distance = thisStaticData.joint_distance
    muWagon.connection_distance = thisStaticData.connection_distance
    muWagon.connection_snap_distance = thisStaticData.connection_snap_distance
    muWagon.weight = prototypeData.weight
    muWagon.max_health = itsLocoPrototype.max_health
    muWagon.placeable_by = {item = placementStaticData.name, count = 1}
    muWagon.minimap_representation = {
        filename = Constants.AssetModName .. "/graphics/entity/" .. thisStaticData.name .. "/" .. thisStaticData.name .. "-minimap_representation.png",
        flags = {"icon"},
        size = {20, 70},
        scale = 0.5
    }
    muWagon.selected_minimap_representation = {
        filename = Constants.AssetModName .. "/graphics/entity/" .. thisStaticData.name .. "/" .. thisStaticData.name .. "-selected_minimap_representation.png",
        flags = {"icon"},
        size = {20, 70},
        scale = 0.5
    }
    muWagon.icons = prototypeData.icons
    muWagon.drawing_box = {{-1, -4}, {1, 3}} -- same as locomotive
    if thisStaticData.type == "cargo-wagon" and settings.startup["single_train_unit-use_wip_graphics"].value then
        local filenameFolder = Constants.AssetModName .. "/graphics/entity/single_train_unit-double_end_cargo_wagon/"
        muWagon.pictures = {
            layers = {
                {
                    priority = "very-low",
                    width = 474,
                    height = 458,
                    direction_count = 128,
                    allow_low_quality_rotation = true,
                    back_equals_front = true,
                    filenames = {
                        filenameFolder .. "single_train_unit-double_end_cargo_wagon_1.png",
                        filenameFolder .. "single_train_unit-double_end_cargo_wagon_2.png",
                        filenameFolder .. "single_train_unit-double_end_cargo_wagon_3.png",
                        filenameFolder .. "single_train_unit-double_end_cargo_wagon_4.png",
                        filenameFolder .. "single_train_unit-double_end_cargo_wagon_5.png",
                        filenameFolder .. "single_train_unit-double_end_cargo_wagon_6.png",
                        filenameFolder .. "single_train_unit-double_end_cargo_wagon_7.png",
                        filenameFolder .. "single_train_unit-double_end_cargo_wagon_8.png"
                    },
                    line_length = 4,
                    lines_per_file = 4,
                    shift = {0.0, -0.5},
                    scale = 0.5
                },
                {
                    flags = {"shadow"},
                    priority = "very-low",
                    width = 490,
                    height = 401,
                    back_equals_front = true,
                    draw_as_shadow = true,
                    direction_count = 128,
                    allow_low_quality_rotation = true,
                    filenames = {
                        "__base__/graphics/entity/cargo-wagon/hr-cargo-wagon-shadow-1.png",
                        "__base__/graphics/entity/cargo-wagon/hr-cargo-wagon-shadow-2.png",
                        "__base__/graphics/entity/cargo-wagon/hr-cargo-wagon-shadow-3.png",
                        "__base__/graphics/entity/cargo-wagon/hr-cargo-wagon-shadow-4.png"
                    },
                    line_length = 4,
                    lines_per_file = 8,
                    shift = util.by_pixel(32, -2.25),
                    scale = 0.5
                }
            }
        }
        muWagon.horizontal_doors = {
            layers = {
                {
                    filename = filenameFolder .. "single_train_unit-double_end_cargo_wagon-horizontal_side.png",
                    line_length = 1,
                    width = 368,
                    height = 76,
                    frame_count = 8,
                    shift = util.by_pixel(0, -24.5),
                    scale = 0.5
                },
                {
                    filename = filenameFolder .. "single_train_unit-double_end_cargo_wagon-horizontal_top.png",
                    line_length = 1,
                    width = 369,
                    height = 54,
                    frame_count = 8,
                    shift = util.by_pixel(0.75, -35.5),
                    scale = 0.5
                }
            }
        }
        muWagon.vertical_doors = {
            layers = {
                {
                    filename = filenameFolder .. "single_train_unit-double_end_cargo_wagon-vertical_side.png",
                    line_length = 8,
                    width = 127,
                    height = 337,
                    frame_count = 8,
                    shift = util.by_pixel(0.25, -32.75),
                    scale = 0.5
                },
                {
                    filename = filenameFolder .. "single_train_unit-double_end_cargo_wagon-vertical_top.png",
                    line_length = 8,
                    width = 64,
                    height = 337,
                    frame_count = 8,
                    shift = util.by_pixel(0, -35.75),
                    scale = 0.5
                }
            }
        }
    end
    table.insert(muWagon.flags, "placeable-off-grid")
    data:extend({muWagon})
end

local function MakeMuWagonPlacementPrototype(thisStaticData, wagonPlacementPrototypeData, locoPrototypeData)
    local placedStaticDataWagon = thisStaticData.placedStaticDataWagon
    local itsWagonPrototype = data.raw[placedStaticDataWagon.type][placedStaticDataWagon.name]
    local muWagonPlacement
    muWagonPlacement = Utils.DeepCopy(refLoco) -- Loco type snaps to stations, whereas cargo types don't.
    muWagonPlacement.name = thisStaticData.name
    muWagonPlacement.collision_box = thisStaticData.collision_box
    muWagonPlacement.selection_box = thisStaticData.selection_box
    muWagonPlacement.joint_distance = thisStaticData.joint_distance
    muWagonPlacement.connection_distance = thisStaticData.connection_distance
    muWagonPlacement.connection_snap_distance = thisStaticData.connection_snap_distance
    muWagonPlacement.wheels = Utils.EmptyRotatedSprite()
    muWagonPlacement.pictures = itsWagonPrototype.pictures
    muWagonPlacement.icons = wagonPlacementPrototypeData.icons
    muWagonPlacement.weight = (locoPrototypeData.weight * 2) + wagonPlacementPrototypeData.weight -- Weight of both loco ends plus the wagon part
    muWagonPlacement.burner.fuel_inventory_size = locoPrototypeData.burner_fuel_inventory_size
    muWagonPlacement.burner.effectivity = locoPrototypeData.burner_effectivity
    table.insert(muWagonPlacement.flags, "not-deconstructable")
    table.insert(muWagonPlacement.flags, "placeable-off-grid")
    data:extend({muWagonPlacement})
end

local function MakeMuWagonPlacementItemPrototype(thisStaticData, prototypeData)
    local muWagonPlacementItem = {
        type = "item-with-entity-data",
        name = thisStaticData.name,
        icons = prototypeData.icons,
        subgroup = "train-transport",
        order = prototypeData.itemOrder,
        place_result = thisStaticData.name,
        stack_size = 5
    }
    data:extend({muWagonPlacementItem})
end

local function MakeMuWagonPlacementRecipePrototype(thisStaticData, prototypeData)
    local muWagonPlacementRecipe = {
        type = "recipe",
        name = thisStaticData.name,
        energy_required = 6,
        enabled = false,
        ingredients = prototypeData.recipeIngredients,
        result = thisStaticData.name
    }
    data:extend({muWagonPlacementRecipe})
end

local mu_loco_placement_prototypedata = {
    weight = (refLoco.weight + refCargoWagon.weight) / 1.75,
    burner_fuel_inventory_size = 1,
    burner_effectivity = 0.5
}

local mu_cargo_placement_prototypedata = {
    itemOrder = "za0",
    icons = {
        {
            icon = Constants.AssetModName .. "/graphics/icons/mu_cargo_wagon.png",
            icon_size = 64,
            icon_mipmaps = 4
        }
    },
    recipeIngredients = {
        {"engine-unit", 40},
        {"electronic-circuit", 20},
        {"steel-plate", 30},
        {"iron-gear-wheel", 5},
        {"iron-plate", 10}
    },
    weight = 1
}
MakeMULocoPrototype(StaticData.mu_cargo_loco, mu_loco_placement_prototypedata)
MakeMUWagonPrototype(StaticData.mu_cargo_wagon, mu_cargo_placement_prototypedata)
MakeMuWagonPlacementPrototype(StaticData.mu_cargo_placement, mu_cargo_placement_prototypedata, mu_loco_placement_prototypedata)
MakeMuWagonPlacementItemPrototype(StaticData.mu_cargo_placement, mu_cargo_placement_prototypedata)
MakeMuWagonPlacementRecipePrototype(StaticData.mu_cargo_placement, mu_cargo_placement_prototypedata)

local mu_fluid_placement_prototypedata = {
    itemOrder = "za1",
    icons = {
        {
            icon = Constants.AssetModName .. "/graphics/icons/mu_fluid_wagon.png",
            icon_size = 64,
            icon_mipmaps = 4
        }
    },
    recipeIngredients = {
        {"engine-unit", 40},
        {"electronic-circuit", 20},
        {"steel-plate", 30},
        {"iron-gear-wheel", 5},
        {"pipe", 4},
        {"storage-tank", 1}
    },
    weight = 1
}
MakeMULocoPrototype(StaticData.mu_fluid_loco, mu_loco_placement_prototypedata)
MakeMUWagonPrototype(StaticData.mu_fluid_wagon, mu_fluid_placement_prototypedata)
MakeMuWagonPlacementPrototype(StaticData.mu_fluid_placement, mu_fluid_placement_prototypedata, mu_loco_placement_prototypedata)
MakeMuWagonPlacementItemPrototype(StaticData.mu_fluid_placement, mu_fluid_placement_prototypedata)
MakeMuWagonPlacementRecipePrototype(StaticData.mu_fluid_placement, mu_fluid_placement_prototypedata)

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
