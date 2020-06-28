local Utils = {}
--local Logging = require("utility/logging")
local factorioUtil = require("__core__/lualib/util")
Utils.DeepCopy = factorioUtil.table.deepcopy
Utils.TableMerge = factorioUtil.merge -- takes an array of tables and returns a new table with copies of their contents

function Utils.KillAllKillableObjectsInArea(surface, positionedBoundingBox, killerEntity, collisionBoxOnlyEntities, force)
    local entitiesFound = surface.find_entities(positionedBoundingBox)
    for k, entity in pairs(entitiesFound) do
        if entity.valid and (force == nil or entity.force == force) then
            if entity.health ~= nil and entity.destructible and ((collisionBoxOnlyEntities and Utils.IsCollisionBoxPopulated(entity.prototype.collision_box)) or (not collisionBoxOnlyEntities)) then
                if killerEntity ~= nil then
                    entity.die("neutral", killerEntity)
                else
                    entity.die("neutral")
                end
            end
        end
    end
end

function Utils.KillAllObjectsInArea(surface, positionedBoundingBox, killerEntity, force)
    local entitiesFound = surface.find_entities(positionedBoundingBox)
    for k, entity in pairs(entitiesFound) do
        if entity.valid and (force == nil or entity.force == force) then
            if entity.destructible then
                if killerEntity ~= nil then
                    entity.die("neutral", killerEntity)
                else
                    entity.die("neutral")
                end
            else
                entity.destroy({dp_cliff_correction = true, raise_destroy = true})
            end
        end
    end
end

function Utils.DestroyAllKillableObjectsInArea(surface, positionedBoundingBox, collisionBoxOnlyEntities, force)
    local entitiesFound = surface.find_entities(positionedBoundingBox)
    for k, entity in pairs(entitiesFound) do
        if entity.valid and (force == nil or entity.force == force) then
            if entity.health ~= nil and entity.destructible and ((collisionBoxOnlyEntities and Utils.IsCollisionBoxPopulated(entity.prototype.collision_box)) or (not collisionBoxOnlyEntities)) then
                entity.destroy({dp_cliff_correction = true, raise_destroy = true})
            end
        end
    end
end

function Utils.DestroyAllObjectsInArea(surface, positionedBoundingBox, force)
    local entitiesFound = surface.find_entities(positionedBoundingBox)
    for k, entity in pairs(entitiesFound) do
        if entity.valid and (force == nil or entity.force == force) then
            entity.destroy({dp_cliff_correction = true, raise_destroy = true})
        end
    end
end

function Utils.IsTableValidPosition(thing)
    if thing.x ~= nil and thing.y ~= nil then
        if type(thing.x) == "number" and type(thing.y) == "number" then
            return true
        else
            return false
        end
    end
    if #thing ~= 2 then
        return false
    end
    if type(thing[1]) == "number" and type(thing[2]) == "number" then
        return true
    else
        return false
    end
end

function Utils.TableToProperPosition(thing)
    if not Utils.IsTableValidPosition(thing) then
        return nil
    elseif thing.x ~= nil and thing.y ~= nil then
        return {x = thing.x, y = thing.y}
    else
        return {x = thing[1], y = thing[2]}
    end
end

function Utils.ApplyBoundingBoxToPosition(centrePos, boundingBox, orientation)
    if orientation == nil or orientation == 0 or orientation == 1 then
        return {
            left_top = {
                x = centrePos.x + boundingBox.left_top.x,
                y = centrePos.y + boundingBox.left_top.y
            },
            right_bottom = {
                x = centrePos.x + boundingBox.right_bottom.x,
                y = centrePos.y + boundingBox.right_bottom.y
            }
        }
    elseif orientation == 0.25 or orientation == 0.5 or orientation == 0.75 then
        local rotatedPoint1 = Utils.RotatePositionAround0(orientation, boundingBox.left_top)
        local rotatedPoint2 = Utils.RotatePositionAround0(orientation, boundingBox.right_bottom)
        local rotatedBoundingBox = Utils.CalculateBoundingBoxFrom2Points(rotatedPoint1, rotatedPoint2)
        return {
            left_top = {
                x = centrePos.x + rotatedBoundingBox.left_top.x,
                y = centrePos.y + rotatedBoundingBox.left_top.y
            },
            right_bottom = {
                x = centrePos.x + rotatedBoundingBox.right_bottom.x,
                y = centrePos.y + rotatedBoundingBox.right_bottom.y
            }
        }
    else
        game.print("Error: Diagonal orientations not supported by Utils.ApplyBoundingBoxToPosition()")
    end
