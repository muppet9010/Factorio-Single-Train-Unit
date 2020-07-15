--local Logging = require("utility/logging")
local GuiActionsClosed = {}
MOD = MOD or {}
MOD.guiClosedActions = MOD.guiClosedActions or {}

--Called from the root of Control.lua
GuiActionsClosed.MonitorGuiClosedActions = function()
    script.on_event(defines.events.on_gui_closed, GuiActionsClosed._HandleGuiClosedAction)
end

--Called from OnLoad() from each script file.
--When actionFunction is triggered actionData argument passed: {actionName = actionName, playerIndex = playerIndex, entity = entity, data = data_passed_on_event_register, eventData = raw_factorio_event_data}
GuiActionsClosed.LinkGuiClosedActionNameToFunction = function(actionName, actionFunction)
    if actionName == nil or actionFunction == nil then
        error("GuiActions.LinkGuiClosedActionNameToFunction called with missing arguments")
    end
    MOD.guiClosedActions[actionName] = actionFunction
end

--Called to register a specific GUI type being closed to a named action. For GuiType it accepts defines.gui_type and "all".
GuiActionsClosed.RegisterActionNameForGuiTypeClosed = function(guiType, actionName, data)
    if guiType == nil or actionName == nil then
        error("GuiActions.RegisterActionNameForGuiTypeClosed called with missing arguments")
    end
    data = data or {}
    global.UTILITYGUIACTIONSGUITYPECLOSED = global.UTILITYGUIACTIONSGUITYPECLOSED or {}
    global.UTILITYGUIACTIONSGUITYPECLOSED[guiType] = global.UTILITYGUIACTIONSGUITYPECLOSED[guiType] or {}
    global.UTILITYGUIACTIONSGUITYPECLOSED[guiType][actionName] = data
end

--Called when desired to remove a specific GUI type closing from triggering its action.
GuiActionsClosed.RemoveActionNameForGuiTypeClosed = function(guiType, actionName)
    if guiType == nil or actionName == nil then
        error("GuiActions.RemoveActionNameForGuiTypeClosed called with missing arguments")
    end
    if global.UTILITYGUIACTIONSGUITYPECLOSED == nil or global.UTILITYGUIACTIONSGUITYPECLOSED[guiType] == nil then
        return
    end
    global.UTILITYGUIACTIONSGUITYPECLOSED[guiType][actionName] = nil
end

GuiActionsClosed._HandleGuiClosedAction = function(event)
    local guiType = event.gui_type

    if global.UTILITYGUIACTIONSGUITYPECLOSED ~= nil and guiType ~= nil then
        for _, guiTypeHandled in pairs({guiType, "all"}) do
            if global.UTILITYGUIACTIONSGUITYPECLOSED[guiTypeHandled] ~= nil then
                for actionName, data in pairs(global.UTILITYGUIACTIONSGUITYPECLOSED[guiTypeHandled]) do
                    local actionFunction = MOD.guiClosedActions[actionName]
                    local actionData = {actionName = actionName, playerIndex = event.player_index, guiType = guiTypeHandled, data = data, eventData = event}
                    if actionFunction == nil then
                        error("ERROR: Entity GUI Closed Handler - no registered action for name: '" .. tostring(actionName) .. "'")
                        return
                    end
                    actionFunction(actionData)
                end
            end
        end
    end
end

return GuiActionsClosed
