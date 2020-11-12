local Utils = require("utility/utils")
local StaticData = require("static-data")
local SharedFunctions = require("prototypes.shared-functions")

if not mods["zombiesextended-logistics"] then
    return
end

local mk1LocoRefPrototype = data.raw["locomotive"]["locomotive-mk1"]
local mk2LocoRefPrototype = data.raw["locomotive"]["locomotive-mk2"]
local mk1CargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon-mk1"]
local mk2CargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon-mk2"]
local mk1FluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon-mk1"]
local mk2FluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon-mk2"]
local mk1LocoRefRecipe = data.raw["recipe"]["locomotive-mk1"]
local mk2LocoRefRecipe = data.raw["recipe"]["locomotive-mk2"]
local mk1CargoRefRecipe = data.raw["recipe"]["cargo-wagon-mk1"]
local mk2CargoRefRecipe = data.raw["recipe"]["cargo-wagon-mk2"]
local mk1FluidRefRecipe = data.raw["recipe"]["fluid-wagon-mk1"]
local mk2FluidRefRecipe = data.raw["recipe"]["fluid-wagon-mk2"]

local MakeIdentifierName = function(name, identifier)
    return name .. "-zombiesextended_logistics-" .. identifier
end

local improvementTiers = {
    mk1 = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk1LocoRefPrototype, {color = {r = 0.24, g = 0.25, b = 0.75}}),
        ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk1LocoRefPrototype),
        ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(mk1CargoRefPrototype),
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
                            mk1LocoRefRecipe,
                            "add",
                            2
                        },
                        {
                            mk1CargoRefRecipe,
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
                    ingredients = Utils.GetRecipeAttribute(mk1LocoRefRecipe, "energy_required", "ingredients", 0.5) * 2,
                    normal = Utils.GetRecipeAttribute(mk1LocoRefRecipe, "energy_required", "normal", 0.5) * 2,
                    expensive = Utils.GetRecipeAttribute(mk1LocoRefRecipe, "energy_required", "expensive", 0.5) * 2
                }
            },
            unlockTech = "high-teir-trains-mk1"
        },
        ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk1LocoRefPrototype),
        ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(mk1FluidRefPrototype),
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
                            mk1LocoRefRecipe,
                            "add",
                            2
                        },
                        {
                            mk1FluidRefRecipe,
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
                    ingredients = Utils.GetRecipeAttribute(mk1LocoRefRecipe, "energy_required", "ingredients", 0.5) * 2,
                    normal = Utils.GetRecipeAttribute(mk1LocoRefRecipe, "energy_required", "normal", 0.5) * 2,
                    expensive = Utils.GetRecipeAttribute(mk1LocoRefRecipe, "energy_required", "expensive", 0.5) * 2
                }
            },
            unlockTech = "high-teir-trains-mk1"
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
    }
}

SharedFunctions.MakeModdedVariations(improvementTiers, MakeIdentifierName, {subgroup = "ds-trains", orderPrefix = "d"})