end

function Utils.RoundPosition(pos, numDecimalPlaces)
    return {x = Utils.RoundNumberToDecimalPlaces(pos.x, numDecimalPlaces), y = Utils.RoundNumberToDecimalPlaces(pos.y, numDecimalPlaces)}
end

function Utils.GetChunkPositionForTilePosition(pos)
    return {x = math.floor(pos.x / 32), y = math.floor(pos.y / 32)}
end

function Utils.GetLeftTopTilePositionForChunkPosition(chunkPos)
    return {x = chunkPos.x * 32, y = chunkPos.y * 32}
end

function Utils.RotatePositionAround0(orientation, position)
    local deg = orientation * 360
    local rad = math.rad(deg)
    local cosValue = math.cos(rad)
    local sinValue = math.sin(rad)
    local rotatedX = (position.x * cosValue) - (position.y * sinValue)
    local rotatedY = (position.x * sinValue) + (position.y * cosValue)
    return {x = rotatedX, y = rotatedY}
end

function Utils.CalculateBoundingBoxFrom2Points(point1, point2)
    local minX = nil
    local maxX = nil
    local minY = nil
    local maxY = nil
    if minX == nil or point1.x < minX then
        minX = point1.x
    end
    if maxX == nil or point1.x > maxX then
        maxX = point1.x
    end
    if minY == nil or point1.y < minY then
        minY = point1.y
    end
    if maxY == nil or point1.y > maxY then
        maxY = point1.y
    end
    if minX == nil or point2.x < minX then
        minX = point2.x
    end
    if maxX == nil or point2.x > maxX then
        maxX = point2.x
    end
    if minY == nil or point2.y < minY then
        minY = point2.y
    end
    if maxY == nil or point2.y > maxY then
        maxY = point2.y
    end
    return {left_top = {x = minX, y = minY}, right_bottom = {x = maxX, y = maxY}}
end

function Utils.ApplyOffsetToPosition(position, offset)
    position = Utils.DeepCopy(position)
    if offset == nil then
        return position
    end
    if offset.x ~= nil then
        position.x = position.x + offset.x
    end
    if offset.y ~= nil then
        position.y = position.y + offset.y
    end
    return position
end

function Utils.IsCollisionBoxPopulated(collisionBox)
    if collisionBox == nil then
        return false
    end
    if collisionBox.left_top.x ~= 0 and collisionBox.left_top.y ~= 0 and collisionBox.right_bottom.x ~= 0 and collisionBox.right_bottom.y ~= 0 then
        return true
    else
        return false
    end
end

function Utils.LogisticEquation(index, height, steepness)
    return height / (1 + math.exp(steepness * (index - 0)))
end

function Utils.ExponentialDecayEquation(index, multiplier, scale)
    return multiplier * math.exp(-index * scale)
end

function Utils.RoundNumberToDecimalPlaces(num, numDecimalPlaces)
    local result
    if numDecimalPlaces ~= nil and numDecimalPlaces > 0 then
        local mult = 10 ^ numDecimalPlaces
        result = math.floor(num * mult + 0.5) / mult
    else
        result = math.floor(num + 0.5)
    end
    if result == "nan" then
        result = 0
    end
    return result
end

function Utils.HandleFloatNumberAsChancedValue(value)
    local intValue = math.floor(value)
    local partialValue = value - intValue
    local chancedValue = intValue
    if partialValue ~= 0 then
        local rand = math.random()
        if rand >= partialValue then
            chancedValue = chancedValue + 1
        end
    end
    return chancedValue
end

--This doesn't guarentee correct on some of the edge cases, but is as close as possible assuming that 1/256 is the variance for the same number (Bilka, Dev on Discord)
function Utils.FuzzyCompareDoubles(num1, logic, num2)
    local numDif = num1 - num2
    local variance = 1 / 256
    if logic == "=" then
        if numDif < variance and numDif > -variance then
            return true
        else
            return false
        end
    elseif logic == "!=" then
        if numDif < variance and numDif > -variance then
            return false
        else
            return true
        end
    elseif logic == ">" then
        if numDif > variance then
            return true
        else
            return false
        end
    elseif logic == ">=" then
        if numDif > -variance then
            return true
        else
            return false
        end
    elseif logic == "<" then
        if numDif < -variance then
            return true
        else
            return false
        end
    elseif logic == "<=" then
        if numDif < variance then
            return true
        else
            return false
        end
    end
