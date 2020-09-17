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

local TryMoveInventoriesLuaItemStacks = function(sourceInventory, targetInventory, dropUnmovedOnGround, ratioToMove)
    -- Moves the full Lua Item Stacks so handles items with data and other complicated items. Updates the passed in inventory object.
    local sourceOwner, itemsNotMoved = nil, false
    if sourceInventory.is_empty() then
        return itemsNotMoved
    end

    for index = 1, #sourceInventory do
        local itemStack = sourceInventory[index]
        if itemStack.valid_for_read then
            local toMoveCount = math.ceil(itemStack.count * ratioToMove)
            local itemStackToMove = Utils.DeepCopy(itemStack)
            itemStackToMove.count = toMoveCount
            local movedCount = targetInventory.insert(itemStackToMove)
            local remaining = itemStack.count - movedCount
            if movedCount > 0 then
                itemStack.count = remaining
            end
            if remaining > 0 then
                itemsNotMoved = true
                if dropUnmovedOnGround then
                    sourceOwner = sourceOwner or targetInventory.entity_owner
                    sourceOwner.surface.spill_item_stack(sourceOwner.position, {name = itemStack.name, count = remaining}, true, sourceOwner.force, false)
                end
            end
        end
    end

    return not itemsNotMoved
end

local TryTakeGridsItems = function(sourceGrid, targetInventory, dropUnmovedOnGround)
    -- Can only move the item name and count via API, Facotrio doesn't support putting equipment objects in an inventory. Updates the passed in grid object.
    local sourceOwner, itemsNotMoved = nil, false
    for _, equipment in pairs(sourceGrid.equipment) do
        local moved = targetInventory.insert({name = equipment.name, count = 1})
        if moved > 0 then
            sourceGrid.take({equipment = equipment})
        end
        if moved == 0 then
            itemsNotMoved = true
            if dropUnmovedOnGround then
                sourceOwner = sourceOwner or targetInventory.entity_owner
                sourceOwner.surface.spill_item_stack(sourceOwner.position, {name = equipment.name, count = 1}, true, sourceOwner.force, false)
            end
        end
    end
    return not itemsNotMoved
end

local TryInsertInventoryContents = function(contents, targetInventory, dropUnmovedOnGround, ratioToMove)
    -- Just takes a list of item names and counts that you get from the inventory.get_contents(). Updates the passed in contents object.
    if contents == nil then
        return
    end
    local sourceOwner, itemsNotMoved = nil, false
    for name, count in pairs(contents) do
        local toMove = math.ceil(count * ratioToMove)
        local moved = targetInventory.insert({name = name, count = toMove})
        local remaining = count - moved
        if moved > 0 then
            contents[name] = remaining
        end
        if remaining > 0 then
            itemsNotMoved = true
            if dropUnmovedOnGround then
                sourceOwner = sourceOwner or targetInventory.entity_owner
                sourceOwner.surface.spill_item_stack(sourceOwner.position, {name = name, count = remaining}, true, sourceOwner.force, false)
            end
        end
    end
    return not itemsNotMoved
end

local TryInsertSimpleItems = function(contents, targetInventory, dropUnmovedOnGround, ratioToMove)
    -- Takes a table of SimpleItemStack and inserts them in to an inventory. Updates the passed in contents object.
    if contents == nil or #contents == 0 then
        return
    end
    local sourceOwner, itemsNotMoved = nil, false
    for index, simpleItemStack in pairs(contents) do
        local toMove = math.ceil(simpleItemStack.count * ratioToMove)
        local moved = targetInventory.insert({name = simpleItemStack.name, count = toMove, health = simpleItemStack.health, durability = simpleItemStack.durablilty, ammo = simpleItemStack.ammo})
        local remaining = simpleItemStack.count - moved
        if moved > 0 then
            contents[index].count = remaining
        end
        if remaining > 0 then
            itemsNotMoved = true
            if dropUnmovedOnGround then
                sourceOwner = sourceOwner or targetInventory.entity_owner
                sourceOwner.surface.spill_item_stack(sourceOwner.position, {name = simpleItemStack.name, count = remaining}, true, sourceOwner.force, false)
            end
        end
    end
    return not itemsNotMoved
end

