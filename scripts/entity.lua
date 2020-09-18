local Entity = {}
local Utils = require("utility/utils")
local Logging = require("utility/logging")
local StaticData = require("static-data")
local Events = require("utility/events")

local debug_placementAttemptCircles = false -- clear all on map via: /c rendering.clear("single_train_unit")
local debug_writeAllWarnings = false

local LoopDirectionValue = function(value)
    return Utils.LoopIntValueWithinRange(value, 0, 7)
end

Entity.CreateGlobals = function()
    global.entity = global.entity or {}
    global.entity.forces = global.entity.forces or {}
    --[[
    global.entity.forces[force.index].singleTrainUnits = {
        id = singleTrainUnitId,
        wagons = {
            forwardLoco = ENTITY, middleCargo = ENTITY, rearLoco = ENTITY
        },
        type = STATICDATA WAGON TYPE
    } -- Force index entries are defined when first used and the intial force entry is generated.
    --]]
    global.entity.wagonIdToSingleTrainUnit = global.entity.wagonIdToSingleTrainUnit or {} -- WagonId to lobal.entity.forces[force.index].singleTrainUnits entry
    global.entity.damageSourcesTick = global.entity.damageSourcesTick or 0
    global.entity.damageSourcesThisTick = global.entity.damageSourcesThisTick or {}

    global.entity.muWagonVariants = {}
    global.entity.muWagonNamesFilter = global.entity.muWagonNamesFilter or {}
    global.entity.muWagonPlacementNameFilter = global.entity.muWagonPlacementNameFilter or {}
end

Entity.OnLoad = function()
    Events.RegisterEvent(defines.events.on_built_entity, "Entity.OnBuiltEntity_MUPlacement", global.entity.muWagonPlacementNameFilter)
    Events.RegisterHandler(defines.events.on_built_entity, "Entity.OnBuiltEntity_MUPlacement", Entity.OnBuiltEntity_MUPlacement)
    Events.RegisterEvent(defines.events.on_train_created)
    Events.RegisterHandler(defines.events.on_train_created, "Entity.OnTrainCreated", Entity.OnTrainCreated)
    Events.RegisterEvent(defines.events.on_player_mined_entity, "Entity.OnPlayerMined_MUWagon", global.entity.muWagonNamesFilter)
    Events.RegisterHandler(defines.events.on_player_mined_entity, "Entity.OnPlayerMined_MUWagon", Entity.OnPlayerMined_MUWagon)
    Events.RegisterEvent(defines.events.on_pre_player_mined_item, "Entity.OnPrePlayerMined_MUWagon", global.entity.muWagonNamesFilter)
    Events.RegisterHandler(defines.events.on_pre_player_mined_item, "Entity.OnPrePlayerMined_MUWagon", Entity.OnPrePlayerMined_MUWagon)
    Events.RegisterEvent(defines.events.on_entity_damaged, "Entity.OnEntityDamaged_MUWagon", global.entity.muWagonNamesFilter)
    Events.RegisterHandler(defines.events.on_entity_damaged, "Entity.OnEntityDamaged_MUWagon", Entity.OnEntityDamaged_MUWagon)
    Events.RegisterEvent(defines.events.on_entity_died, "Entity.OnEntityDied_MUWagon", global.entity.muWagonNamesFilter)
    Events.RegisterHandler(defines.events.on_entity_died, "Entity.OnEntityDied_MUWagon", Entity.OnEntityDied_MUWagon)
    Events.RegisterEvent(defines.events.on_robot_built_entity, "Entity.OnBuiltEntity_MUPlacement_WagonEntities", global.entity.muWagonNamesFilter)
    Events.RegisterEvent(defines.events.on_robot_built_entity, "Entity.OnBuiltEntity_MUPlacement_PlacementEntities", global.entity.muWagonPlacementNameFilter)
    Events.RegisterHandler(defines.events.on_robot_built_entity, "Entity.OnBuiltEntity_MUPlacement", Entity.OnBuiltEntity_MUPlacement)
    Events.RegisterEvent(defines.events.on_robot_mined_entity, "Entity.OnRobotMinedEntity_MUWagons", global.entity.muWagonNamesFilter)
    Events.RegisterHandler(defines.events.on_robot_mined_entity, "Entity.OnRobotMinedEntity_MUWagons", Entity.OnRobotMinedEntity_MUWagons)
end

