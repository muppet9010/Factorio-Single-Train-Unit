local Utils = require("utility/utils")
local StaticData = require("static-data")
local SharedFunctions = require("prototypes.shared-functions")

if not mods["FactorioExtended-Plus-Transport"] then
    return
end

local mk2LocoRefPrototype = data.raw["locomotive"]["locomotive-mk2"]
local mk3LocoRefPrototype = data.raw["locomotive"]["locomotive-mk3"]
local mk2CargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon-mk2"]
local mk3CargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon-mk3"]
local mk2FluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon-mk2"]
local mk3FluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon-mk3"]
local mk2LocoRefRecipe = data.raw["recipe"]["locomotive-mk2"]
local mk3LocoRefRecipe = data.raw["recipe"]["locomotive-mk3"]
local mk2CargoRefRecipe = data.raw["recipe"]["cargo-wagon-mk2"]
local mk3CargoRefRecipe = data.raw["recipe"]["cargo-wagon-mk3"]
local mk2FluidRefRecipe = data.raw["recipe"]["fluid-wagon-mk2"]
local mk3FluidRefRecipe = data.raw["recipe"]["fluid-wagon-mk3"]

local MakeIdentifierName = function(name, identifier)
    return name .. "-factorio_extended_plus_transport-" .. identifier
end

local improvementTiers = {
    mk2 = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk2LocoRefPrototype, {color = {r = 0.4, g = 0.804, b = 0.667, a = 0.8}}),
        ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk2LocoRefPrototype),
        ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(mk2CargoRefPrototype),
        ["cargo-placement"] = {
            prototypeAttributes = {},
            recipe = Utils.GetRecipeIngredientsAddedTogeather(
                {
                    {
                        {
                            {StaticData.MakeName({locoConfiguration = "double_end", unitType = "cargo", type = "placement"}), 1}
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
                            {"locomotive", 10},
                            {"cargo-wagon", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            unlockTech = "railway-2"
        },
        ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk2LocoRefPrototype),
        ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(mk2FluidRefPrototype),
        ["fluid-placement"] = {
            prototypeAttributes = {},
            recipe = Utils.GetRecipeIngredientsAddedTogeather(
                {
                    {
                        {
                            {StaticData.MakeName({locoConfiguration = "double_end", unitType = "fluid", type = "placement"}), 1}
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
                            {"locomotive", 10},
                            {"fluid-wagon", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            unlockTech = "railway-2"
        }
    },
    mk3 = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk3LocoRefPrototype, {color = {r = 0.690, g = 0.75, b = 1, a = 0.8}}),
        ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk3LocoRefPrototype),
        ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(mk3CargoRefPrototype),
        ["cargo-placement"] = {
            prototypeAttributes = {},
            recipe = Utils.GetRecipeIngredientsAddedTogeather(
                {
                    {
                        {
                            {MakeIdentifierName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "cargo", type = "placement"}), "mk2"), 1}
                        },
                        "add",
                        1
                    },
                    {
                        mk3LocoRefRecipe,
                        "add",
                        2
                    },
                    {
                        mk3CargoRefRecipe,
                        "highest",
                        2
                    },
                    {
                        {
                            {"locomotive-mk2", 10},
                            {"cargo-wagon-mk2", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            unlockTech = "railway-3"
        },
        ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk3LocoRefPrototype),
        ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(mk3FluidRefPrototype),
        ["fluid-placement"] = {
            prototypeAttributes = {},
            recipe = Utils.GetRecipeIngredientsAddedTogeather(
                {
                    {
                        {
                            {MakeIdentifierName(StaticData.MakeName({locoConfiguration = "double_end", unitType = "fluid", type = "placement"}), "mk2"), 1}
                        },
                        "add",
                        1
                    },
                    {
                        mk3LocoRefRecipe,
                        "add",
                        2
                    },
                    {
                        mk3FluidRefRecipe,
                        "highest",
                        2
                    },
                    {
                        {
                            {"locomotive-mk2", 10},
                            {"fluid-wagon-mk2", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            unlockTech = "railway-3"
        }
    }
}

SharedFunctions.MakeModdedVariations(improvementTiers, MakeIdentifierName, {subgroup = "fb-vehicle", orderPrefix = "j"})
