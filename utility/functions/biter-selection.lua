--[[
    Can get random biter types and worm type for specified evolution level.
]]
local Utils = require("utility/utils")

local BiterSelection = {}

function BiterSelection.GetBiterType(probabilityGlobalName, spawnerType, evolution)
    -- probabilityGlobalName option is a name for tracking this biter evolution probability line. Use unique names if different evolutions are being tracked.
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
    -- wormEvoGlobalName parameter is a name for tracking this worm evolution line. Use unique names if different evolutions are being tracked.
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
    local turrets = game.get_filtered_entity_prototypes({{filter = "turret"}, {mode = "and", filter = "build-base-evolution-requirement", comparison = "≤", value = evolution}, {mode = "and", filter = "flag", flag = "placeable-enemy"}, {mode = "and", filter = "flag", flag = "player-creation", invert = true}})
    if #turrets == 0 then
        return nil
    end

    local sortedTurrets = {}
    for _, turret in pairs(turrets) do
        table.insert(sortedTurrets, turret)
    end

    table.sort(
        sortedTurrets,
        function(a, b)
            return a.build_base_evolution_requirement > b.build_base_evolution_requirement
        end
    )
    return sortedTurrets[1].name
end

return BiterSelection
