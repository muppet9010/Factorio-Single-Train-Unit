local Utils = require("utility/utils")
local StaticData = require("static-data")
local SharedFunctions = require("prototypes.shared-functions")

if not mods["SchallArmouredTrain"] then
    return
end
if settings.startup["armouredtrain-locomotive-enable"].value == false or (settings.startup["armouredtrain-cargo-wagon-enable"].value == false and settings.startup["armouredtrain-fluid-wagon-enable"].value == false) then
    -- If both the loco and one or more wagon types isn't enabled in the mod then we don't have a complete armoured vresion to add.
    return
end

local mk0armouredLocoRefPrototype = data.raw["locomotive"]["Schall-armoured-locomotive"]
local mk1armouredLocoRefPrototype = data.raw["locomotive"]["Schall-armoured-locomotive-mk1"]
local mk2armouredLocoRefPrototype = data.raw["locomotive"]["Schall-armoured-locomotive-mk2"]
local mk0armouredLocoRefRecipe = data.raw["recipe"]["Schall-armoured-locomotive"]
local mk1armouredLocoRefRecipe = data.raw["recipe"]["Schall-armoured-locomotive-mk1"]
local mk2armouredLocoRefRecipe = data.raw["recipe"]["Schall-armoured-locomotive-mk2"]
local mk0armouredCargoRefPrototype = data.raw["cargo-wagon"]["Schall-armoured-cargo-wagon"]
local mk1armouredCargoRefPrototype = data.raw["cargo-wagon"]["Schall-armoured-cargo-wagon-mk1"]
local mk2armouredCargoRefPrototype = data.raw["cargo-wagon"]["Schall-armoured-cargo-wagon-mk2"]
local mk0armouredCargoRefRecipe = data.raw["recipe"]["Schall-armoured-cargo-wagon"]
local mk1armouredCargoRefRecipe = data.raw["recipe"]["Schall-armoured-cargo-wagon-mk1"]
local mk2armouredCargoRefRecipe = data.raw["recipe"]["Schall-armoured-cargo-wagon-mk2"]
local mk0armouredFluidRefPrototype = data.raw["fluid-wagon"]["Schall-armoured-fluid-wagon"]
local mk1armouredFluidRefPrototype = data.raw["fluid-wagon"]["Schall-armoured-fluid-wagon-mk1"]
local mk2armouredFluidRefPrototype = data.raw["fluid-wagon"]["Schall-armoured-fluid-wagon-mk2"]
local mk0armouredFluidRefRecipe = data.raw["recipe"]["Schall-armoured-fluid-wagon"]
local mk1armouredFluidRefRecipe = data.raw["recipe"]["Schall-armoured-fluid-wagon-mk1"]
local mk2armouredFluidRefRecipe = data.raw["recipe"]["Schall-armoured-fluid-wagon-mk2"]

local MakeIdentifierName = function(name, identifier)
    return name .. "-schallarmouredtrain-armouredtrains-" .. identifier
end

local improvementTiers = {
    mk0 = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk0armouredLocoRefPrototype, {color = {r = 150, g = 150, b = 150}})
    },
    mk1 = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk1armouredLocoRefPrototype, {color = {r = 110, g = 110, b = 110}})
    },
    mk2 = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk2armouredLocoRefPrototype, {color = {r = 70, g = 70, b = 70}})
    }
}
local armouredCargoImprovementTiers, armouredFluidImprovementTiers
if settings.startup["armouredtrain-locomotive-enable"].value and settings.startup["armouredtrain-cargo-wagon-enable"].value then
    armouredCargoImprovementTiers = {
        mk0 = {
            ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk0armouredLocoRefPrototype),
            ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(mk0armouredCargoRefPrototype),
            ["cargo-placement"] = {
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
        },
        mk1 = {
            ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk1armouredLocoRefPrototype),
            ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(mk1armouredCargoRefPrototype),
            ["cargo-placement"] = {
                prototypeAttributes = {},
                recipe = {
                    enabled = false,
                    ingredientLists = Utils.GetRecipeIngredientsAddedTogeather(
                        {
                            {
                                {
                                    {MakeIdentifierName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "cargo", type = "placement"}), "mk0"), 1}
                                },
                                "add",
                                1
                            },
                            {
                                mk1armouredLocoRefRecipe,
                                "add",
                                2
                            },
                            {
                                mk1armouredCargoRefRecipe,
                                "highest",
                                2
                            },
                            {
                                {
                                    {"Schall-armoured-locomotive", 10},
                                    {"Schall-armoured-cargo-wagon", 10}
                                },
                                "subtract",
                                1
                            }
                        }
                    ),
                    energyLists = {
                        ingredients = Utils.GetRecipeAttribute(mk1armouredLocoRefRecipe, "energy_required", "ingredients", 0.5) * 2,
                        normal = Utils.GetRecipeAttribute(mk1armouredLocoRefRecipe, "energy_required", "normal", 0.5) * 2,
                        expensive = Utils.GetRecipeAttribute(mk1armouredLocoRefRecipe, "energy_required", "expensive", 0.5) * 2
                    }
                },
                unlockTech = "Schall-armoured-cargo-wagon-1"
            }
        },
        mk2 = {
            ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk2armouredLocoRefPrototype),
            ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(mk2armouredCargoRefPrototype),
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
                                mk2armouredLocoRefRecipe,
                                "add",
                                2
                            },
                            {
                                mk2armouredCargoRefRecipe,
                                "highest",
                                2
                            },
                            {
                                {
                                    {"Schall-armoured-locomotive-mk1", 10},
                                    {"Schall-armoured-cargo-wagon-mk1", 10}
                                },
                                "subtract",
                                1
                            }
                        }
                    ),
                    energyLists = {
                        ingredients = Utils.GetRecipeAttribute(mk2armouredLocoRefRecipe, "energy_required", "ingredients", 0.5) * 2,
                        normal = Utils.GetRecipeAttribute(mk2armouredLocoRefRecipe, "energy_required", "normal", 0.5) * 2,
                        expensive = Utils.GetRecipeAttribute(mk2armouredLocoRefRecipe, "energy_required", "expensive", 0.5) * 2
                    }
                },
                unlockTech = "Schall-armoured-cargo-wagon-2"
            }
        }
    }
