local Utils = require("utility/utils")
local StaticData = require("static-data")
local Constants = require("constants")

local refLoco = data.raw.locomotive.locomotive
local refCargoWagon = data.raw["cargo-wagon"]["cargo-wagon"]
local refFluidWagon = data.raw["fluid-wagon"]["fluid-wagon"]
local weightMultiplier = settings.startup["single_train_unit-weight_percentage"].value / 100
local cargoCapacityMultiplier = settings.startup["single_train_unit-wagon_capacity_percentage"].value / 100
local locoBurnerEffectivityMultiplier = settings.startup["single_train_unit-burner_effectivity_percentage"].value / 100
local locoBurnerInventorySize = settings.startup["single_train_unit-burner_inventory_size"].value

local function MakeMULocoPrototype(thisStaticData, locoPrototypeData)
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
    muLoco.weight = locoPrototypeData.weight
    muLoco.burner.fuel_inventory_size = locoPrototypeData.burner_fuel_inventory_size
    muLoco.burner.effectivity = locoPrototypeData.burner_effectivity
    muLoco.minimap_representation = nil
    muLoco.selected_minimap_representation = nil
    muLoco.placeable_by = {item = placementStaticData.name, count = 1}
    muLoco.alert_when_damaged = false
    muLoco.alert_icon_shift = {0, -0.5}
    table.insert(muLoco.flags, "not-deconstructable")
    table.insert(muLoco.flags, "placeable-off-grid")
    data:extend({muLoco})
end

