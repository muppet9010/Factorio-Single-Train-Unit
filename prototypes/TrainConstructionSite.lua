local Utils = require("utility/utils")
local StaticData = require("static-data")

if not mods["space-exploration"] then
    return
end

-- Remove our default added recipes for Train Construction Site mod as it makes a loop and crashs game on startup otherwis.
local effectIndex = Utils.GetTableKeyWithInnerKeyValue(data.raw["technology"]["railway"].effects, "recipe", StaticData.DoubleEndCargoPlacement.name)
data.raw["technology"]["railway"].effects[effectIndex] = nil
effectIndex = Utils.GetTableKeyWithInnerKeyValue(data.raw["technology"]["fluid-wagon"].effects, "recipe", StaticData.DoubleEndFluidPlacement.name)
data.raw["technology"]["fluid-wagon"].effects[effectIndex] = nil
