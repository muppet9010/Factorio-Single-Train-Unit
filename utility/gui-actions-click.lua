--local Logging = require("utility/logging")
local GuiActionsClick = {}
local Constants = require("constants")
MOD = MOD or {}
MOD.guiClickActions = MOD.guiClickActions or {}

--Called from the root of Control.lua
GuiActionsClick.MonitorGuiClickActions = function()
    script.on_event(defines.events.on_gui_click, GuiActionsClick._HandleGuiClickAction)
end

--Called from OnLoad() from each script file.
--When actionFunction is triggered actionData argument passed: {actionName = actionName, playerIndex = playerIndex, data = data_passed_on_event_register, eventData = raw_factorio_event_data}
GuiActionsClick.LinkGuiClickActionNameToFunction = function(actionName, actionFunction)
    if actionName == nil or actionFunction == nil then
        error("GuiActions.LinkGuiClickActionNameToFunction called with missing arguments")
    end
    MOD.guiClickActions[actionName] = actionFunction
end

--Generally called from the GuiUtil library now, but can be called manually.
--Called after creating a button or other GuiElement is created to register a specific GUI click action name to it.
-- Optional data will be passed through to the actionName when called. If disabled is true then click not registered (for use with GUI templating).
GuiActionsClick.RegisterGuiForClick = function(elementName, elementType, actionName, data, disabled)
    if elementName == nil or elementType == nil or actionName == nil then
        error("GuiActions.RegisterGuiForClick called with missing arguments")
    end
    local name = GuiActionsClick.GenerateGuiElementName(elementName, elementType)
    global.UTILITYGUIACTIONSGUICLICK = global.UTILITYGUIACTIONSGUICLICK or {}
    if not disabled then
        global.UTILITYGUIACTIONSGUICLICK[name] = {actionName = actionName, data = data}
    else
        global.UTILITYGUIACTIONSGUICLICK[name] = nil
    end
end

-- Called when desired to remove a specific button or other GuiElement from triggering its action.
-- Should be called to remove links for buttons when their elements are removed to stop global data lingering.
-- ElementType is only needed if you are supplying raw name and not the name of a created element.
GuiActionsClick.RemoveGuiForClick = function(elementName, elementType)
    if elementName == nil then
        error("GuiActions.RemoveButtonName called with missing arguments")
    end
    if global.UTILITYGUIACTIONSGUICLICK == nil then
        return
    end
    local name = elementName
    if elementType ~= nil then
        name = GuiActionsClick.GenerateGuiElementName(elementName, elementType)
    end
    global.UTILITYGUIACTIONSGUICLICK[name] = nil
end

GuiActionsClick._HandleGuiClickAction = function(rawFactorioEventData)
    if global.UTILITYGUIACTIONSGUICLICK == nil then
        return
    end
    local clickedElementName = rawFactorioEventData.element.name
    local guiClickDetails = global.UTILITYGUIACTIONSGUICLICK[clickedElementName]
    if guiClickDetails ~= nil then
        local actionName = guiClickDetails.actionName
        local actionFunction = MOD.guiClickActions[actionName]
        local actionData = {actionName = actionName, playerIndex = rawFactorioEventData.player_index, data = guiClickDetails.data, eventData = rawFactorioEventData}
        if actionFunction == nil then
            error("ERROR: GUI Click Handler - no registered action for name: '" .. tostring(actionName) .. "'")
            return
        end
        actionFunction(actionData)
    else
        return
    end
end

--Just happens to be the same as in GuiUtil, but not a requirement.
GuiActionsClick.GenerateGuiElementName = function(name, type)
    if name == nil then
        return nil
    else
        return Constants.ModName .. "-" .. name .. "-" .. type
    end
end

return GuiActionsClick
