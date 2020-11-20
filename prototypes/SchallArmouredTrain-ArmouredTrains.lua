local Utils = require("utility/utils")
local StaticData = require("static-data")
local SharedFunctions = require("prototypes.shared-functions")

if not mods["SchallArmouredTrain"] then
    return
end

local mk0armouredLocoRefPrototype,
    mk1armouredLocoRefPrototype,
    mk2armouredLocoRefPrototype,
    mk0armouredCargoRefPrototype,
    mk1armouredCargoRefPrototype,
    mk2armouredCargoRefPrototype,
    mk0armouredFluidRefPrototype,
    mk1armouredFluidRefPrototype,
    mk2armouredFluidRefPrototype,
    mk0armouredLocoRefRecipe,
    mk1armouredLocoRefRecipe,
    mk2armouredLocoRefRecipe,
    mk0armouredCargoRefRecipe,
    mk1armouredCargoRefRecipe,
    mk2armouredCargoRefRecipe,
    mk0armouredFluidRefRecipe,
    mk1armouredFluidRefRecipe,
    mk2armouredFluidRefRecipe

if settings.startup["armouredtrain-locomotive-enable"].value then
    mk0armouredLocoRefPrototype = data.raw["locomotive"]["Schall-armoured-locomotive"]
    mk1armouredLocoRefPrototype = data.raw["locomotive"]["Schall-armoured-locomotive-mk1"]
    mk2armouredLocoRefPrototype = data.raw["locomotive"]["Schall-armoured-locomotive-mk2"]
    mk0armouredLocoRefRecipe = data.raw["recipe"]["Schall-armoured-locomotive"]
    mk1armouredLocoRefRecipe = data.raw["recipe"]["Schall-armoured-locomotive-mk1"]
    mk2armouredLocoRefRecipe = data.raw["recipe"]["Schall-armoured-locomotive-mk2"]
else
    mk0armouredLocoRefPrototype = data.raw["locomotive"]["locomotive"]
    mk1armouredLocoRefPrototype = data.raw["locomotive"]["locomotive"]
    mk2armouredLocoRefPrototype = data.raw["locomotive"]["locomotive"]
    mk0armouredLocoRefRecipe = data.raw["recipe"]["locomotive"]
    mk1armouredLocoRefRecipe = data.raw["recipe"]["locomotive"]
    mk2armouredLocoRefRecipe = data.raw["recipe"]["locomotive"]
end
if settings.startup["armouredtrain-cargo-wagon-enable"].value then
    mk0armouredCargoRefPrototype = data.raw["cargo-wagon"]["Schall-armoured-cargo-wagon"]
    mk1armouredCargoRefPrototype = data.raw["cargo-wagon"]["Schall-armoured-cargo-wagon-mk1"]
    mk2armouredCargoRefPrototype = data.raw["cargo-wagon"]["Schall-armoured-cargo-wagon-mk2"]
    mk0armouredCargoRefRecipe = data.raw["recipe"]["Schall-armoured-cargo-wagon"]
    mk1armouredCargoRefRecipe = data.raw["recipe"]["Schall-armoured-cargo-wagon-mk1"]
    mk2armouredCargoRefRecipe = data.raw["recipe"]["Schall-armoured-cargo-wagon-mk2"]
else
    mk0armouredCargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon"]
    mk1armouredCargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon"]
    mk2armouredCargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon"]
    mk0armouredCargoRefRecipe = data.raw["recipe"]["cargo-wagon"]
    mk1armouredCargoRefRecipe = data.raw["recipe"]["cargo-wagon"]
    mk2armouredCargoRefRecipe = data.raw["recipe"]["cargo-wagon"]
end
if settings.startup["armouredtrain-fluid-wagon-enable"].value then
    mk0armouredFluidRefPrototype = data.raw["fluid-wagon"]["Schall-armoured-fluid-wagon"]
    mk1armouredFluidRefPrototype = data.raw["fluid-wagon"]["Schall-armoured-fluid-wagon-mk1"]
    mk2armouredFluidRefPrototype = data.raw["fluid-wagon"]["Schall-armoured-fluid-wagon-mk2"]
    mk0armouredFluidRefRecipe = data.raw["recipe"]["Schall-armoured-fluid-wagon"]
    mk1armouredFluidRefRecipe = data.raw["recipe"]["Schall-armoured-fluid-wagon-mk1"]
    mk2armouredFluidRefRecipe = data.raw["recipe"]["Schall-armoured-fluid-wagon-mk2"]
else
    mk0armouredFluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon"]
    mk1armouredFluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon"]
    mk2armouredFluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon"]
    mk0armouredFluidRefRecipe = data.raw["recipe"]["fluid-wagon"]
    mk1armouredFluidRefRecipe = data.raw["recipe"]["fluid-wagon"]
    mk2armouredFluidRefRecipe = data.raw["recipe"]["fluid-wagon"]