local GetBuilderInventory = function(builder)
    if builder.is_player() then
        return builder.get_main_inventory()
    elseif builder.type ~= nil and builder.type == "construction-robot" then
        return builder.get_inventory(defines.inventory.robot_cargo)
    else
        return builder
    end
end

local muWagonNamesFilter = {
    {filter = "name", name = StaticData.mu_cargo_loco.name},
    {mode = "or", filter = "name", name = StaticData.mu_cargo_wagon.name},
    {mode = "or", filter = "name", name = StaticData.mu_fluid_loco.name},
    {mode = "or", filter = "name", name = StaticData.mu_fluid_wagon.name}
}
local muWagonPlacementNameFilter = {
    {filter = "name", name = StaticData.mu_cargo_placement.name},
    {mode = "or", filter = "name", name = StaticData.mu_fluid_placement.name}
}

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
end

Entity.OnLoad = function()
    Events.RegisterEvent(defines.events.on_built_entity, "Entity.OnBuiltEntity_MUPlacement", muWagonPlacementNameFilter)
    Events.RegisterHandler(defines.events.on_built_entity, "Entity.OnBuiltEntity_MUPlacement", Entity.OnBuiltEntity_MUPlacement)
    Events.RegisterEvent(defines.events.on_train_created)
    Events.RegisterHandler(defines.events.on_train_created, "Entity.OnTrainCreated", Entity.OnTrainCreated)
    Events.RegisterEvent(defines.events.on_player_mined_entity, "Entity.OnPlayerMined_MUWagon", muWagonNamesFilter)
    Events.RegisterHandler(defines.events.on_player_mined_entity, "Entity.OnPlayerMined_MUWagon", Entity.OnPlayerMined_MUWagon)
    Events.RegisterEvent(defines.events.on_pre_player_mined_item, "Entity.OnPrePlayerMined_MUWagon", muWagonNamesFilter)
    Events.RegisterHandler(defines.events.on_pre_player_mined_item, "Entity.OnPrePlayerMined_MUWagon", Entity.OnPrePlayerMined_MUWagon)
    Events.RegisterEvent(defines.events.on_entity_damaged, "Entity.OnEntityDamaged_MUWagon", muWagonNamesFilter)
    Events.RegisterHandler(defines.events.on_entity_damaged, "Entity.OnEntityDamaged_MUWagon", Entity.OnEntityDamaged_MUWagon)
    Events.RegisterEvent(defines.events.on_entity_died, "Entity.OnEntityDied_MUWagon", muWagonNamesFilter)
    Events.RegisterHandler(defines.events.on_entity_died, "Entity.OnEntityDied_MUWagon", Entity.OnEntityDied_MUWagon)
    Events.RegisterEvent(defines.events.on_robot_built_entity, "Entity.OnBuiltEntity_MUPlacement_WagonEntities", muWagonNamesFilter)
    Events.RegisterEvent(defines.events.on_robot_built_entity, "Entity.OnBuiltEntity_MUPlacement_PlacementEntities", muWagonPlacementNameFilter)
    Events.RegisterHandler(defines.events.on_robot_built_entity, "Entity.OnBuiltEntity_MUPlacement", Entity.OnBuiltEntity_MUPlacement)
    Events.RegisterEvent(defines.events.on_robot_mined_entity, "Entity.OnRobotMinedEntity_MUWagons", muWagonNamesFilter)
    Events.RegisterHandler(defines.events.on_robot_mined_entity, "Entity.OnRobotMinedEntity_MUWagons", Entity.OnRobotMinedEntity_MUWagons)
end

Entity.OnStartup = function()
    Entity.OnMigration()
end

Entity.OnMigration = function()
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