Entity.OnStartup = function()
    Entity.OnMigration()
    global.entity.muWagonNamesFilter = Entity.GenerateMuWagonNamesFilter()
    global.entity.muWagonPlacementNameFilter = Entity.GenerateMuWagonPlacementNameFilter()
    Entity.OnLoad() -- need to update dynmaic filter registration lists
end

Entity.OnMigration = function()
    -- Fix the missing .type on earlier versions
    for _, force in pairs(global.entity.forces) do
        for index, singleTrainUnit in pairs(force.singleTrainUnits) do
            if singleTrainUnit.wagons == nil or singleTrainUnit.wagons.middleCargo == nil or not singleTrainUnit.wagons.middleCargo.valid then
                force.singleTrainUnits[index] = nil
            elseif singleTrainUnit.type == nil then
                singleTrainUnit.type = StaticData.entityNames[singleTrainUnit.wagons.middleCargo.name].type
            end
        end
    end
end

Entity.GenerateMuWagonNamesFilter = function()
    local filterTable = {}
    for _, prototype in pairs(game.get_filtered_entity_prototypes({{filter = "rolling-stock"}})) do
        for _, staticDataName in pairs({StaticData.mu_cargo_loco.name, StaticData.mu_cargo_wagon.name, StaticData.mu_fluid_loco.name, StaticData.mu_fluid_wagon.name}) do
            if string.find(prototype.name, staticDataName, 1, true) then
                if #filterTable == 0 then
                    table.insert(filterTable, {filter = "name", name = prototype.name})
                else
                    table.insert(filterTable, {mode = "or", filter = "name", name = prototype.name})
                end
            end
        end
    end
    return filterTable
end

Entity.GenerateMuWagonPlacementNameFilter = function()
    local filterTable = {}
    for _, prototype in pairs(game.get_filtered_entity_prototypes({{filter = "rolling-stock"}})) do
        for _, staticDataName in pairs({StaticData.mu_cargo_placement.name, StaticData.mu_fluid_placement.name}) do
            if string.find(prototype.name, staticDataName, 1, true) then
                if #filterTable == 0 then
                    table.insert(filterTable, {filter = "name", name = prototype.name})
                else
                    table.insert(filterTable, {mode = "or", filter = "name", name = prototype.name})
                end
                Entity.GenerateRecordPlacementStaticDataVariant(staticDataName, prototype.name)
            end
        end
    end
    return filterTable
end

Entity.GenerateRecordPlacementStaticDataVariant = function(baseName, variantName)
    -- TODO - doesn't handle if a mod adds a new version of the placement part and some or none of the other parts.
    local variantNamePos_start, variantNamePos_end = string.find(variantName, baseName, 1, true)
    local variantNamePrefix, variantNameSuffix = string.sub(variantName, 1, variantNamePos_start - 1), string.sub(variantName, variantNamePos_end + 1)
    local variantPlacement = Utils.DeepCopy(StaticData.entityNames[baseName])
    variantPlacement.name = variantName
    if variantPlacement.placedStaticDataWagon ~= nil then
        local variantPart = Utils.DeepCopy(variantPlacement.placedStaticDataWagon)
        local variantPartName = variantNamePrefix .. variantPart.name .. variantNameSuffix
        if game.get_filtered_entity_prototypes({{filter = "name", name = variantPartName}}) ~= nil then
            variantPart.name = variantPartName
        end
        global.entity.muWagonVariants[variantPart.name] = variantPart
        variantPlacement.placedStaticDataWagon = variantPart
        variantPlacement.placedStaticDataWagon.placementStaticData = variantPlacement
    end
    if variantPlacement.placedStaticDataLoco ~= nil then
        local variantPart = Utils.DeepCopy(variantPlacement.placedStaticDataLoco)
        local variantPartName = variantNamePrefix .. variantPart.name .. variantNameSuffix
        if game.get_filtered_entity_prototypes({{filter = "name", name = variantPartName}}) ~= nil then
            variantPart.name = variantPartName
        end
        global.entity.muWagonVariants[variantPart.name] = variantPart
        variantPlacement.placedStaticDataLoco = variantPart
        variantPlacement.placedStaticDataLoco.placementStaticData = variantPlacement
    end
    global.entity.muWagonVariants[variantPlacement.name] = variantPlacement
end

