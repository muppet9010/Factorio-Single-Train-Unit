--[[
    Can get random biter types and worm type for specified evolution level.
]]
local Utils = require("utility/utils")
--local Logging = require("utility/logging")

local BiterSelection = {}

function BiterSelection.GetBiterType(probabilityGlobalName, spawnerType, evolution)
    --probabilityGlobalName is a name for tracking this biter evolution probability line. Use unique names if different evolutions are being tracked.
    global.UTILITYBITERSELECTION = global.UTILITYBITERSELECTION or {}
    global.UTILITYBITERSELECTION[probabilityGlobalName] = global.UTILITYBITERSELECTION[probabilityGlobalName] or {}
    local modEnemyProbabilities = global.UTILITYBITERSELECTION[probabilityGlobalName]
    if modEnemyProbabilities[spawnerType] == nil then
        modEnemyProbabilities[spawnerType] = {}
    end
    evolution = Utils.RoundNumberToDecimalPlaces(evolution, 2)
    if modEnemyProbabilities[spawnerType].calculatedEvolution == nil or modEnemyProbabilities[spawnerType].calculatedEvolution ~= evolution then
        modEnemyProbabilities[spawnerType].calculatedEvolution = evolution
        modEnemyProbabilities[spawnerType].probabilities = BiterSelection._CalculateSpecificBiterSelectionProbabilities(spawnerType, evolution)
    end
    return Utils.GetRandomEntryFromNormalisedDataSet(modEnemyProbabilities[spawnerType].probabilities, "chance").unit
end

function BiterSelection._CalculateSpecificBiterSelectionProbabilities(spawnerType, currentEvolution)
    local rawUnitProbs = game.entity_prototypes[spawnerType].result_units
    local currentEvolutionProbabilities = {}
    for _, possibility in pairs(rawUnitProbs) do
        local startSpawnPointIndex = nil
        for spawnPointIndex, spawnPoint in pairs(possibility.spawn_points) do
            if spawnPoint.evolution_factor <= currentEvolution then
                startSpawnPointIndex = spawnPointIndex
            end
        end
        if startSpawnPointIndex ~= nil then
            local startSpawnPoint = possibility.spawn_points[startSpawnPointIndex]
            local endSpawnPoint
            if possibility.spawn_points[startSpawnPointIndex + 1] ~= nil then
                endSpawnPoint = possibility.spawn_points[startSpawnPointIndex + 1]
            else
                endSpawnPoint = {evolution_factor = 1.0, weight = startSpawnPoint.weight}
            end

            local weight
            if startSpawnPoint.evolution_factor ~= endSpawnPoint.evolution_factor then
                local evoRange = endSpawnPoint.evolution_factor - startSpawnPoint.evolution_factor
                local weightRange = endSpawnPoint.weight - startSpawnPoint.weight
                local evoRangeMultiplier = (currentEvolution - startSpawnPoint.evolution_factor) / evoRange
                weight = (weightRange * evoRangeMultiplier) + startSpawnPoint.weight
            else
                weight = startSpawnPoint.weight
            end
            table.insert(currentEvolutionProbabilities, {chance = weight, unit = possibility.unit})
        end
    end
    local normalisedcurrentEvolutionProbabilities = Utils.NormaliseChanceList(currentEvolutionProbabilities, "chance")
    return normalisedcurrentEvolutionProbabilities
end

function BiterSelection.GetWormType(wormEvoGlobalName, evolution)
    --wormEvoGlobalName is a name for tracking this worm evolution line. Use unique names if different evolutions are being tracked.
    global.UTILITYBITERSELECTION = global.UTILITYBITERSELECTION or {}
    global.UTILITYBITERSELECTION[wormEvoGlobalName] = global.UTILITYBITERSELECTION[wormEvoGlobalName] or {}
    local wormEvoType = global.UTILITYBITERSELECTION[wormEvoGlobalName]
    evolution = Utils.RoundNumberToDecimalPlaces(evolution, 2)
    if wormEvoType.calculatedEvolution == nil or wormEvoType.calculatedEvolution ~= evolution then
        wormEvoType.calculatedEvolution = evolution
        wormEvoType.name = BiterSelection._CalculateSpecificWormForEvolution(evolution)
    end
    return wormEvoType.name
end

function BiterSelection._CalculateSpecificWormForEvolution(evolution)
    local turrets = game.get_filtered_entity_prototypes({{filter = "turret"}})
    local enemyTurrets = {}
    for _, turret in pairs(turrets) do
        if turret.subgroup ~= nil and turret.subgroup.name == "enemies" then
            local autoplaceEvo = turret.build_base_evolution_requirement or 0
            if autoplaceEvo <= evolution then
                enemyTurrets[autoplaceEvo] = turret
            end
        end
    end
    local selectedTurret, maxEvo = nil, -1
    for evo, turret in pairs(enemyTurrets) do
        if evo > maxEvo then
            selectedTurret = turret
            maxEvo = evo
        end
    end
    if selectedTurret == nil then
        return nil
    else
        return selectedTurret.name
    end
end

return BiterSelection
