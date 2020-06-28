--local Logging = require("utility/logging")
local GuiActionsOpened = {}
MOD = MOD or {}
MOD.guiOpenedActions = MOD.guiOpenedActions or {}

--Called from the root of Control.lua
GuiActionsOpened.MonitorGuiOpenedActions = function()
    script.on_event(defines.events.on_gui_opened, GuiActionsOpened._HandleGuiOpenedAction)
end

--Called from OnLoad() from each script file.
--When actionFunction is triggered actionData argument passed: {actionName = actionName, playerIndex = playerIndex, entity = entity, data = data_passed_on_event_register, eventData = raw_factorio_event_data}
GuiActionsOpened.LinkGuiOpenedActionNameToFunction = function(actionName, actionFunction)
    if actionName == nil or actionFunction == nil then
        error("GuiActions.LinkGuiOpenedActionNameToFunction called with missing arguments")
    end
    MOD.guiOpenedActions[actionName] = actionFunction
end

--Called to register a specific entitie's GUI being opened to a named action.
GuiActionsOpened.RegisterEntityForGuiOpenedAction = function(entity, actionName, data)
    if entity == nil or actionName == nil then
        error("GuiActions.RegisterEntityForGuiOpenedAction called with missing arguments")
    end
    data = data or {}
    global.UTILITYGUIACTIONSENTITYGUIOPENED = global.UTILITYGUIACTIONSENTITYGUIOPENED or {}
    global.UTILITYGUIACTIONSENTITYGUIOPENED[entity.unit_number] = global.UTILITYGUIACTIONSENTITYGUIOPENED[entity.unit_number] or {}
    global.UTILITYGUIACTIONSENTITYGUIOPENED[entity.unit_number][actionName] = data
end

--Called when desired to remove a specific entitie's GUI being opened from triggering its action.
GuiActionsOpened.RemoveEntityForGuiOpenedAction = function(entity, actionName)
    if entity == nil or actionName == nil then
        error("GuiActions.RemoveEntityForGuiOpenedAction called with missing arguments")
    end
    if global.UTILITYGUIACTIONSENTITYGUIOPENED == nil or global.UTILITYGUIACTIONSENTITYGUIOPENED[entity.unit_number] == nil then
        return
    end
    global.UTILITYGUIACTIONSENTITYGUIOPENED[entity.unit_number][actionName] = nil
end

--Called to register a specific GUI type being opened to a named action. For GuiType it accepts defines.gui_type and "all".
GuiActionsOpened.RegisterActionNameForGuiTypeOpened = function(guiType, actionName, data)
    if guiType == nil or actionName == nil then
        error("GuiActions.RegisterActionNameForGuiTypeOpened called with missing arguments")
    end
    data = data or {}
    global.UTILITYGUIACTIONSGUITYPEOPENED = global.UTILITYGUIACTIONSGUITYPEOPENED or {}
    global.UTILITYGUIACTIONSGUITYPEOPENED[guiType] = global.UTILITYGUIACTIONSGUITYPEOPENED[guiType] or {}
    global.UTILITYGUIACTIONSGUITYPEOPENED[guiType][actionName] = data
end

--Called when desired to remove a specific GUI type opening from triggering its action.
GuiActionsOpened.RemoveActionNameForGuiTypeOpened = function(guiType, actionName)
    if guiType == nil or actionName == nil then
        error("GuiActions.RemoveActionNameForGuiTypeOpened called with missing arguments")
    end
    if global.UTILITYGUIACTIONSGUITYPEOPENED == nil or global.UTILITYGUIACTIONSGUITYPEOPENED[guiType] == nil then
        return
    end
    global.UTILITYGUIACTIONSGUITYPEOPENED[guiType][actionName] = nil
end

GuiActionsOpened._HandleGuiOpenedAction = function(event)
    local guiType, entityOpened = event.gui_type, event.entity

    if global.UTILITYGUIACTIONSGUITYPEOPENED ~= nil and guiType ~= nil then
        for _, guiTypeHandled in pairs({guiType, "all"}) do
            if global.UTILITYGUIACTIONSGUITYPEOPENED[guiTypeHandled] ~= nil then
                for actionName, data in pairs(global.UTILITYGUIACTIONSGUITYPEOPENED[guiTypeHandled]) do
                    local actionFunction = MOD.guiOpenedActions[actionName]
                    local actionData = {actionName = actionName, playerIndex = event.player_index, guiType = guiTypeHandled, data = data, eventData = event}
                    if actionFunction == nil then
                        error("ERROR: Entity GUI Opened Handler - no registered action for name: '" .. tostring(actionName) .. "'")
                        return
                    end
                    actionFunction(actionData)
                end
            end
        end
    end

    if global.UTILITYGUIACTIONSENTITYGUIOPENED ~= nil and entityOpened ~= nil and global.UTILITYGUIACTIONSENTITYGUIOPENED[entityOpened.unit_number] ~= nil then
        for actionName, data in pairs(global.UTILITYGUIACTIONSENTITYGUIOPENED[entityOpened.unit_number]) do
            local actionFunction = MOD.guiOpenedActions[actionName]
            local actionData = {actionName = actionName, playerIndex = event.player_index, entity = entityOpened, data = data, eventData = event}
            if actionFunction == nil then
                error("ERROR: Entity GUI Opened Handler - no registered action for name: '" .. tostring(actionName) .. "'")
                return
            end
            actionFunction(actionData)
        end
    end
end

return GuiActionsOpened
