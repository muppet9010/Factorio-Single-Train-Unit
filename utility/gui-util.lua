local GuiUtil = {}
local Utils = require("utility/utils")
local GuiActionsClick = require("utility/gui-actions-click")
local Logging = require("utility/logging")
local Constants = require("constants")
local StyleDataStyleVersion = require("utility/style-data").styleVersion

--[[
    - elementDetails takes everything that GuiElement.add() accepts in Factorio API. Plus compulsory "parent" argument of who to create the GUI element under if it isn't a child element.
    - The "name" argument will be merged with the mod name and type to try and ensure a unique name is given to the GUI element in Factorio API.
    - The "style" argument will be checked for starting with "muppet_" and if so merged with the style-data version to handle the style prototype version control.
    - The optional "children" argument is an array of other elements detail's arrays, to recursively add in this hierachy. Parent argument isn't required and is ignored for children, as it is worked out during recursive loop.
    - Passing the string "self" as the caption/tooltip value or localised string name will be auto replaced to its unique mod auto generated name under gui-caption/gui-tooltip. This avoids having to duplicate name when defining the element's arguments.
    - The optional "styling" argument of a table of style attributes to be applied post element creation. Saves having to capture local reference to do this with at element declaration point.
    - The optional "registerClick" passes the supplied "actionName" string, the optional "data" table and the optional disabled boolean to GuiActionsClick.RegisterGuiForClick().
    - The optional "returnElement" if true will return the element in a table of elements. Key will be the elements name..type and the value a reference to the element.
    - The optional "exclude" if true will mean the GUI Element is ignored. To allow more natural templating.
    - The optional "attributes" is a table of k v pairs that is applied to the element via the API post element creation. V can be a return function wrapped around another function if you want it to be executed post element creation. i.e. function() return MyMainFunction("bob") end. Intended for the occasioanl adhock attributes you want to set which can't be done in the add() API function. i.e. drag_target or auto_center.
]]
GuiUtil.AddElement = function(elementDetails)
    if elementDetails.exclude == true then
        return
    end
    local rawName = elementDetails.name
    elementDetails.name = GuiUtil.GenerateGuiElementName(elementDetails.name, elementDetails.type)
    elementDetails.caption = GuiUtil._ReplaceSelfWithGeneratedName(elementDetails, "caption")
    elementDetails.tooltip = GuiUtil._ReplaceSelfWithGeneratedName(elementDetails, "tooltip")
    if string.sub(elementDetails.style, 1, 7) == "muppet_" then
        elementDetails.style = elementDetails.style .. StyleDataStyleVersion
    end
    local returnElements = {}
    local attributes, returnElement, storeName, styling, registerClick, children = elementDetails.attributes, elementDetails.returnElement, elementDetails.storeName, elementDetails.styling, elementDetails.registerClick, elementDetails.children
    elementDetails.attributes, elementDetails.returnElement, elementDetails.storeName, elementDetails.styling, elementDetails.registerClick, elementDetails.children = nil, nil, nil, nil, nil, nil
    local element = elementDetails.parent.add(elementDetails)
    if returnElement then
        if elementDetails.name == nil then
            Logging.LogPrint("ERROR: GuiUtil.AddElement returnElement attribute requires element name to be supplied.")
        else
            returnElements[elementDetails.name] = element
        end
    end
    if storeName ~= nil then
        if elementDetails.name == nil then
            Logging.LogPrint("ERROR: GuiUtil.AddElement storeName attribute requires element name to be supplied.")
        else
            GuiUtil.AddElementToPlayersReferenceStorage(element.player_index, storeName, elementDetails.name, element)
        end
    end
    if styling ~= nil then
        GuiUtil._ApplyStylingArgumentsToElement(element, styling)
    end
    if registerClick ~= nil then
        if elementDetails.name == nil then
            Logging.LogPrint("ERROR: GuiUtil.AddElement registerClick attribute requires element name to be supplied.")
        else
            GuiActionsClick.RegisterGuiForClick(rawName, elementDetails.type, registerClick.actionName, registerClick.data, registerClick.disabled)
        end
    end
    if attributes ~= nil then
        for k, v in pairs(attributes) do
            if type(v) == "function" then
                v = v()
            end
            element[k] = v
        end
    end
    if children ~= nil then
        for _, child in pairs(children) do
            if type(child) ~= "table" then
                Logging.LogPrint("ERROR: GuiUtil.AddElement children not supplied as an array of child details in their own table.")
            else
                child.parent = element
                local childReturnElements = GuiUtil.AddElement(child)
                if childReturnElements ~= nil then
                    returnElements = Utils.TableMerge({returnElements, childReturnElements})
                end
            end
        end
    end
    if Utils.GetTableNonNilLength(returnElements) then
        return returnElements
    else
        return nil
    end
end

--Gets a specific name and type from the returned elements table from the GuiUtil.AddElement() function.
GuiUtil.GetNameFromReturnedElements = function(returnedElements, elementName, elementType)
    if returnedElements == nil then
        return nil
    else
        return returnedElements[GuiUtil.GenerateGuiElementName(elementName, elementType)]
    end
end

GuiUtil._CreatePlayersElementReferenceStorage = function(playerIndex, storeName)
    global.GUIUtilPlayerElementReferenceStorage = global.GUIUtilPlayerElementReferenceStorage or {}
    global.GUIUtilPlayerElementReferenceStorage[playerIndex] = global.GUIUtilPlayerElementReferenceStorage[playerIndex] or {}
    global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName] = global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName] or {}
