local Utils = require("utility/utils")
local StaticData = require("static-data")
local SharedFunctions = require("prototypes.shared-functions")

if not mods["Krastorio2"] then
    return
end
if data.raw["locomotive"]["kr-nuclear-locomotive"] == nil then
    return -- added locos are optional from the look of it.
end

local nuclearLocoRefPrototype = data.raw["locomotive"]["kr-nuclear-locomotive"]
local nuclearLocoRefRecipe = data.raw["recipe"]["kr-nuclear-locomotive"]
local refCargoWagonPrototype = data.raw["cargo-wagon"]["cargo-wagon"]
local refCargoWagonRecipe = data.raw["recipe"]["cargo-wagon"]
local refFluidWagonPrototype = data.raw["fluid-wagon"]["fluid-wagon"]
local refFluidWagonRecipe = data.raw["recipe"]["fluid-wagon"]

local MakeIdentifierName = function(name, identifier)
    return name .. "-krastorio2-" .. identifier
end

local locoBurnerEffectivityMultiplier = settings.startup["single_train_unit-burner_effectivity_percentage"].value / 100

local improvementTiers = {
    nuclear = {
        ["generic"] = SharedFunctions.GetGenericSettingsFromReference(nuclearLocoRefPrototype, {color = {r = 60, g = 170, b = 25}}),
        ["cargo-loco"] = SharedFunctions.GetLocoSettingsFromReference(
            nuclearLocoRefPrototype,
            {
                burner = {
                    fuel_category = nuclearLocoRefPrototype.burner.fuel_category,
                    effectivity = nuclearLocoRefPrototype.burner.effectivity * locoBurnerEffectivityMultiplier,
                    fuel_inventory_size = nuclearLocoRefPrototype.burner.fuel_inventory_size,
                    burnt_inventory_size = nuclearLocoRefPrototype.burner.burnt_inventory_size,
                    smoke = nuclearLocoRefPrototype.burner.smoke
                }
            }
        ),
        ["cargo-wagon"] = SharedFunctions.GetCargoSettingsFromReference(refCargoWagonPrototype),
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
                            refCargoWagonRecipe,
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
                energyLists = {
                    ingredients = Utils.GetRecipeAttribute(nuclearLocoRefRecipe, "energy_required", "ingredients") * 2,
                    normal = Utils.GetRecipeAttribute(nuclearLocoRefRecipe, "energy_required", "normal") * 2,
                    expensive = Utils.GetRecipeAttribute(nuclearLocoRefRecipe, "energy_required", "expensive") * 2
                }
            },
            unlockTech = "kr-nuclear-locomotive"
        },
        ["fluid-loco"] = SharedFunctions.GetLocoSettingsFromReference(
            nuclearLocoRefPrototype,
            {
                burner = {
                    fuel_category = nuclearLocoRefPrototype.burner.fuel_category,
                    effectivity = nuclearLocoRefPrototype.burner.effectivity * locoBurnerEffectivityMultiplier,
                    fuel_inventory_size = nuclearLocoRefPrototype.burner.fuel_inventory_size,
                    burnt_inventory_size = nuclearLocoRefPrototype.burner.burnt_inventory_size,
                    smoke = nuclearLocoRefPrototype.burner.smoke
                }
            }
        ),
        ["fluid-wagon"] = SharedFunctions.GetFluidSettingsFromReference(refFluidWagonPrototype),
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
                            refFluidWagonRecipe,
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
                energyLists = {
                    ingredients = Utils.GetRecipeAttribute(nuclearLocoRefRecipe, "energy_required", "ingredients") * 2,
                    normal = Utils.GetRecipeAttribute(nuclearLocoRefRecipe, "energy_required", "normal") * 2,
                    expensive = Utils.GetRecipeAttribute(nuclearLocoRefRecipe, "energy_required", "expensive") * 2
                }
            },
            unlockTech = "kr-nuclear-locomotive"
        }
    }
}

SharedFunctions.MakeModdedVariations(improvementTiers, MakeIdentifierName, {subgroup = "transport", orderPrefix = "a[train-system]-f[nuclear-locomotive.png]"})