Entity.OnBuiltEntity_MUPlacement = function(event)
    local entity = event.created_entity
    --Called from 2 different events with their own filter lists.
    if not Utils.GetTableKeyWithInnerKeyValue(muWagonPlacementNameFilter, "name", entity.name) and not Utils.GetTableKeyWithInnerKeyValue(muWagonNamesFilter, "name", entity.name) then
        return
    end

    local surface, force, placedEntityName, placedEntityPosition, placedEntityOrientation = entity.surface, entity.force, entity.name, entity.position, entity.orientation
    local placementStaticData = StaticData.entityNames[placedEntityName]
    local builder = event.robot or game.get_player(event.player_index)
    local builderInventory = GetBuilderInventory(builder)

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
                    TryInsertInventoryContents({[fuelName] = 0 - fuelUsedFromBuilder}, builderInventory, true, 1)
                end
            end
        else
            -- Will spread the fuel from the placement loco across the 2 end locos.
            local fuelAllMoved = TryInsertInventoryContents(fuelInventoryContents, wagons.forwardLoco.get_fuel_inventory(), false, 0.5)
            if not fuelAllMoved then
                fuelAllMoved = TryInsertInventoryContents(fuelInventoryContents, wagons.rearLoco.get_fuel_inventory(), false, 0.5)
            end
            if not fuelAllMoved then
                TryInsertInventoryContents(fuelInventoryContents, builderInventory, true, 1)
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
    local builderInventory = GetBuilderInventory(builder)
    local placementSimpleItemStackTable = {{name = placedEntityName, count = 1, health = health}}

    Logging.LogPrint("WARNING: " .. "failed placing " .. failedOnName, debug_writeAllWarnings)
    for _, wagon in pairs(wagons) do
        if wagon ~= nil and wagon.valid then
            wagon.destroy()
        end
    end
    if eventReplaced ~= nil and eventReplaced then
        Logging.LogPrint("ERROR: " .. "failed placing " .. failedOnName .. " for second orientation, so giving up")
        TryInsertSimpleItems(placementSimpleItemStackTable, builderInventory, true, 1)
        TryInsertInventoryContents(fuelInventoryContents, builderInventory, true, 1)
        return
    end

    placedEntityDirection = LoopDirectionValue(placedEntityDirection + 4)
    local placedWagon = surface.create_entity {name = placedEntityName, position = placedEntityPosition, force = force, snap_to_train_stop = false, direction = placedEntityDirection}
    if placedWagon ~= nil then
        TryInsertInventoryContents(fuelInventoryContents, placedWagon.get_fuel_inventory(), true, 1)
        placedWagon.health = health
    else
        Logging.LogPrint("ERROR: " .. "failed to place origional " .. placedEntityName .. " back at " .. Logging.PositionToString(placedEntityPosition) .. " with new direction: " .. placedEntityDirection)
        TryInsertSimpleItems(placementSimpleItemStackTable, builderInventory, true, 1)
        TryInsertInventoryContents(fuelInventoryContents, builderInventory, true, 1)
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
    local frontWagonStaticData = StaticData.entityNames[frontCarriage.name]
    if frontWagonStaticData ~= nil and (frontWagonStaticData.type == "cargo-wagon" or frontWagonStaticData.type == "fluid-wagon") then
        local orientationDif = math.abs(frontCarriage.orientation - backCarriage.orientation)
        if orientationDif < 0.25 then
            frontCarriage.connect_rolling_stock(defines.rail_direction.front)
        else
            frontCarriage.connect_rolling_stock(defines.rail_direction.back)
        end
    end

    local backWagonStaticData = StaticData.entityNames[backCarriage.name]
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
        TryMoveInventoriesLuaItemStacks(singleTrainUnit.wagons.middleCargo.get_inventory(defines.inventory.cargo_wagon), playerInventory, false, 1)
    end
    TryMoveInventoriesLuaItemStacks(singleTrainUnit.wagons.forwardLoco.get_fuel_inventory(), playerInventory, false, 1)
    TryMoveInventoriesLuaItemStacks(singleTrainUnit.wagons.rearLoco.get_fuel_inventory(), playerInventory, false, 1)
    for _, wagon in pairs(singleTrainUnit.wagons) do
        local wagonGrid = wagon.grid
        if wagonGrid ~= nil then
            TryTakeGridsItems(wagonGrid, playerInventory, false)
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

    TryMoveInventoriesLuaItemStacks(singleTrainUnit.wagons.forwardLoco.get_fuel_inventory(), buffer, false, 1)
    TryMoveInventoriesLuaItemStacks(singleTrainUnit.wagons.rearLoco.get_fuel_inventory(), buffer, false, 1)
    for _, wagon in pairs(singleTrainUnit.wagons) do
        local wagonGrid = wagon.grid
        if wagonGrid ~= nil then
            TryTakeGridsItems(wagonGrid, buffer, false)
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