end

GuiUtil.AddElementToPlayersReferenceStorage = function(playerIndex, storeName, fullName, element)
    GuiUtil._CreatePlayersElementReferenceStorage(playerIndex, storeName)
    global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName][fullName] = element
end

GuiUtil.GetElementFromPlayersReferenceStorage = function(playerIndex, storeName, name, type)
    GuiUtil._CreatePlayersElementReferenceStorage(playerIndex, storeName)
    return global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName][GuiUtil.GenerateGuiElementName(name, type)]
end

--Similar options as AddElement where arguments exist. Some don't make sense for updating and so not supported.
GuiUtil.UpdateElementFromPlayersReferenceStorage = function(playerIndex, storeName, name, type, arguments, ignoreMissingElement)
    ignoreMissingElement = ignoreMissingElement or false
    local element = GuiUtil.GetElementFromPlayersReferenceStorage(playerIndex, storeName, name, type)
    if element ~= nil then
        local generatedName = GuiUtil.GenerateGuiElementName(name, type)
        if arguments.styling ~= nil then
            GuiUtil._ApplyStylingArgumentsToElement(element, arguments.styling)
            arguments.styling = nil
        end
        if arguments.registerClick ~= nil then
            GuiActionsClick.RegisterGuiForClick(name, type, arguments.registerClick.actionName, arguments.registerClick.data, arguments.registerClick.disabled)
            arguments.registerClick = nil
        end
        if arguments.storeName ~= nil then
            Logging.LogPrint("ERROR: GuiUtil.UpdateElementFromPlayersReferenceStorage doesn't support storeName for element name '" .. name .. "' and type '" .. type .. "'")
            arguments.storeName = nil
        end
        if arguments.returnElement ~= nil then
            Logging.LogPrint("ERROR: GuiUtil.UpdateElementFromPlayersReferenceStorage doesn't support returnElement for element name '" .. name .. "' and type '" .. type .. "'")
            arguments.returnElement = nil
        end
        if arguments.children ~= nil then
            Logging.LogPrint("ERROR: GuiUtil.UpdateElementFromPlayersReferenceStorage doesn't support children for element name '" .. name .. "' and type '" .. type .. "'")
            arguments.children = nil
        end
        if arguments.attributes ~= nil then
            for k, v in pairs(arguments.attributes) do
                if type(v) == "function" then
                    v = v()
                end
                element[k] = v
            end
            arguments.attributes = nil
        end

        for argName, argValue in pairs(arguments) do
            if argName == "caption" or argName == "tooltip" then
                argValue = GuiUtil._ReplaceSelfWithGeneratedName({name = generatedName, [argName] = argValue}, argName)
            end
            element[argName] = argValue
        end
    elseif not ignoreMissingElement then
        Logging.LogPrint("ERROR: GuiUtil.UpdateElementFromPlayersReferenceStorage didn't find a GUI element for name '" .. name .. "' and type '" .. type .. "'")
    end
    return element
end

GuiUtil.DestroyElementInPlayersReferenceStorage = function(playerIndex, storeName, name, type)
    local elementName = GuiUtil.GenerateGuiElementName(name, type)
    if global.GUIUtilPlayerElementReferenceStorage ~= nil and global.GUIUtilPlayerElementReferenceStorage[playerIndex] ~= nil and global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName] ~= nil and global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName][elementName] ~= nil then
        if global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName][elementName].valid then
            global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName][elementName].destroy()
        end
        global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName][elementName] = nil
    end
end

GuiUtil.DestroyPlayersReferenceStorage = function(playerIndex, storeName)
    if global.GUIUtilPlayerElementReferenceStorage == nil or global.GUIUtilPlayerElementReferenceStorage[playerIndex] == nil then
        return
    end
    if storeName == nil then
        for _, store in pairs(global.GUIUtilPlayerElementReferenceStorage[playerIndex]) do
            for _, element in pairs(store) do
                if element.valid then
                    element.destroy()
                end
            end
        end
        global.GUIUtilPlayerElementReferenceStorage[playerIndex] = nil
    else
        if global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName] == nil then
            return
        end
        for _, element in pairs(global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName]) do
            if element.valid then
                element.destroy()
            end
        end
        global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName] = nil
    end
end

GuiUtil._ApplyStylingArgumentsToElement = function(element, stylingArgs)
    if stylingArgs.column_alignments ~= nil then
        for k, v in pairs(stylingArgs.column_alignments) do
            element.style.column_alignments[k] = v
        end
        stylingArgs.column_alignments = nil
    end
    for k, v in pairs(stylingArgs) do
        element.style[k] = v
    end
end

GuiUtil._ReplaceSelfWithGeneratedName = function(arguments, argName)
    local arg = arguments[argName]
    local name = arguments.name or "missing"
    if arg == nil then
        arg = nil
    elseif arg == "self" then
        arg = {"gui-" .. argName .. "." .. name}
    elseif type(arg) == "table" and arg[1] ~= nil and arg[1] == "self" then
        arg[1] = "gui-" .. argName .. "." .. name
    end
    return arg
end

GuiUtil.GenerateGuiElementName = function(name, type)
    if name == nil then
        return nil
    else
        return Constants.ModName .. "-" .. name .. "-" .. type
    end
end

return GuiUtil