end

local MakeIdentifierName = function(name, identifier)
    return name .. "-schallarmouredtrain-armouredtrains-" .. identifier
end

local improvementTiers = {}
if settings.startup["armouredtrain-locomotive-enable"].value or settings.startup["armouredtrain-cargo-wagon-enable"].value then
    if improvementTiers["mk0"] == nil then
        improvementTiers["mk0"] = {
            ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk0armouredLocoRefPrototype, {color = {r = 166, g = 166, b = 166}})
        }
    end
    improvementTiers["mk0"]["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk0armouredLocoRefPrototype)
    improvementTiers["mk0"]["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(mk0armouredCargoRefPrototype)
    improvementTiers["mk0"]["cargo-placement"] = {
        prototypeAttributes = {},
        recipe = {
            enabled = false,
            ingredientLists = Utils.GetRecipeIngredientsAddedTogeather(
                {
                    {
                        {
                            {StaticData.MakeName({locoConfiguration = "double_end", unitType = "cargo", type = "placement"}), 1}
                        },
                        "add",
                        1
                    },
                    {
                        mk0armouredLocoRefRecipe,
                        "add",
                        2
                    },
                    {
                        mk0armouredCargoRefRecipe,
                        "highest",
                        2
                    },
                    {
                        {
                            {"locomotive", 10},
                            {"cargo-wagon", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            energyLists = {
                ingredients = Utils.GetRecipeAttribute(mk0armouredLocoRefRecipe, "energy_required", "ingredients", 0.5) * 2,
                normal = Utils.GetRecipeAttribute(mk0armouredLocoRefRecipe, "energy_required", "normal", 0.5) * 2,
                expensive = Utils.GetRecipeAttribute(mk0armouredLocoRefRecipe, "energy_required", "expensive", 0.5) * 2
            }
        },
        unlockTech = "Schall-armoured-cargo-wagon-0"
    }
end
if settings.startup["armouredtrain-locomotive-enable"].value or settings.startup["armouredtrain-fluid-wagon-enable"].value then
    if improvementTiers["mk0"] == nil then
        improvementTiers["mk0"] = {
            ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk0armouredLocoRefPrototype, {color = {r = 166, g = 166, b = 166}})
        }
    end
    improvementTiers["mk0"]["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk0armouredLocoRefPrototype)
    improvementTiers["mk0"]["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(mk0armouredFluidRefPrototype)
    improvementTiers["mk0"]["fluid-placement"] = {
        prototypeAttributes = {},
        recipe = {
            enabled = false,
            ingredientLists = Utils.GetRecipeIngredientsAddedTogeather(
                {
                    {
                        {
                            {StaticData.MakeName({locoConfiguration = "double_end", unitType = "fluid", type = "placement"}), 1}
                        },
                        "add",
                        1
                    },
                    {
                        mk0armouredLocoRefRecipe,
                        "add",
                        2
                    },
                    {
                        mk0armouredFluidRefRecipe,
                        "highest",
                        2
                    },
                    {
                        {
                            {"locomotive", 10},
                            {"fluid-wagon", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            energyLists = {
                ingredients = Utils.GetRecipeAttribute(mk0armouredLocoRefRecipe, "energy_required", "ingredients", 0.5) * 2,
                normal = Utils.GetRecipeAttribute(mk0armouredLocoRefRecipe, "energy_required", "normal", 0.5) * 2,
                expensive = Utils.GetRecipeAttribute(mk0armouredLocoRefRecipe, "energy_required", "expensive", 0.5) * 2
            }
        },
        unlockTech = "Schall-armoured-fluid-wagon-0"
    }
end
--[[,
    mk1 = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk2LocoRefPrototype, {color = {r = 0.66, g = 0.24, b = 0.75}}),
        ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk2LocoRefPrototype),
        ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(mk2CargoRefPrototype),
        ["cargo-placement"] = {
            prototypeAttributes = {},
            recipe = {
                enabled = false,
                ingredientLists = Utils.GetRecipeIngredientsAddedTogeather(
                    {
                        {
                            {
                                {MakeIdentifierName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "cargo", type = "placement"}), "mk1"), 1}
                            },
                            "add",
                            1
                        },
                        {
                            mk2LocoRefRecipe,
                            "add",
                            2
                        },
                        {
                            mk2CargoRefRecipe,
                            "highest",
                            2
                        },
                        {
                            {
                                {"locomotive-mk1", 10},
                                {"cargo-wagon-mk1", 10}
                            },
                            "subtract",
                            1
                        }
                    }
                ),
                energyLists = {
                    ingredients = Utils.GetRecipeAttribute(mk2LocoRefRecipe, "energy_required", "ingredients", 0.5) * 2,
                    normal = Utils.GetRecipeAttribute(mk2LocoRefRecipe, "energy_required", "normal", 0.5) * 2,
                    expensive = Utils.GetRecipeAttribute(mk2LocoRefRecipe, "energy_required", "expensive", 0.5) * 2
                }
            },
            unlockTech = "high-teir-trains-mk2"
        },
        ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk2LocoRefPrototype),
        ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(mk2FluidRefPrototype),
        ["fluid-placement"] = {
            prototypeAttributes = {},
            recipe = {
                enabled = false,
                ingredientLists = Utils.GetRecipeIngredientsAddedTogeather(
                    {
                        {
                            {
                                {MakeIdentifierName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "fluid", type = "placement"}), "mk1"), 1}
                            },
                            "add",
                            1
                        },
                        {
                            mk2LocoRefRecipe,
                            "add",
                            2
                        },
                        {
                            mk2FluidRefRecipe,
                            "highest",
                            2
                        },
                        {
                            {
                                {"locomotive-mk1", 10},
                                {"fluid-wagon-mk1", 10}
                            },
                            "subtract",
                            1
                        }
                    }
                ),
                energyLists = {
                    ingredients = Utils.GetRecipeAttribute(mk2LocoRefRecipe, "energy_required", "ingredients", 0.5) * 2,
                    normal = Utils.GetRecipeAttribute(mk2LocoRefRecipe, "energy_required", "normal", 0.5) * 2,
                    expensive = Utils.GetRecipeAttribute(mk2LocoRefRecipe, "energy_required", "expensive", 0.5) * 2
                }
            },
            unlockTech = "high-teir-trains-mk2"
        }
    },
    mk2 = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk2LocoRefPrototype, {color = {r = 0.66, g = 0.24, b = 0.75}}),
        ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk2LocoRefPrototype),
        ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(mk2CargoRefPrototype),
        ["cargo-placement"] = {
            prototypeAttributes = {},
            recipe = {
                enabled = false,
                ingredientLists = Utils.GetRecipeIngredientsAddedTogeather(
                    {
                        {
                            {
                                {MakeIdentifierName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "cargo", type = "placement"}), "mk1"), 1}
                            },
                            "add",
                            1
                        },
                        {
                            mk2LocoRefRecipe,
                            "add",
                            2
                        },
                        {
                            mk2CargoRefRecipe,
                            "highest",
                            2
                        },
                        {
                            {
                                {"locomotive-mk1", 10},
                                {"cargo-wagon-mk1", 10}
                            },
                            "subtract",
                            1
                        }
                    }
                ),
                energyLists = {
                    ingredients = Utils.GetRecipeAttribute(mk2LocoRefRecipe, "energy_required", "ingredients", 0.5) * 2,
                    normal = Utils.GetRecipeAttribute(mk2LocoRefRecipe, "energy_required", "normal", 0.5) * 2,
                    expensive = Utils.GetRecipeAttribute(mk2LocoRefRecipe, "energy_required", "expensive", 0.5) * 2
                }
            },
            unlockTech = "high-teir-trains-mk2"
        },
        ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk2LocoRefPrototype),
        ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(mk2FluidRefPrototype),
        ["fluid-placement"] = {
            prototypeAttributes = {},
            recipe = {
                enabled = false,
                ingredientLists = Utils.GetRecipeIngredientsAddedTogeather(
                    {
                        {
                            {
                                {MakeIdentifierName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "fluid", type = "placement"}), "mk1"), 1}
                            },
                            "add",
                            1
                        },
                        {
                            mk2LocoRefRecipe,
                            "add",
                            2
                        },
                        {
                            mk2FluidRefRecipe,
                            "highest",
                            2
                        },
                        {
                            {
                                {"locomotive-mk1", 10},
                                {"fluid-wagon-mk1", 10}
                            },
                            "subtract",
                            1
                        }
                    }
                ),
                energyLists = {
                    ingredients = Utils.GetRecipeAttribute(mk2LocoRefRecipe, "energy_required", "ingredients", 0.5) * 2,
                    normal = Utils.GetRecipeAttribute(mk2LocoRefRecipe, "energy_required", "normal", 0.5) * 2,
                    expensive = Utils.GetRecipeAttribute(mk2LocoRefRecipe, "energy_required", "expensive", 0.5) * 2
                }
            },
            unlockTech = "high-teir-trains-mk2"
        }
    }--]]
--77 color mk2
local subgroup = "transport"
if mods["SchallTransportGroup"] then
    subgroup = "vehicles-railway"
end
SharedFunctions.MakeModdedVariations(improvementTiers, MakeIdentifierName, {subgroup = subgroup, orderPrefix = "a[train-system]-"})