Entity.OnBuiltEntity_MUPlacement = function(event)
    local entity = event.created_entity
    --Called from 2 different events with their own filter lists.
    if not Utils.GetTableKeyWithInnerKeyValue(global.entity.muWagonPlacementNameFilter, "name", entity.name) and not Utils.GetTableKeyWithInnerKeyValue(global.entity.muWagonNamesFilter, "name", entity.name) then
        return
    end

    local surface, force, placedEntityName, placedEntityPosition, placedEntityOrientation = entity.surface, entity.force, entity.name, entity.position, entity.orientation
    local placementStaticData = global.entity.muWagonVariants[placedEntityName]
    local builder = event.robot or game.get_player(event.player_index)
    local builderInventory = Utils.GetBuilderInventory(builder)

    -- Is a bot placing blueprint of the actual wagon, not the placement entity.
    if placementStaticData.placedStaticDataWagon == nil then
        placementStaticData = placementStaticData.placementStaticData
        placedEntityName = placementStaticData.name
    end

    local wagonStaticData, locoStaticData = placementStaticData.placedStaticDataWagon, placementStaticData.placedStaticDataLoco
    local placedEntityDirection = LoopDirectionValue(Utils.RoundNumberToDecimalPlaces(placedEntityOrientation * 8, 0))
    local locoDistance = (placementStaticData.joint_distance / 2) - (locoStaticData.joint_distance / 2)

    local forwardLocoOrientation = placedEntityOrientation
    local forwardLocoPosition = Utils.GetPositionForAngledDistance(placedEntityPosition, locoDistance, forwardLocoOrientation * 360)
    local forwardLocoDirection = placedEntityDirection
    local rearLocoOrientation = placedEntityOrientation - 0.5
    local rearLocoPosition = Utils.GetPositionForAngledDistance(placedEntityPosition, locoDistance, rearLocoOrientation * 360)
    local rearLocoDirection = LoopDirectionValue(placedEntityDirection + 4)
    local middleCargoDirection = placedEntityDirection
    local middleCargoPosition = placedEntityPosition

    local fuelInventory, fuelInventoryContents = entity.get_fuel_inventory(), nil
    if fuelInventory ~= nil then
        fuelInventoryContents = fuelInventory.get_contents()
    end
    local health = entity.health
    entity.destroy()
    local wagons = {forwardLoco = nil, middleCargo = nil, rearLoco = nil}

    wagons.forwardLoco = Entity.PlaceWagon(locoStaticData.name, forwardLocoPosition, surface, force, forwardLocoDirection)
    if wagons.forwardLoco == nil then
        Entity.PlaceOrionalWagonBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection, wagons, "Front Loco", event.replaced, event, fuelInventoryContents, health)
        return
    end

    wagons.middleCargo = Entity.PlaceWagon(wagonStaticData.name, middleCargoPosition, surface, force, middleCargoDirection)
    if wagons.middleCargo == nil then
        Entity.PlaceOrionalWagonBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection, wagons, "Middle Cargo Wagon", event.replaced, event, fuelInventoryContents, health)
        return
    end

    wagons.rearLoco = Entity.PlaceWagon(locoStaticData.name, rearLocoPosition, surface, force, rearLocoDirection)
    if wagons.rearLoco == nil then
        Entity.PlaceOrionalWagonBack(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection, wagons, "Rear Loco", event.replaced, event, fuelInventoryContents, health)
        return
    end

    for _, wagon in pairs(wagons) do
        wagon.connect_rolling_stock(defines.rail_direction.front)
        wagon.connect_rolling_stock(defines.rail_direction.back)
    end

    -- Set to blank as cargo & fluid wagons can't have names. We want all parts of the unit to have the same on-hover name.
    wagons.forwardLoco.backer_name = ""
    wagons.rearLoco.backer_name = ""

    -- Handle Fuel
    if fuelInventoryContents ~= nil then
        if game.active_mods["Fill4Me"] then
            -- Will insert the same amount of fuel in to both end locos as was placed in to the placement loco assuming fuel in builder inventory allowing. Otherwise will use all available and split between.
            local fuelName, fuelCount = next(fuelInventoryContents, nil)
            if fuelName ~= nil and fuelCount ~= nil and fuelCount > 0 then
                local fuelAvailable = builderInventory.get_item_count(fuelName) + fuelCount
                local fuelToInsert = math.ceil(math.min(fuelAvailable / 2, fuelCount))
                local fuelInserted = 0
                if fuelToInsert > 0 then
                    fuelInserted = fuelInserted + wagons.forwardLoco.get_fuel_inventory().insert({name = fuelName, count = fuelToInsert})
                end
                fuelToInsert = math.floor(math.min(fuelAvailable / 2, fuelCount))
                if fuelToInsert > 0 then
                    fuelInserted = fuelInserted + wagons.rearLoco.get_fuel_inventory().insert({name = fuelName, count = fuelToInsert})
                end
                local fuelUsedFromBuilder = fuelInserted - fuelCount
                if fuelUsedFromBuilder > 0 then
                    builderInventory.remove({name = fuelName, count = fuelUsedFromBuilder})
                elseif fuelUsedFromBuilder < 0 then
                    Utils.TryInsertInventoryContents({[fuelName] = 0 - fuelUsedFromBuilder}, builderInventory, true, 1)
                end
            end
        else
            -- Will spread the fuel from the placement loco across the 2 end locos.
            local fuelAllMoved = Utils.TryInsertInventoryContents(fuelInventoryContents, wagons.forwardLoco.get_fuel_inventory(), false, 0.5)
            if not fuelAllMoved then
                fuelAllMoved = Utils.TryInsertInventoryContents(fuelInventoryContents, wagons.rearLoco.get_fuel_inventory(), false, 0.5)
            end
            if not fuelAllMoved then
                Utils.TryInsertInventoryContents(fuelInventoryContents, builderInventory, true, 1)
            end
        end
    end

    wagons.middleCargo.health = health

    Entity.RecordSingleUnit(force, wagons, wagonStaticData.type)
