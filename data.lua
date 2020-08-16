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

local function MakeMULocoPrototype(thisStaticData)
    local muLoco = Utils.DeepCopy(refLoco)
    muLoco.name = thisStaticData.name
    muLoco.localised_name = {"entity-name." .. thisStaticData.placementStaticData.name}
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
    muLoco.collision_box = thisStaticData.collision_box
    muLoco.selection_box = thisStaticData.selection_box
    muLoco.allow_manual_color = false
    muLoco.joint_distance = thisStaticData.joint_distance
    muLoco.connection_distance = thisStaticData.connection_distance
    muLoco.connection_snap_distance = thisStaticData.connection_snap_distance
    muLoco.weight = (refLoco.weight + refCargoWagon.weight) / 1.75
    muLoco.burner.fuel_inventory_size = 1
    muLoco.burner.effectivity = 0.5
    muLoco.minimap_representation = nil
    muLoco.selected_minimap_representation = nil
    muLoco.placeable_by = {item = thisStaticData.placementStaticData.name, count = 1}
    muLoco.alert_when_damaged = false
    table.insert(muLoco.flags, "not-blueprintable")
    table.insert(muLoco.flags, "not-deconstructable")
    data:extend({muLoco})
end

local function MakeMUWagonPrototype(thisStaticData)
    local itsLocoPrototype = data.raw["locomotive"][thisStaticData.placementStaticData.placedStaticDataLoco.name]
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
    muWagon.localised_name = {"entity-name." .. thisStaticData.placementStaticData.name}
    muWagon.minable.result = thisStaticData.placementStaticData.name
    muWagon.vertical_selection_shift = -0.5
    muWagon.wheels = EmptyRotatedSprite()
    muWagon.back_light = nil
    muWagon.stand_by_light = nil
    muWagon.collision_box = thisStaticData.collision_box
    muWagon.selection_box = thisStaticData.selection_box
    muWagon.allow_manual_color = true
    muWagon.joint_distance = thisStaticData.joint_distance
    muWagon.connection_distance = thisStaticData.connection_distance
    muWagon.connection_snap_distance = thisStaticData.connection_snap_distance
    muWagon.weight = 1
    muWagon.max_health = itsLocoPrototype.max_health
    muWagon.placeable_by = {item = thisStaticData.placementStaticData.name, count = 1}
    muWagon.minimap_representation = {
        filename = Constants.AssetModName .. "/graphics/entity/" .. thisStaticData.name .. "-minimap_representation.png",
        flags = {"icon"},
        size = {20, 70},
        scale = 0.5
    }
    muWagon.selected_minimap_representation = {
        filename = Constants.AssetModName .. "/graphics/entity/" .. thisStaticData.name .. "-selected_minimap_representation.png",
        flags = {"icon"},
        size = {20, 70},
        scale = 0.5
    }
    data:extend({muWagon})
end

local function MakeMuWagonPlacementPrototype(thisStaticData)
    local itsWagonPrototype = data.raw[thisStaticData.placedStaticDataWagon.type][thisStaticData.placedStaticDataWagon.name]
    local muWagonPlacement
    muWagonPlacement = Utils.DeepCopy(refLoco) -- Loco type snaps to stations, whereas cargo types don't.
    muWagonPlacement.name = thisStaticData.name
    muWagonPlacement.collision_box = thisStaticData.collision_box
    muWagonPlacement.selection_box = thisStaticData.selection_box
    muWagonPlacement.joint_distance = thisStaticData.joint_distance
    muWagonPlacement.connection_distance = thisStaticData.connection_distance
    muWagonPlacement.connection_snap_distance = thisStaticData.connection_snap_distance
    muWagonPlacement.wheels = EmptyRotatedSprite()
    muWagonPlacement.pictures = itsWagonPrototype.pictures
    muWagonPlacement.icon = thisStaticData.icon
    muWagonPlacement.icon_size = thisStaticData.iconSize
    muWagonPlacement.icon_mipmaps = thisStaticData.iconMipmaps
    data:extend({muWagonPlacement})
end

local function MakeMuWagonPlacementItemPrototype(thisStaticData)
    local muWagonPlacementItem = {
        type = "item-with-entity-data",
        name = thisStaticData.name,
        icon = thisStaticData.icon,
        icon_size = thisStaticData.iconSize,
        icon_mipmaps = thisStaticData.iconMipmaps,
        subgroup = "train-transport",
        order = thisStaticData.itemOrder,
        place_result = thisStaticData.name,
        stack_size = 5
    }
    data:extend({muWagonPlacementItem})
end

local function MakeMuWagonPlacementRecipePrototype(thisStaticData)
    local muWagonPlacementRecipe = {
        type = "recipe",
        name = thisStaticData.name,
        energy_required = 6,
        enabled = false,
        ingredients = thisStaticData.recipeIngredients,
        result = thisStaticData.name
    }
    data:extend({muWagonPlacementRecipe})
end

MakeMULocoPrototype(StaticData.mu_cargo_loco)
MakeMUWagonPrototype(StaticData.mu_cargo_wagon)
MakeMuWagonPlacementPrototype(StaticData.mu_cargo_placement)
MakeMuWagonPlacementItemPrototype(StaticData.mu_cargo_placement)
MakeMuWagonPlacementRecipePrototype(StaticData.mu_cargo_placement)

MakeMULocoPrototype(StaticData.mu_fluid_loco)
MakeMUWagonPrototype(StaticData.mu_fluid_wagon)
MakeMuWagonPlacementPrototype(StaticData.mu_fluid_placement)
MakeMuWagonPlacementItemPrototype(StaticData.mu_fluid_placement)
MakeMuWagonPlacementRecipePrototype(StaticData.mu_fluid_placement)

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