end

function Utils.GetTableNonNilLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function Utils.GetMaxKey(table)
    local max_key = 0
    for k in pairs(table) do
        if k > max_key then
            max_key = k
        end
    end
    return max_key
end

function Utils.GetTableValueByIndexCount(table, indexCount)
    local count = 0
    for _, v in pairs(table) do
        count = count + 1
        if count == indexCount then
            return v
        end
    end
end

function Utils.CalculateBoundingBoxFromPositionAndRange(position, range)
    return {
        left_top = {
            x = position.x - range,
            y = position.y - range
        },
        right_bottom = {
            x = position.x + range,
            y = position.y + range
        }
    }
end

function Utils.CalculateTilesUnderPositionedBoundingBox(positionedBoundingBox)
    local tiles = {}
    for x = positionedBoundingBox.left_top.x, positionedBoundingBox.right_bottom.x do
        for y = positionedBoundingBox.left_top.y, positionedBoundingBox.right_bottom.y do
            table.insert(tiles, {x = math.floor(x), y = math.floor(y)})
        end
    end
    return tiles
end

function Utils.GetDistance(pos1, pos2)
    local dx = pos1.x - pos2.x
    local dy = pos1.y - pos2.y
    return math.sqrt(dx * dx + dy * dy)
end

function Utils.IsPositionInBoundingBox(position, boundingBox, safeTiling)
    --safeTiling means that the boundingbox can be tiled without risk of an entity on the border being in 2 result sets, i.e. for use on each chunk.
    if safeTiling == nil or not safeTiling then
        if position.x >= boundingBox.left_top.x and position.x <= boundingBox.right_bottom.x and position.y >= boundingBox.left_top.y and position.y <= boundingBox.right_bottom.y then
            return true
        else
            return false
        end
    else
        if position.x > boundingBox.left_top.x and position.x <= boundingBox.right_bottom.x and position.y > boundingBox.left_top.y and position.y <= boundingBox.right_bottom.y then
            return true
        else
            return false
        end
    end
end

function Utils.GetEntityReturnedToInventoryName(entity)
    if entity.prototype.mineable_properties ~= nil and entity.prototype.mineable_properties.products ~= nil and #entity.prototype.mineable_properties.products > 0 then
        return entity.prototype.mineable_properties.products[1].name
    else
        return entity.name
    end
end

function Utils.TableKeyToArray(aTable)
    local newArray = {}
    for key in pairs(aTable) do
        table.insert(newArray, key)
    end
    return newArray
end

function Utils.TableContentsToJSON(target_table, name)
    local tablesLogged = {}
    return Utils._TableContentsToJSON(target_table, name, tablesLogged)