end

Entity.PlaceWagon = function(prototypeName, position, surface, force, direction)
    if debug_placementAttemptCircles then
        rendering.draw_circle {
            color = {r = 0, g = 0, b = 1},
            radius = 0.1,
            filled = true,
            target = position,
            surface = surface
        }
    end
    local wagon = surface.create_entity {name = prototypeName, position = position, force = force, snap_to_train_stop = false, direction = direction}
    if wagon == nil then
        Logging.LogPrint("WARNING: " .. prototypeName .. " failed to place at " .. Logging.PositionToString(position) .. " with direction: " .. direction, debug_writeAllWarnings)
        return
    end
    return wagon
end

Entity.PlaceOrionalWagonBack = function(surface, placedEntityName, placedEntityPosition, force, placedEntityDirection, wagons, failedOnName, eventReplaced, event, fuelInventoryContents, health)
    -- As we failed to place all the expected parts remove any placed. Then place the origional wagon placement entity back, but backwards. Calling the replacement process on this reversed placement wagon generally works for any standard use cases because Factorio.
    local builder = event.robot or game.get_player(event.player_index)
    local builderInventory = Utils.GetBuilderInventory(builder)
    local placementSimpleItemStackTable = {{name = placedEntityName, count = 1, health = health}}

    Logging.LogPrint("WARNING: " .. "failed placing " .. failedOnName, debug_writeAllWarnings)
    for _, wagon in pairs(wagons) do
        if wagon ~= nil and wagon.valid then
            wagon.destroy()
        end
    end
    if eventReplaced ~= nil and eventReplaced then
        Logging.LogPrint("ERROR: " .. "failed placing " .. failedOnName .. " for second orientation, so giving up")
        Utils.TryInsertSimpleItems(placementSimpleItemStackTable, builderInventory, true, 1)
        Utils.TryInsertInventoryContents(fuelInventoryContents, builderInventory, true, 1)
        return
    end

    placedEntityDirection = LoopDirectionValue(placedEntityDirection + 4)
    local placedWagon = surface.create_entity {name = placedEntityName, position = placedEntityPosition, force = force, snap_to_train_stop = false, direction = placedEntityDirection}
    if placedWagon ~= nil then
        Utils.TryInsertInventoryContents(fuelInventoryContents, placedWagon.get_fuel_inventory(), true, 1)
        placedWagon.health = health
    else
        Logging.LogPrint("ERROR: " .. "failed to place origional " .. placedEntityName .. " back at " .. Logging.PositionToString(placedEntityPosition) .. " with new direction: " .. placedEntityDirection)
        Utils.TryInsertSimpleItems(placementSimpleItemStackTable, builderInventory, true, 1)
        Utils.TryInsertInventoryContents(fuelInventoryContents, builderInventory, true, 1)
        return
    end
    Logging.LogPrint("WARNING: " .. "placed origional " .. placedEntityName .. " back at " .. Logging.PositionToString(placedEntityPosition) .. " with new direction: " .. placedEntityDirection, debug_writeAllWarnings)

    Entity.OnBuiltEntity_MUPlacement({created_entity = placedWagon, replaced = true, robot = event.robot, player_index = event.player_index})
end

