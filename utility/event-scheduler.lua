--local Logging = require("utility/logging")
local Utils = require("utility/utils")
local EventScheduler = {}
MOD = MOD or {}
MOD.scheduledEventNames = MOD.scheduledEventNames or {}

--Called from the root of Control.lua
EventScheduler.RegisterScheduler = function()
    script.on_event(defines.events.on_tick, EventScheduler._OnSchedulerCycle)
end

--Called from OnLoad() from each script file.
--When eventFunction is triggered eventData argument passed: {tick = tick, name = eventName, instanceId = instanceId, data = scheduledFunctionData}
EventScheduler.RegisterScheduledEventType = function(eventName, eventFunction)
    if eventName == nil or eventFunction == nil then
        error("EventScheduler.RegisterScheduledEventType called with missing arguments")
    end
    MOD.scheduledEventNames[eventName] = eventFunction
end

--Called from OnStartup() or from some other event or trigger to schedule an event.
EventScheduler.ScheduleEvent = function(eventTick, eventName, instanceId, eventData)
    if eventName == nil then
        error("EventScheduler.ScheduleEvent called with missing arguments")
    end
    local nowTick = game.tick
    if eventTick == nil or eventTick <= nowTick then
        eventTick = nowTick + 1
    end
    instanceId = EventScheduler._GetDefaultInstanceId(instanceId)
    eventData = eventData or {}
    global.UTILITYSCHEDULEDFUNCTIONS = global.UTILITYSCHEDULEDFUNCTIONS or {}
    global.UTILITYSCHEDULEDFUNCTIONS[eventTick] = global.UTILITYSCHEDULEDFUNCTIONS[eventTick] or {}
    global.UTILITYSCHEDULEDFUNCTIONS[eventTick][eventName] = global.UTILITYSCHEDULEDFUNCTIONS[eventTick][eventName] or {}
    if global.UTILITYSCHEDULEDFUNCTIONS[eventTick][eventName][instanceId] ~= nil then
        error("WARNING: Overridden schedule event: '" .. eventName .. "' id: '" .. instanceId .. "' at tick: " .. eventTick)
    end
    global.UTILITYSCHEDULEDFUNCTIONS[eventTick][eventName][instanceId] = eventData
end

--Called whenever required.
EventScheduler.IsEventScheduled = function(targetEventName, targetInstanceId, targetTick)
    if targetEventName == nil then
        error("EventScheduler.IsEventScheduled called with missing arguments")
    end
    local result = EventScheduler._ParseScheduledEvents(targetEventName, targetInstanceId, targetTick, EventScheduler._IsEventScheduledInTickEntry)
    if result ~= true then
        result = false
    end
    return result
end

--Called whenever required.
EventScheduler.RemoveScheduledEvents = function(targetEventName, targetInstanceId, targetTick)
    if targetEventName == nil then
        error("EventScheduler.RemoveScheduledEvents called with missing arguments")
    end
    EventScheduler._ParseScheduledEvents(targetEventName, targetInstanceId, targetTick, EventScheduler._RemoveScheduledEventsFromTickEntry)
end

--Called whenever required.
EventScheduler.GetScheduledEvents = function(targetEventName, targetInstanceId, targetTick)
    if targetEventName == nil then
        error("EventScheduler.GetScheduledEvents called with missing arguments")
    end
    local _, results = EventScheduler._ParseScheduledEvents(targetEventName, targetInstanceId, targetTick, EventScheduler._GetScheduledEventsFromTickEntry)
    return results
end

EventScheduler._GetDefaultInstanceId = function(instanceId)
    return instanceId or ""
end

EventScheduler._OnSchedulerCycle = function(event)
    local tick = event.tick
    if global.UTILITYSCHEDULEDFUNCTIONS == nil then
        return
    end
    if global.UTILITYSCHEDULEDFUNCTIONS[tick] ~= nil then
        for eventName, instances in pairs(global.UTILITYSCHEDULEDFUNCTIONS[tick]) do
            for instanceId, scheduledFunctionData in pairs(instances) do
                local eventData = {tick = tick, name = eventName, instanceId = instanceId, data = scheduledFunctionData}
                if MOD.scheduledEventNames[eventName] ~= nil then
                    MOD.scheduledEventNames[eventName](eventData)
                else
                    error("WARNING: schedule event called that doesn't exist: '" .. eventName .. "' id: '" .. instanceId .. "' at tick: " .. tick)
                end
            end
        end
        global.UTILITYSCHEDULEDFUNCTIONS[tick] = nil
    end
end

EventScheduler._ParseScheduledEvents = function(targetEventName, targetInstanceId, targetTick, actionFunction)
    targetInstanceId = EventScheduler._GetDefaultInstanceId(targetInstanceId)
    local result, results = nil, {}
    if targetTick == nil then
        for tick, events in pairs(global.UTILITYSCHEDULEDFUNCTIONS) do
            local outcome = actionFunction(events, targetEventName, targetInstanceId, tick)
            if outcome ~= nil then
                result = outcome.result
                if outcome.results ~= nil then
                    table.insert(results, outcome.results)
                end
                if result then
                    break
                end
            end
        end
    else
        local events = global.UTILITYSCHEDULEDFUNCTIONS[targetTick]
        if events ~= nil then
            local outcome = actionFunction(events, targetEventName, targetInstanceId)
            result = outcome.result
            if outcome.results ~= nil then
                table.insert(results, outcome.results)
            end
        end
    end
    return result, results
end

EventScheduler._IsEventScheduledInTickEntry = function(events, targetEventName, targetInstanceId)
    if events[targetEventName] ~= nil and events[targetEventName][targetInstanceId] ~= nil then
        return {result = true}
    end
end

EventScheduler._RemoveScheduledEventsFromTickEntry = function(events, targetEventName, targetInstanceId, tick)
    if events[targetEventName] ~= nil then
        events[targetEventName][targetInstanceId] = nil
        if Utils.GetTableNonNilLength(events[targetEventName]) == 0 then
            events[targetEventName] = nil
        end
    end
    if Utils.GetTableNonNilLength(events) == 0 then
        global.UTILITYSCHEDULEDFUNCTIONS[tick] = nil
    end
end

EventScheduler._GetScheduledEventsFromTickEntry = function(events, targetEventName, targetInstanceId, tick)
    if events[targetEventName] ~= nil and events[targetEventName][targetInstanceId] ~= nil then
        local scheduledEvent = {
            tick = tick,
            eventName = targetEventName,
            instanceId = targetInstanceId,
            eventData = events[targetEventName][targetInstanceId]
        }
        return {results = scheduledEvent}
    end
end

return EventScheduler