end
function Utils._TableContentsToJSON(target_table, name, tablesLogged, indent, stop_traversing)
    indent = indent or 1
    local indentstring = string.rep(" ", (indent * 4))
    tablesLogged[target_table] = "logged"
    local table_contents = ""
    if Utils.GetTableNonNilLength(target_table) > 0 then
        for k, v in pairs(target_table) do
            local key, value
            if type(k) == "string" or type(k) == "number" or type(k) == "boolean" then
                key = '"' .. tostring(k) .. '"'
            elseif type(k) == "nil" then
                key = '"nil"'
            elseif type(k) == "table" then
                if stop_traversing == true then
                    key = '"CIRCULAR LOOP TABLE"'
                else
                    local sub_stop_traversing = nil
                    if tablesLogged[k] ~= nil then
                        sub_stop_traversing = true
                    end
                    key = "{\r\n" .. Utils._TableContentsToJSON(k, name, tablesLogged, indent + 1, sub_stop_traversing) .. "\r\n" .. indentstring .. "}"
                end
            elseif type(k) == "function" then
                key = '"' .. tostring(k) .. '"'
            else
                key = '"unhandled type: ' .. type(k) .. '"'
            end
            if type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
                value = '"' .. tostring(v) .. '"'
            elseif type(v) == "nil" then
                value = '"nil"'
            elseif type(v) == "table" then
                if stop_traversing == true then
                    value = '"CIRCULAR LOOP TABLE"'
                else
                    local sub_stop_traversing = nil
                    if tablesLogged[v] ~= nil then
                        sub_stop_traversing = true
                    end
                    value = "{\r\n" .. Utils._TableContentsToJSON(v, name, tablesLogged, indent + 1, sub_stop_traversing) .. "\r\n" .. indentstring .. "}"
                end
            elseif type(v) == "function" then
                value = '"' .. tostring(v) .. '"'
            else
                value = '"unhandled type: ' .. type(v) .. '"'
            end
            if table_contents ~= "" then
                table_contents = table_contents .. "," .. "\r\n"
            end
            table_contents = table_contents .. indentstring .. tostring(key) .. ":" .. tostring(value)
        end
    else
        table_contents = indentstring .. '"empty"'
    end
    if indent == 1 then
        local resultString = ""
        if name ~= nil then
            resultString = resultString .. '"' .. name .. '":'
        end
        resultString = resultString .. "{" .. "\r\n" .. table_contents .. "\r\n" .. "}"
        return resultString
    else
        return table_contents
    end
end

function Utils.FormatPositionTableToString(positionTable)
    return positionTable.x .. "," .. positionTable.y
end

function Utils.GetTableKeyWithValue(theTable, value)
    for k, v in pairs(theTable) do
        if v == value then
            return k
        end
    end
    return nil
end

function Utils.GetTableKeyWithInnerKeyValue(theTable, key, value)
    for i, innerTable in pairs(theTable) do
        if innerTable[key] ~= nil and innerTable[key] == value then
            return i
        end
    end
    return nil
end

function Utils.GetRandomFloatInRange(lower, upper)
    return lower + math.random() * (upper - lower)
end

function Utils.WasCreativeModeInstantDeconstructionUsed(event)
    if event.instant_deconstruction ~= nil and event.instant_deconstruction == true then
        return true
    else
        return false
    end
end

function Utils.NormaliseChanceList(dataSet, chancePropertyName, skipFillingEmptyChance)
    --By default the dataSet's total chance is manipulated in to a 0-1 range. But if optional skipFillingEmptyChance is set to true then total chance below 1 will not be scaled up, so that nil results can be had in random selection.
    local totalChance = 0
    for _, v in pairs(dataSet) do
        totalChance = totalChance + v[chancePropertyName]
    end
    local multiplier = 1
    if not skipFillingEmptyChance or (skipFillingEmptyChance and totalChance > 1) then
        multiplier = 1 / totalChance
    end
    for _, v in pairs(dataSet) do
        v[chancePropertyName] = v[chancePropertyName] * multiplier
    end
    return dataSet
end

function Utils.GetRandomEntryFromNormalisedDataSet(dataSet, chancePropertyName)
    local random = math.random()
    local chanceRangeLow = 0
    local chanceRangeHigh
    for _, v in pairs(dataSet) do
        chanceRangeHigh = chanceRangeLow + v[chancePropertyName]
        if random >= chanceRangeLow and random <= chanceRangeHigh then
            return v
        end
        chanceRangeLow = chanceRangeHigh
    end
    return nil
end

function Utils.DisableSiloScript()
    --OnLoad
    if remote.interfaces["silo_script"] == nil then
        return
    end
    local items = remote.call("silo_script", "get_tracked_items")
    for itemName in pairs(items) do
        remote.call("silo_script", "remove_tracked_item", itemName)
    end
end

function Utils.DisableWinOnRocket()
    --OnInit
    if remote.interfaces["silo_script"] == nil then
        return
    end
    remote.call("silo_script", "set_no_victory", true)
end

function Utils.ClearSpawnRespawnItems()
    --OnInit
    if remote.interfaces["freeplay"] == nil then
        return
    end
    remote.call("freeplay", "set_created_items", {})
    remote.call("freeplay", "set_respawn_items", {})
end

function Utils.SetStartingMapReveal(distance)
    --OnInit
    if remote.interfaces["freeplay"] == nil then
        return
    end
    remote.call("freeplay", "set_chart_distance", distance)
end