Entity.RecordSingleUnit = function(force, wagons, type)
    global.entity.forces[force.index] =
        global.entity.forces[force.index] or
        {
            singleTrainUnits = {}
        }
    local forcesEntry = global.entity.forces[force.index]
    local singleTrainUnitId = #forcesEntry.singleTrainUnits + 1
    forcesEntry.singleTrainUnits[singleTrainUnitId] = {
        id = singleTrainUnitId,
        wagons = wagons,
        type = type
    }
    for _, wagon in pairs(wagons) do
        global.entity.wagonIdToSingleTrainUnit[wagon.unit_number] = forcesEntry.singleTrainUnits[singleTrainUnitId]
    end
end

Entity.DeleteSingleUnitRecord = function(force, singleTrainUnitId)
    local forcesEntry = global.entity.forces[force.index]
    if forcesEntry == nil or forcesEntry.singleTrainUnits[singleTrainUnitId] == nil then
        return
    end
    for _, wagon in pairs(forcesEntry.singleTrainUnits[singleTrainUnitId].wagons) do
        if wagon.valid then
            global.entity.wagonIdToSingleTrainUnit[wagon.unit_number] = nil
        end
    end
    forcesEntry.singleTrainUnits[singleTrainUnitId] = nil
end

Entity.OnTrainCreated = function(event)
    -- This is just to protect against the user disconnecting the parts of the single trian unit. It does tend to loop a bit, but as long as no infinite loops we are all good.

    if event.old_train_id_1 ~= nil and event.old_train_id_2 ~= nil then
        -- Is the joining of 2 trains togeather.
        return
    end
    if event.old_train_id_1 == nil and event.old_train_id_2 == nil then
        -- Is the creation of a single new trian.
        return
    end

    local frontCarriage = event.train.front_stock
    local backCarriage = event.train.back_stock
    if frontCarriage == nil or backCarriage == nil then
        return
    end

    -- Connects to the front or back of the rolling stock direction, not the train direction. The reverse of the connect direction based on the other end of the trains wagon seems to work in testing, but feels a bit janky.
    local frontWagonStaticData = global.entity.muWagonVariants[frontCarriage.name]
    if frontWagonStaticData ~= nil and (frontWagonStaticData.type == "cargo-wagon" or frontWagonStaticData.type == "fluid-wagon") then
        local orientationDif = math.abs(frontCarriage.orientation - backCarriage.orientation)
        if orientationDif < 0.25 then
            frontCarriage.connect_rolling_stock(defines.rail_direction.front)
        else
            frontCarriage.connect_rolling_stock(defines.rail_direction.back)
        end
    end

    local backWagonStaticData = global.entity.muWagonVariants[backCarriage.name]
    if backWagonStaticData ~= nil and (backWagonStaticData.type == "cargo-wagon" or backWagonStaticData.type == "fluid-wagon") then
        local orientationDif = math.abs(frontCarriage.orientation - backCarriage.orientation)
        if orientationDif < 0.25 then
            backCarriage.connect_rolling_stock(defines.rail_direction.back)
        else
            backCarriage.connect_rolling_stock(defines.rail_direction.front)
        end
    end
end

Entity.OnPlayerMined_MUWagon = function(event)
    local minedWagon, force = event.entity, event.entity.force
    local singleTrainUnit = global.entity.wagonIdToSingleTrainUnit[minedWagon.unit_number]
    if singleTrainUnit == nil then
        return
    end

    local player = game.get_player(event.player_index)
    local thisUnitsWagons = Utils.DeepCopy(singleTrainUnit.wagons)
    Entity.DeleteSingleUnitRecord(force, singleTrainUnit.id)
    local thisWagonId = minedWagon.unit_number

    for _, wagon in pairs(thisUnitsWagons) do
        if wagon.valid and wagon.unit_number ~= thisWagonId then
            player.mine_entity(wagon, force)
        end
    end
end

