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

local function MakeMULocoPrototype(thisStaticData, wagonStaticType)
    local muLoco = Utils.DeepCopy(refLoco)
    muLoco.name = thisStaticData.name
    muLoco.localised_name = {"entity-name." .. wagonStaticType.placementStaticData.name}
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
    table.insert(muLoco.flags, "not-blueprintable")
    table.insert(muLoco.flags, "not-deconstructable")
    return muLoco
end

local function MakeMUWagonPrototype(thisStaticData, locoPrototype)
    local muWagon
    if thisStaticData.type == "cargo_wagon" then
        muWagon = Utils.DeepCopy(refCargoWagon)
        muWagon.inventory_size = muWagon.inventory_size / 2
    elseif thisStaticData.type == "fluid_wagon" then
        muWagon = Utils.DeepCopy(refFluidWagon)
        muWagon.capacity = muWagon.capacity / 2
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
    muWagon.max_health = locoPrototype.max_health
    table.insert(muWagon.flags, "not-blueprintable")
    table.insert(muWagon.flags, "not-deconstructable")
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
    return muWagon
end

local function MakeMuWagonPlacementPrototype(thisStaticData)
    local muWagonPlacement
    if thisStaticData.placedStaticDataWagon.type == "cargo_wagon" then
        muWagonPlacement = Utils.DeepCopy(refCargoWagon)
    elseif thisStaticData.placedStaticDataWagon.type == "fluid_wagon" then
        muWagonPlacement = Utils.DeepCopy(refFluidWagon)
    end
    muWagonPlacement.name = thisStaticData.name
    muWagonPlacement.collision_box = thisStaticData.collision_box
    muWagonPlacement.selection_box = thisStaticData.selection_box
    muWagonPlacement.joint_distance = thisStaticData.joint_distance
    muWagonPlacement.connection_distance = thisStaticData.connection_distance
    muWagonPlacement.connection_snap_distance = thisStaticData.connection_snap_distance
    muWagonPlacement.wheels = EmptyRotatedSprite()
    table.insert(muWagonPlacement.flags, "not-blueprintable")
    table.insert(muWagonPlacement.flags, "not-deconstructable")
    return muWagonPlacement
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
    return muWagonPlacementItem
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
    return muWagonPlacementRecipe
end

local muCargoLoco = MakeMULocoPrototype(StaticData.mu_cargo_loco, StaticData.mu_cargo_wagon)
local muCargoWagon = MakeMUWagonPrototype(StaticData.mu_cargo_wagon, muCargoLoco)
local muCargoPlacement = MakeMuWagonPlacementPrototype(StaticData.mu_cargo_placement)
local muCargoPlacementItem = MakeMuWagonPlacementItemPrototype(StaticData.mu_cargo_placement)
local muCargoPlacementRecipe = MakeMuWagonPlacementRecipePrototype(StaticData.mu_cargo_placement)

local muFluidLoco = MakeMULocoPrototype(StaticData.mu_fluid_loco, StaticData.mu_fluid_wagon)
local muFluidWagon = MakeMUWagonPrototype(StaticData.mu_fluid_wagon, muFluidLoco)
local muFluidPlacement = MakeMuWagonPlacementPrototype(StaticData.mu_fluid_placement)
local muFluidPlacementItem = MakeMuWagonPlacementItemPrototype(StaticData.mu_fluid_placement)
local muFluidPlacementRecipe = MakeMuWagonPlacementRecipePrototype(StaticData.mu_fluid_placement)

data:extend(
    {
        muCargoWagon,
        muCargoLoco,
        muCargoPlacement,
        muCargoPlacementItem,
        muCargoPlacementRecipe,
        muFluidWagon,
        muFluidLoco,
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