end
if settings.startup["armouredtrain-locomotive-enable"].value and settings.startup["armouredtrain-fluid-wagon-enable"].value then
    armouredFluidImprovementTiers = {
        mk0 = {
            ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk0armouredLocoRefPrototype),
            ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(mk0armouredFluidRefPrototype),
            ["fluid-placement"] = {
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
        },
        mk1 = {
            ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk1armouredLocoRefPrototype),
            ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(mk1armouredFluidRefPrototype),
            ["fluid-placement"] = {
                prototypeAttributes = {},
                recipe = {
                    enabled = false,
                    ingredientLists = Utils.GetRecipeIngredientsAddedTogeather(
                        {
                            {
                                {
                                    {MakeIdentifierName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "fluid", type = "placement"}), "mk0"), 1}
                                },
                                "add",
                                1
                            },
                            {
                                mk1armouredLocoRefRecipe,
                                "add",
                                2
                            },
                            {
                                mk1armouredFluidRefRecipe,
                                "highest",
                                2
                            },
                            {
                                {
                                    {"Schall-armoured-locomotive", 10},
                                    {"Schall-armoured-fluid-wagon", 10}
                                },
                                "subtract",
                                1
                            }
                        }
                    ),
                    energyLists = {
                        ingredients = Utils.GetRecipeAttribute(mk1armouredLocoRefRecipe, "energy_required", "ingredients", 0.5) * 2,
                        normal = Utils.GetRecipeAttribute(mk1armouredLocoRefRecipe, "energy_required", "normal", 0.5) * 2,
                        expensive = Utils.GetRecipeAttribute(mk1armouredLocoRefRecipe, "energy_required", "expensive", 0.5) * 2
                    }
                },
                unlockTech = "Schall-armoured-fluid-wagon-1"
            }
        },
        mk2 = {
            ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk2armouredLocoRefPrototype),
            ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(mk2armouredFluidRefPrototype),
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
                                mk2armouredLocoRefRecipe,
                                "add",
                                2
                            },
                            {
                                mk2armouredFluidRefRecipe,
                                "highest",
                                2
                            },
                            {
                                {
                                    {"Schall-armoured-locomotive-mk1", 10},
                                    {"Schall-armoured-fluid-wagon-mk1", 10}
                                },
                                "subtract",
                                1
                            }
                        }
                    ),
                    energyLists = {
                        ingredients = Utils.GetRecipeAttribute(mk2armouredLocoRefRecipe, "energy_required", "ingredients", 0.5) * 2,
                        normal = Utils.GetRecipeAttribute(mk2armouredLocoRefRecipe, "energy_required", "normal", 0.5) * 2,
                        expensive = Utils.GetRecipeAttribute(mk2armouredLocoRefRecipe, "energy_required", "expensive", 0.5) * 2
                    }
                },
                unlockTech = "Schall-armoured-fluid-wagon-2"
            }
        }
    }
end
improvementTiers = Utils.TableMerge({improvementTiers, armouredCargoImprovementTiers, armouredFluidImprovementTiers})

local subgroup = "transport"
if mods["SchallTransportGroup"] then
    subgroup = "vehicles-railway"
end

SharedFunctions.MakeModdedVariations(improvementTiers, MakeIdentifierName, {subgroup = subgroup, orderPrefix = "a[train-system]-"})