function Utils.DisableIntroMessage()
    --OnInit
    if remote.interfaces["freeplay"] == nil then
        return
    end
    remote.call("freeplay", "set_skip_intro", true)
end

function Utils.PadNumberToMinimumDigits(input, requiredLength)
    local shortBy = requiredLength - string.len(input)
    for i = 1, shortBy do
        input = "0" .. input
    end
    return input
end

function Utils.DisplayNumberPretty(number)
    if number == nil then
        return ""
    end
    local formatted = number
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if (k == 0) then
            break
        end
    end
    return formatted
end

function Utils.DisplayTimeOfTicks(inputTicks, displayLargestTimeUnit, displaySmallestTimeUnit)
    if inputTicks == nil then
        return ""
    end
    local negativeSign = ""
    if inputTicks < 0 then
        negativeSign = "-"
        inputTicks = 0 - inputTicks
    end
    local hours = math.floor(inputTicks / 216000)
    local displayHours = Utils.PadNumberToMinimumDigits(hours, 2)
    inputTicks = inputTicks - (hours * 216000)
    local minutes = math.floor(inputTicks / 3600)
    local displayMinutes = Utils.PadNumberToMinimumDigits(minutes, 2)
    inputTicks = inputTicks - (minutes * 3600)
    local seconds = math.floor(inputTicks / 60)
    local displaySeconds = Utils.PadNumberToMinimumDigits(seconds, 2)

    if displayLargestTimeUnit == nil or displayLargestTimeUnit == "" or displayLargestTimeUnit == "auto" then
        if hours > 0 then
            displayLargestTimeUnit = "hour"
        elseif minutes > 0 then
            displayLargestTimeUnit = "minute"
        else
            displayLargestTimeUnit = "second"
        end
    end
    if not (displayLargestTimeUnit == "hour" or displayLargestTimeUnit == "minute" or displayLargestTimeUnit == "second") then
        error("unrecognised displayLargestTimeUnit argument in Utils.MakeLocalisedStringDisplayOfTime")
    end
    if displaySmallestTimeUnit == nil or displaySmallestTimeUnit == "" or displaySmallestTimeUnit == "auto" then
        displaySmallestTimeUnit = "second"
    end
    if not (displaySmallestTimeUnit == "hour" or displaySmallestTimeUnit == "minute" or displaySmallestTimeUnit == "second") then
        error("unrecognised displaySmallestTimeUnit argument in Utils.MakeLocalisedStringDisplayOfTime")
    end

    local timeUnitIndex = {second = 1, minute = 2, hour = 3}
    local displayLargestTimeUnitIndex = timeUnitIndex[displayLargestTimeUnit]
    local displaySmallestTimeUnitIndex = timeUnitIndex[displaySmallestTimeUnit]
    local timeUnitRange = displayLargestTimeUnitIndex - displaySmallestTimeUnitIndex

    if timeUnitRange == 2 then
        return (negativeSign .. displayHours .. ":" .. displayMinutes .. ":" .. displaySeconds)
    elseif timeUnitRange == 1 then
        if displayLargestTimeUnit == "hour" then
            return (negativeSign .. displayHours .. ":" .. displayMinutes)
        else
            return (negativeSign .. displayMinutes .. ":" .. displaySeconds)
        end
    elseif timeUnitRange == 0 then
        if displayLargestTimeUnit == "hour" then
            return (negativeSign .. displayHours)
        elseif displayLargestTimeUnit == "minute" then
            return (negativeSign .. displayMinutes)
        else
            return (negativeSign .. displaySeconds)
        end
    else
        error("time unit range is negative in Utils.MakeLocalisedStringDisplayOfTime")
    end
end

function Utils._CreatePlacementTestEntityPrototype(entityToClone, newEntityName, subgroup, collisionMask)
    --TODO: doesn't handle mipmaps at all presently. Also ignores any of the extra data in an icons table of "Types/IconData". Think this should just duplicate the target icons table entry.
    local clonedIcon = entityToClone.icon
    local clonedIconSize = entityToClone.icon_size
    if clonedIcon == nil then
        clonedIcon = entityToClone.icons[1].icon
        clonedIconSize = entityToClone.icons[1].icon_size
    end
    return {
        type = "simple-entity",
        name = newEntityName,
        subgroup = subgroup,
        order = "zzz",
        icons = {
            {
                icon = clonedIcon,
                icon_size = clonedIconSize
            },
            {
                icon = "__core__/graphics/cancel.png",
                icon_size = 64,
                scale = (clonedIconSize / 64) * 0.75
            }
        },
        flags = entityToClone.flags,
        selection_box = entityToClone.selection_box,
        collision_box = entityToClone.collision_box,
        collision_mask = collisionMask,
        picture = {
            filename = "__core__/graphics/cancel.png",
            height = 64,
            width = 64
        }
    }
