local Utils = require("utility/utils")
local StaticData = require("static-data")
local SharedFunctions = require("prototypes.shared-functions")

if not mods["SchallArmouredTrain"] then
    return
end
if settings.startup["armouredtrain-nuclear-locomotive-enable"].value == false then
    return
end

local nuclearLocoRefPrototype = data.raw["locomotive"]["Schall-nuclear-locomotive"]
local nuclearLocoRefRecipe = data.raw["recipe"]["Schall-nuclear-locomotive"]
local cargoRefPrototype = data.raw["cargo-wagon"]["cargo-wagon"]
local fluidRefPrototype = data.raw["fluid-wagon"]["fluid-wagon"]

local MakeIdentifierName = function(name, identifier)
    return name .. "-schallarmouredtrain-" .. identifier
end

local improvementTiers = {
    nuclear = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(nuclearLocoRefPrototype, {color = {r = 63, g = 255, b = 63}}),
        ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(nuclearLocoRefPrototype),
        ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(cargoRefPrototype),
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
                            nuclearLocoRefRecipe,
                            "add",
                            2
                        },
                        {
                            {
                                {"locomotive", 10}
                            },
                            "subtract",
                            1
                        }
                    }
                ),
                energyLists = {
                    ingredients = Utils.GetRecipeAttribute(nuclearLocoRefRecipe, "energy_required", "ingredients", 0.5) * 2,
                    normal = Utils.GetRecipeAttribute(nuclearLocoRefRecipe, "energy_required", "normal", 0.5) * 2,
                    expensive = Utils.GetRecipeAttribute(nuclearLocoRefRecipe, "energy_required", "expensive", 0.5) * 2
                }
            },
            unlockTech = "Schall-nuclear-locomotive"
        },
        ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(nuclearLocoRefPrototype),
        ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(fluidRefPrototype),
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
                            nuclearLocoRefRecipe,
                            "add",
                            2
                        },
                        {
                            {
                                {"locomotive", 10}
                            },
                            "subtract",
                            1
                        }
                    }
                ),
                energyLists = {
                    ingredients = Utils.GetRecipeAttribute(nuclearLocoRefRecipe, "energy_required", "ingredients", 0.5) * 2,
                    normal = Utils.GetRecipeAttribute(nuclearLocoRefRecipe, "energy_required", "normal", 0.5) * 2,
                    expensive = Utils.GetRecipeAttribute(nuclearLocoRefRecipe, "energy_required", "expensive", 0.5) * 2
                }
            },
            unlockTech = "Schall-nuclear-locomotive"
        }
    }
}

local subgroup = "transport"
if mods["SchallTransportGroup"] then
    subgroup = "vehicles-railway"
end

SharedFunctions.MakeModdedVariations(improvementTiers, MakeIdentifierName, {subgroup = subgroup, orderPrefix = "a[train-system]-"})
