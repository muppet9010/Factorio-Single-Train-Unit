local GuiUtil = {}
local Constants = require("constants")

function GuiUtil.GenerateName(name, type)
    return Constants.ModName .. "-" .. name .. "-" .. type
end

function GuiUtil._ReplaceSelfWithGeneratedName(arguments, argName)
    local arg = arguments[argName]
    if arg == nil then
        arg = nil
    elseif arg == "self" then
        arg = {"gui-" .. argName .. "." .. arguments.name}
    elseif type(arg) == "table" and arg[1] ~= nil and arg[1] == "self" then
        arg[1] = "gui-" .. argName .. "." .. arguments.name
    end
    return arg
end

function GuiUtil.AddElement(arguments, storeName)
    --pass self as the caption/tooltip value or localised string name and it will be set to its GenerateName() under gui-caption/gui-tooltip
    arguments.name = GuiUtil.GenerateName(arguments.name, arguments.type)
    arguments.caption = GuiUtil._ReplaceSelfWithGeneratedName(arguments, "caption")
    arguments.tooltip = GuiUtil._ReplaceSelfWithGeneratedName(arguments, "tooltip")
    local element = arguments.parent.add(arguments)
    if storeName ~= nil then
        GuiUtil.AddElementToPlayersReferenceStorage(element.player_index, storeName, arguments.name, element)
    end
    return element
end

function GuiUtil._CreatePlayersElementReferenceStorage(playerIndex, storeName)
    global.GUIUtilPlayerElementReferenceStorage = global.GUIUtilPlayerElementReferenceStorage or {}
    global.GUIUtilPlayerElementReferenceStorage[playerIndex] = global.GUIUtilPlayerElementReferenceStorage[playerIndex] or {}
    global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName] = global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName] or {}
end

function GuiUtil.AddElementToPlayersReferenceStorage(playerIndex, storeName, fullName, element)
    GuiUtil._CreatePlayersElementReferenceStorage(playerIndex, storeName)
    global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName][fullName] = element
end

function GuiUtil.GetElementFromPlayersReferenceStorage(playerIndex, storeName, name, type)
    GuiUtil._CreatePlayersElementReferenceStorage(playerIndex, storeName)
    return global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName][GuiUtil.GenerateName(name, type)]
end

function GuiUtil.UpdateElementFromPlayersReferenceStorage(playerIndex, storeName, name, type, arguments)
    local element = GuiUtil.GetElementFromPlayersReferenceStorage(playerIndex, storeName, name, type)
    if element ~= nil then
        local generatedName = GuiUtil.GenerateName(name, type)
        for argName, argValue in pairs(arguments) do
            if argName == "caption" or argName == "tooltip" then
                argValue = GuiUtil._ReplaceSelfWithGeneratedName({name = generatedName, [argName] = argValue}, argName)
            end
            element[argName] = argValue
        end
    end
    return element
end

function GuiUtil.DestroyElementInPlayersReferenceStorage(playerIndex, storeName, name, type)
    local elementName = GuiUtil.GenerateName(name, type)
    if global.GUIUtilPlayerElementReferenceStorage ~= nil and global.GUIUtilPlayerElementReferenceStorage[playerIndex] ~= nil and global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName] ~= nil and global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName][elementName] ~= nil then
        if global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName][elementName].valid then
            global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName][elementName].destroy()
        end
        global.GUIUtilPlayerElementReferenceStorage[playerIndex][storeName][elementName] = nil
    end
end

function GuiUtil.DestroyPlayersReferenceStorage(playerIndex, storeName)
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

return GuiUtil
