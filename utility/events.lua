local Utils = require("utility/utils")
--local Logging = require("utility/logging")

local Events = {}
MOD = MOD or {}
MOD.events = MOD.events or {}
MOD.customEventNameToId = MOD.customEventNameToId or {}

function Events.RegisterEvent(eventName)
    local eventId
    if Utils.GetTableKeyWithValue(defines.events, eventName) ~= nil then
        eventId = eventName
    elseif MOD.customEventNameToId[eventName] ~= nil then
        eventId = MOD.customEventNameToId[eventName]
    elseif type(eventName) == "number" then
        eventId = eventName
    else
        eventId = script.generate_event_name()
        MOD.customEventNameToId[eventName] = eventId
    end
    script.on_event(eventId, Events._HandleEvent)
end

function Events.RegisterHandler(eventName, handlerName, handlerFunction)
    local eventId
    if MOD.customEventNameToId[eventName] ~= nil then
        eventId = MOD.customEventNameToId[eventName]
    else
        eventId = eventName
    end
    if MOD.events[eventId] == nil then
        MOD.events[eventId] = {}
    end
    MOD.events[eventId][handlerName] = handlerFunction
end

function Events.RemoveHandler(eventName, handlerName)
    if MOD.events[eventName] == nil then
        return
    end
    MOD.events[eventName][handlerName] = nil
end

function Events._HandleEvent(eventData)
    local eventId = eventData.name
    if MOD.events[eventId] == nil then
        return
    end
    for _, handlerFunction in pairs(MOD.events[eventId]) do
        handlerFunction(eventData)
    end
end

function Events.RaiseEvent(eventData)
    eventData.tick = game.tick
    local eventName = eventData.name
    if defines.events[eventName] ~= nil then
        script.raise_event(eventName, eventData)
    elseif MOD.customEventNameToId[eventName] ~= nil then
        local eventId = MOD.customEventNameToId[eventName]
        script.raise_event(eventId, eventData)
    elseif type(eventName) == "number" then
        script.raise_event(eventName, eventData)
    else
        error("WARNING: raise event called that doesn't exist: " .. eventName)
    end
end

return Events
