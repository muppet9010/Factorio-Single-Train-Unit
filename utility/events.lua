--[[
    Events is used to register one or more functions to be run when a script.event occurs.
    It supports defines.events and custom events. Also offers a raise event method.
    Intended for use with a modular script design to avoid having to link to each modulars functions in a centralised event handler.
]]
local Utils = require("utility/utils")

local Events = {}
MOD = MOD or {}
MOD.events = MOD.events or {}
MOD.customEventNameToId = MOD.customEventNameToId or {}
MOD.eventFilters = MOD.eventFilters or {}

-- Called from OnLoad() from each script file. Registers the event in Factorio and the handler function for all event types and custom inputs.
-- Filtered events have to expect to recieve results outside of their filter. As an event can only be registered one time, with multiple instances the most lienient or merged filters for all instances must be applied.
-- Returns the eventId, useful for custom event names when you need to store the eventId to return via a remote interface call.
-- If an empty table (not nil) is passed in to filterData then no event is registered and not eventId is returned. This is really for when a filter is dynamically generated and so we don;t want to do anything for an empty filer table oddity.
Events.RegisterHandlerEvent = function(eventName, handlerName, handlerFunction, thisFilterName, thisFilterData)
    if eventName == nil or handlerName == nil or handlerFunction == nil then
        error("Events.RegisterHandler called with missing arguments")
    end
    local eventId = Events._RegisterEvent(eventName, thisFilterName, thisFilterData)
    if eventId == nil then
        return nil
    end
    MOD.events[eventId] = MOD.events[eventId] or {}
    MOD.events[eventId][handlerName] = handlerFunction
    return eventId
end

-- Called from the root of Control.lua for custom inputs (key bindings) as their names are handled specially.
Events.RegisterCustomInput = function(actionName)
    if actionName == nil then
        error("Events.RegisterCustomInput called with missing arguments")
    end
    script.on_event(actionName, Events._HandleEvent)
end

-- Called when needed
Events.RemoveHandler = function(eventName, handlerName)
    if eventName == nil or handlerName == nil then
        error("Events.RemoveHandler called with missing arguments")
    end
    if MOD.events[eventName] == nil then
        return
    end
    MOD.events[eventName][handlerName] = nil
end

-- Called when needed, but not before tick 0 as they are ignored
Events.RaiseEvent = function(eventData)
    eventData.tick = game.tick
    local eventName = eventData.name
    if type(eventName) == "number" then
        script.raise_event(eventName, eventData)
    elseif MOD.customEventNameToId[eventName] ~= nil then
        local eventId = MOD.customEventNameToId[eventName]
        script.raise_event(eventId, eventData)
    else
        error("WARNING: raise event called that doesn't exist: " .. eventName)
    end
end

-- Called from anywhere, including OnStartup in tick 0. This won't be passed out to other mods however, only run within this mod.
Events.RaiseInternalEvent = function(eventData)
    eventData.tick = game.tick
    local eventName = eventData.name
    if type(eventName) == "number" then
        Events._HandleEvent(eventData)
    elseif MOD.customEventNameToId[eventName] ~= nil then
        eventData.name = MOD.customEventNameToId[eventName]
        Events._HandleEvent(eventData)
    else
        error("WARNING: raise event called that doesn't exist: " .. eventName)
    end
end

Events._HandleEvent = function(eventData)
    -- input_name used by custom_input , with eventId used by all other events
    local eventId, inputName = eventData.name, eventData.input_name
    if MOD.events[eventId] ~= nil then
        for _, handlerFunction in pairs(MOD.events[eventId]) do
            handlerFunction(eventData)
        end
    elseif MOD.events[inputName] ~= nil then
        for _, handlerFunction in pairs(MOD.events[inputName]) do
            handlerFunction(eventData)
        end
    end
end

Events._RegisterEvent = function(eventName, thisFilterName, thisFilterData)
    if eventName == nil then
        error("Events.RegisterEvent called with missing arguments")
    end
    local eventId, filterData
    thisFilterData = Utils.DeepCopy(thisFilterData) -- Deepcopy it so if a persisted or shared table is passed in we don't cause changes to source table.
    if type(eventName) == "number" then
        eventId = eventName
        if thisFilterData ~= nil then
            if Utils.IsTableEmpty(thisFilterData) then
                -- filter isn't nil, but has no data, so as this won't register to any filters just drop it.
                return nil
            end
            MOD.eventFilters[eventId] = MOD.eventFilters[eventId] or {}
            MOD.eventFilters[eventId][thisFilterName] = thisFilterData
            local currentFilter, currentHandler = script.get_event_filter(eventId), script.get_event_handler(eventId)
            if currentHandler ~= nil and currentFilter == nil then
                -- an event is registered already and has no filter, so already fully lienent.
                return eventId
            else
                -- add new filter to any existing old filter and let it be re-applied.
                filterData = {}
                for _, filterTable in pairs(MOD.eventFilters[eventId]) do
                    filterTable[1].mode = "or"
                    for _, filterEntry in pairs(filterTable) do
                        table.insert(filterData, filterEntry)
                    end
                end
            end
        end
    elseif MOD.customEventNameToId[eventName] ~= nil then
        eventId = MOD.customEventNameToId[eventName]
    else
        eventId = script.generate_event_name()
        MOD.customEventNameToId[eventName] = eventId
    end
    script.on_event(eventId, Events._HandleEvent, filterData)
    return eventId
end

return Events