local function MakeMUWagonPrototype(thisStaticData, prototypeData)
    local placementStaticData = thisStaticData.placementStaticData
    local itsLocoPrototype = data.raw["locomotive"][placementStaticData.placedStaticDataLoco.name]
    local muWagon
    if thisStaticData.prototypeType == "cargo-wagon" then
        muWagon = Utils.DeepCopy(refCargoWagon)
        muWagon.inventory_size = math.floor(muWagon.inventory_size * cargoCapacityMultiplier)
    elseif thisStaticData.prototypeType == "fluid-wagon" then
        muWagon = Utils.DeepCopy(refFluidWagon)
        muWagon.capacity = math.floor(muWagon.capacity * cargoCapacityMultiplier)
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
    muWagon.alert_icon_shift = {0, -0.5}
    muWagon.allow_manual_color = true
    muWagon.joint_distance = thisStaticData.joint_distance
    muWagon.connection_distance = thisStaticData.connection_distance
    muWagon.connection_snap_distance = thisStaticData.connection_snap_distance
    muWagon.weight = prototypeData.weight
    muWagon.max_health = itsLocoPrototype.max_health
    muWagon.placeable_by = {item = placementStaticData.name, count = 1}
    muWagon.minimap_representation = {
        filename = Constants.AssetModName .. "/graphics/entity/" .. thisStaticData.name .. "/" .. thisStaticData.name .. "-minimap-representation.png",
        flags = {"icon"},
        size = {20, 70},
        scale = 0.5
    }
    muWagon.selected_minimap_representation = {
        filename = Constants.AssetModName .. "/graphics/entity/" .. thisStaticData.name .. "/" .. thisStaticData.name .. "-selected-minimap-representation.png",
        flags = {"icon"},
        size = {20, 70},
        scale = 0.5
    }
    muWagon.icons = prototypeData.icons
    muWagon.drawing_box = {{-1, -4}, {1, 3}} -- same as locomotive
    if thisStaticData.prototypeType == "cargo-wagon" and settings.startup["single_train_unit-use_wip_graphics"].value then
        local filenameFolder = Constants.AssetModName .. "/graphics/entity/single_train_unit-double_end-cargo-wagon/"
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
                        filenameFolder .. "single_train_unit-double_end-cargo-wagon-1.png",
                        filenameFolder .. "single_train_unit-double_end-cargo-wagon-2.png",
                        filenameFolder .. "single_train_unit-double_end-cargo-wagon-3.png",
                        filenameFolder .. "single_train_unit-double_end-cargo-wagon-4.png",
                        filenameFolder .. "single_train_unit-double_end-cargo-wagon-5.png",
                        filenameFolder .. "single_train_unit-double_end-cargo-wagon-6.png",
                        filenameFolder .. "single_train_unit-double_end-cargo-wagon-7.png",
                        filenameFolder .. "single_train_unit-double_end-cargo-wagon-8.png"
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
                    filename = filenameFolder .. "single_train_unit-double_end-cargo-wagon-horizontal-side.png",
                    line_length = 1,
                    width = 368,
                    height = 76,
                    frame_count = 8,
                    shift = util.by_pixel(0, -24.5),
                    scale = 0.5
                },
                {
                    filename = filenameFolder .. "single_train_unit-double_end-cargo-wagon-horizontal-top.png",
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
                    filename = filenameFolder .. "single_train_unit-double_end-cargo-wagon-vertical-side.png",
                    line_length = 8,
                    width = 127,
                    height = 337,
                    frame_count = 8,
                    shift = util.by_pixel(0.25, -32.75),
                    scale = 0.5
                },
                {
                    filename = filenameFolder .. "single_train_unit-double_end-cargo-wagon-vertical-top.png",
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

local function MakeMuWagonPlacementPrototype(thisStaticData, wagonPrototypeData, locoPrototypeData)
    local placedStaticDataWagon = thisStaticData.placedStaticDataWagon
    local itsWagonPrototype = data.raw[placedStaticDataWagon.prototypeType][placedStaticDataWagon.name]
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
    muWagonPlacement.icons = wagonPrototypeData.icons
    muWagonPlacement.weight = (locoPrototypeData.weight * 2) + wagonPrototypeData.weight -- Weight of both loco ends plus the wagon part - means you can look at the recipe details and work out the expected speed.
    muWagonPlacement.burner.fuel_inventory_size = locoPrototypeData.burner_fuel_inventory_size * 2 -- Make the placement twice the size of the loco as then when any fuel/request is split between the 2 loco ends it works out.
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

local muLocoPrototypeData = {
    weight = refLoco.weight * weightMultiplier,
    burner_fuel_inventory_size = locoBurnerInventorySize,
    burner_effectivity = locoBurnerEffectivityMultiplier
}

local muCargoPrototypeData = {
    itemOrder = "za0",
    icons = {
        {
            icon = Constants.AssetModName .. "/graphics/icons/" .. StaticData.DoubleEndCargoWagon.name .. ".png",
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
    weight = refCargoWagon.weight * weightMultiplier
}
MakeMULocoPrototype(StaticData.DoubleEndCargoLoco, muLocoPrototypeData)
MakeMUWagonPrototype(StaticData.DoubleEndCargoWagon, muCargoPrototypeData)
MakeMuWagonPlacementPrototype(StaticData.DoubleEndCargoPlacement, muCargoPrototypeData, muLocoPrototypeData)
MakeMuWagonPlacementItemPrototype(StaticData.DoubleEndCargoPlacement, muCargoPrototypeData)
MakeMuWagonPlacementRecipePrototype(StaticData.DoubleEndCargoPlacement, muCargoPrototypeData)

local muFluidPrototypeData = {
    itemOrder = "za1",
    icons = {
        {
            icon = Constants.AssetModName .. "/graphics/icons/" .. StaticData.DoubleEndFluidWagon.name .. ".png",
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
    weight = refFluidWagon.weight * weightMultiplier
}
MakeMULocoPrototype(StaticData.DoubleEndFluidLoco, muLocoPrototypeData)
MakeMUWagonPrototype(StaticData.DoubleEndFluidWagon, muFluidPrototypeData)
MakeMuWagonPlacementPrototype(StaticData.DoubleEndFluidPlacement, muFluidPrototypeData, muLocoPrototypeData)
MakeMuWagonPlacementItemPrototype(StaticData.DoubleEndFluidPlacement, muFluidPrototypeData)
MakeMuWagonPlacementRecipePrototype(StaticData.DoubleEndFluidPlacement, muFluidPrototypeData)

if mods["trainConstructionSite"] == nil then
    -- Don't add our recipes for Train Construction Site mod as it makes a loop
    table.insert(
        data.raw["technology"]["railway"].effects,
        {
            type = "unlock-recipe",
            recipe = StaticData.DoubleEndCargoPlacement.name
        }
    )
    table.insert(
        data.raw["technology"]["railway"].effects,
        {
            type = "unlock-recipe",
            recipe = StaticData.DoubleEndFluidPlacement.name
        }
    )
end
