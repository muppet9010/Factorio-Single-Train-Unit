local Utils = require("utility/utils")
local StaticData = require("static-data")
local SharedFunctions = require("prototypes.shared-functions")

if not mods["FactorioExtended-Trains"] then
    return
end

local mk1LocoRefPrototype = data.raw["locomotive"]["locomotive-1"]
local mk2LocoRefPrototype = data.raw["locomotive"]["locomotive-2"]
local mk3LocoRefPrototype = data.raw["locomotive"]["locomotive-3"]
local mk1CargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon-1"]
local mk2CargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon-2"]
local mk3CargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon-3"]
local mk1FluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon-1"]
local mk2FluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon-2"]
local mk3FluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon-3"]
local mk1LocoRefRecipe = data.raw["recipe"]["locomotive-1"]
local mk2LocoRefRecipe = data.raw["recipe"]["locomotive-2"]
local mk3LocoRefRecipe = data.raw["recipe"]["locomotive-3"]
local mk1CargoRefRecipe = data.raw["recipe"]["cargo-wagon-1"]
local mk2CargoRefRecipe = data.raw["recipe"]["cargo-wagon-2"]
local mk3CargoRefRecipe = data.raw["recipe"]["cargo-wagon-3"]
local mk1FluidRefRecipe = data.raw["recipe"]["fluid-wagon-1"]
local mk2FluidRefRecipe = data.raw["recipe"]["fluid-wagon-2"]
local mk3FluidRefRecipe = data.raw["recipe"]["fluid-wagon-3"]

local MakeIdentifierName = function(name, identifier)
    return name .. "-factorio_extended_trains-" .. identifier
end

local improvementTiers = {
    mk1 = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk1LocoRefPrototype, {color = {r = 124, g = 17, b = 15, a = 204}}),
        ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk1LocoRefPrototype),
        ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(mk1CargoRefPrototype),
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
                        mk1LocoRefRecipe,
                        "add",
                        2
                    },
                    {
                        mk1CargoRefRecipe,
                        "highest",
                        1
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
            unlockTech = "stainless-steel-trains"
        },
        ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk1LocoRefPrototype),
        ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(mk1FluidRefPrototype),
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
                        mk1LocoRefRecipe,
                        "add",
                        2
                    },
                    {
                        mk1FluidRefRecipe,
                        "highest",
                        1
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
            unlockTech = "stainless-steel-trains"
        }
    },
    mk2 = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk2LocoRefPrototype, {color = {r = 12, g = 76, b = 22, a = 204}}),
        ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk2LocoRefPrototype),
        ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(mk2CargoRefPrototype),
        ["cargo-placement"] = {
            prototypeAttributes = {},
            recipe = Utils.GetRecipeIngredientsAddedTogeather(
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
                        1
                    },
                    {
                        {
                            {"locomotive-1", 10},
                            {"cargo-wagon-1", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            unlockTech = "titanium-trains"
        },
        ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(mk2LocoRefPrototype),
        ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(mk2FluidRefPrototype),
        ["fluid-placement"] = {
            prototypeAttributes = {},
            recipe = Utils.GetRecipeIngredientsAddedTogeather(
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
                        1
                    },
                    {
                        {
                            {"locomotive-1", 10},
                            {"fluid-wagon-1", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            unlockTech = "titanium-trains"
        }
    },
    mk3 = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(mk3LocoRefPrototype, {color = {r = 113, g = 22, b = 88, a = 204}}),
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
                        1
                    },
                    {
                        {
                            {"locomotive-2", 10},
                            {"cargo-wagon-2", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            unlockTech = "graphene-trains"
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
                        1
                    },
                    {
                        {
                            {"locomotive-2", 10},
                            {"fluid-wagon-2", 10}
                        },
                        "subtract",
                        1
                    }
                }
            ),
            unlockTech = "graphene-trains"
        }
    }
}

SharedFunctions.MakeModdedVariations(improvementTiers, MakeIdentifierName, {subgroup = "fb-trains", orderPrefix = "a-c"})