end

function Utils.CreateLandPlacementTestEntityPrototype(entityToClone, newEntityName, subgroup)
    subgroup = subgroup or "other"
    return Utils._CreatePlacementTestEntityPrototype(entityToClone, newEntityName, subgroup, {"water-tile", "colliding-with-tiles-only"})
end

function Utils.CreateWaterPlacementTestEntityPrototype(entityToClone, newEntityName, subgroup)
    subgroup = subgroup or "other"
    return Utils._CreatePlacementTestEntityPrototype(entityToClone, newEntityName, subgroup, {"ground-tile", "colliding-with-tiles-only"})
end

function Utils.GetValidPositionForEntityNearPosition(entityName, surface, centerPos, radius, maxAttempts, searchIncrement, allowNonTileCenter)
    local pos
    local attempts = 1
    searchIncrement = searchIncrement or 1
    allowNonTileCenter = allowNonTileCenter or false
    while pos == nil do
        local searchRadius = radius * attempts
        pos = surface.find_non_colliding_position(entityName, centerPos, searchRadius, searchIncrement, not allowNonTileCenter)
        if pos ~= nil then
            return pos
        end
        attempts = attempts + 1
        if attempts > maxAttempts then
            return nil
        end
    end
    return nil
end

function Utils.ToBoolean(text)
    text = string.lower(text)
    if text ~= nil and text == "true" then
        return true
    elseif text ~= nil and text == "false" then
        return false
    end
    return nil
end

function Utils.RandomLocationInRadius(centrePos, maxRadius, minRadius)
    local angleRad = math.random() * (math.pi * 2)
    minRadius = minRadius or 0
    local radiusMultiplier = maxRadius - minRadius
    local distance = minRadius + (math.random() * radiusMultiplier)
    local randomPos = {
        x = (distance * math.sin(angleRad)) + centrePos.x,
        y = (distance * -math.cos(angleRad)) + centrePos.y
    }
    return randomPos
end

function Utils.GetPositionForAngledDistance(startingPos, distance, angle)
    if angle < 0 then
        angle = 360 + angle
    end
    local angleRad = math.rad(angle)
    local newPos = {
        x = (distance * math.sin(angleRad)) + startingPos.x,
        y = (distance * -math.cos(angleRad)) + startingPos.y
    }
    return newPos
end

function Utils.FindWhereLineCrossesCircle(radius, slope, yIntercept)
    local centerPos = {x = 0, y = 0}
    local A = 1 + slope * slope
    local B = -2 * centerPos.x + 2 * slope * yIntercept - 2 * centerPos.y * slope
    local C = centerPos.x * centerPos.x + yIntercept * yIntercept + centerPos.y * centerPos.y - 2 * centerPos.y * yIntercept - radius * radius
    local delta = B * B - 4 * A * C

    if delta < 0 then
        return nil, nil
    else
        local x1 = (-B + math.sqrt(delta)) / (2 * A)

        local x2 = (-B - math.sqrt(delta)) / (2 * A)

        local y1 = slope * x1 + yIntercept

        local y2 = slope * x2 + yIntercept

        local pos1 = {x = x1, y = y1}
        local pos2 = {x = x2, y = y2}
        if pos1 == pos2 then
            return pos1, nil
        else
            return pos1, pos2
        end
    end
end

function Utils.IsPositionWithinCircled(circleCenter, radius, position)
    local deltaX = math.abs(position.x - circleCenter.x)
    local deltaY = math.abs(position.y - circleCenter.y)
    if deltaX + deltaY <= radius then
        return true
    elseif deltaX > radius then
        return false
    elseif deltaY > radius then
        return false
    elseif deltaX ^ 2 + deltaY ^ 2 <= radius ^ 2 then
        return true
    else
        return false
    end
end

return Utils