Entity.OnPrePlayerMined_MUWagon = function(event)
    --This tries to take all the cargo items, then fuel before the actual MU Wagon entiies get mined. If the train contents are more than the players inventory space this will mean the players inventory fills up and then the game will naturally not try to mine the train entities themselves.
    local minedWagon = event.entity
    local singleTrainUnit = global.entity.wagonIdToSingleTrainUnit[minedWagon.unit_number]
    if singleTrainUnit == nil then
        return
    end

    local player = game.get_player(event.player_index)
    local playerInventory = player.get_main_inventory()
    if singleTrainUnit.type == "cargo-wagon" then
        Utils.TryMoveInventoriesLuaItemStacks(singleTrainUnit.wagons.middleCargo.get_inventory(defines.inventory.cargo_wagon), playerInventory, false, 1)
    end
    Utils.TryMoveInventoriesLuaItemStacks(singleTrainUnit.wagons.forwardLoco.get_fuel_inventory(), playerInventory, false, 1)
    Utils.TryMoveInventoriesLuaItemStacks(singleTrainUnit.wagons.rearLoco.get_fuel_inventory(), playerInventory, false, 1)
    for _, wagon in pairs(singleTrainUnit.wagons) do
        local wagonGrid = wagon.grid
        if wagonGrid ~= nil then
            Utils.TryTakeGridsItems(wagonGrid, playerInventory, false)
        end
    end
end

Entity.GetDamageCauseString = function(event)
    local causeString
    if event.cause == nil then
        causeString = "unknown"
    else
        causeString = event.cause.name
        if event.cause.player then
            causeString = causeString .. "_" .. event.cause.player.name
        end
        if event.cause.unit_number then
            causeString = causeString .. "_" .. event.cause.unit_number
        end
    end
    causeString = causeString .. "-" .. event.damage_type.name
    return causeString
end

Entity.OnEntityDamaged_MUWagon = function(event)
    local damagedWagon = event.entity
    local singleTrainUnit = global.entity.wagonIdToSingleTrainUnit[damagedWagon.unit_number]
    local cargoWagon = singleTrainUnit.wagons.middleCargo

    if global.entity.damageSourcesTick ~= event.tick then
        global.entity.damageSourcesTick = event.tick
        global.entity.damageSourcesThisTick = {}
    end
    local damageName = Entity.GetDamageCauseString(event)
    local damageToDo = event.final_damage_amount
    -- This damageToDo is to handle variable damage from the same thing affecting multiple parts, however, it does mean that dual damaging weapons (explosive rockets, cluster grenades, etc) will only do their single most max damage and not the damage from each part.
    if global.entity.damageSourcesThisTick[damageName] == nil then
        global.entity.damageSourcesThisTick[damageName] = damageToDo
    else
        if global.entity.damageSourcesThisTick[damageName] < event.final_damage_amount then
            damageToDo = event.final_damage_amount - global.entity.damageSourcesThisTick[damageName]
            global.entity.damageSourcesThisTick[damageName] = event.final_damage_amount
        else
            damageToDo = 0
        end
    end

    cargoWagon.health = cargoWagon.health - damageToDo
    damagedWagon.health = damagedWagon.health + event.final_damage_amount
end

Entity.OnEntityDied_MUWagon = function(event)
    local damagedWagon = event.entity
    local singleTrainUnit = global.entity.wagonIdToSingleTrainUnit[damagedWagon.unit_number]

    for _, wagon in pairs(singleTrainUnit.wagons) do
        if wagon.valid and wagon.unit_number ~= damagedWagon.unit_number then
            wagon.die()
        end
    end

    Entity.DeleteSingleUnitRecord(event.force, singleTrainUnit.id)
end

Entity.OnRobotMinedEntity_MUWagons = function(event)
    -- Try to move the fuel contents in to the robot picking up the item. In some cases the items will fall on the ground from the construction robot, but marked for decon, etc. This is vanilla behaviour, i.e rocks.
    local minedWagon, buffer = event.entity, event.buffer
    local singleTrainUnit = global.entity.wagonIdToSingleTrainUnit[minedWagon.unit_number]
    if singleTrainUnit == nil then
        return
    end

    Utils.TryMoveInventoriesLuaItemStacks(singleTrainUnit.wagons.forwardLoco.get_fuel_inventory(), buffer, false, 1)
    Utils.TryMoveInventoriesLuaItemStacks(singleTrainUnit.wagons.rearLoco.get_fuel_inventory(), buffer, false, 1)
    for _, wagon in pairs(singleTrainUnit.wagons) do
        local wagonGrid = wagon.grid
        if wagonGrid ~= nil then
            Utils.TryTakeGridsItems(wagonGrid, buffer, false)
        end
    end

    local thisUnitsWagons, force = Utils.DeepCopy(singleTrainUnit.wagons), minedWagon.force
    Entity.DeleteSingleUnitRecord(force, singleTrainUnit.id)
    local thisWagonId = minedWagon.unit_number

    for _, wagon in pairs(thisUnitsWagons) do
        if wagon.valid and wagon.unit_number ~= thisWagonId then
            wagon.destroy()
        end
    end
end

return Entity
