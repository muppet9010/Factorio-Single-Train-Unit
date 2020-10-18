local Utils = require("utility/utils")
local StaticData = require("static-data")

if not mods["trainConstructionMod"] then
    return
end

-- Remove our default added recipes for Train Construction Site mod as it makes a loop and crashs game on startup otherwis.
local effectIndex = Utils.GetTableKeyWithInnerKeyValue(data.raw["technology"]["railway"].effects, "recipe", StaticData.DoubleEndCargoPlacement.name)
if effectIndex ~= nil then
    data.raw["technology"]["railway"].effects[effectIndex] = nil
end

effectIndex = Utils.GetTableKeyWithInnerKeyValue(data.raw["technology"]["fluid-wagon"].effects, "recipe", StaticData.DoubleEndFluidPlacement.name)
if effectIndex ~= nil then
    data.raw["technology"]["fluid-wagon"].effects[effectIndex] = nil
end
