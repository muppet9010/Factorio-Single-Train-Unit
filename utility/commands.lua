local Commands = {}
local Utils = require("utility/utils")

-- Call from OnLoad
Commands.Register = function(name, helpText, commandFunction, adminOnly)
    commands.remove_command(name)
    local handlerFunction
    if not adminOnly then
        handlerFunction = commandFunction
    elseif adminOnly then
        handlerFunction = function(data)
            if data.player_index == nil then
                commandFunction(data)
            else
                local player = game.get_player(data.player_index)
                if player.admin then
                    commandFunction(data)
                else
                    player.print("Must be an admin to run command: " .. data.name)
                end
            end
        end
    end
    commands.add_command(name, helpText, handlerFunction)
end

-- Supports multiple string arguments seperated by a space as a commands parameter. Can use pairs of single or double quotes to define the start and end of an argument string with spaces in it. Supports JSON array [] and dictionary {} of N depth and content characters.
-- String quotes can be escaped by "\"" within their own quote type, ie: 'don\'t' will come out as "don't". Note the same quote type rule, i.e. "don\'t" will come out as "don\'t" . Otherwise the escape character \ wil be passed through as regular text.
-- Returns a table of sequentially indexed arguments
Commands.GetArgumentsFromCommand = function(parameterString)
    local args = {}
    if parameterString == nil or parameterString == "" or parameterString == " " then
        return args
    end
    local openCloseChars = {
        ["{"] = "}",
        ["["] = "]",
        ['"'] = '"',
        ["'"] = "'"
    }
    local escapeChar = "\\"

    local currentString, inQuotedString, inJson, openChar, closeChar, jsonSteppedIn, prevCharEscape = "", false, false, "", "", 0, false
    for char in string.gmatch(parameterString, ".") do
        if not inJson then
            if char == "{" or char == "[" then
                inJson = true
                openChar = char
                closeChar = openCloseChars[openChar]
                currentString = char
            elseif not inQuotedString and char ~= " " then
                if char == '"' or char == "'" then
                    inQuotedString = true
                    openChar = char
                    closeChar = openCloseChars[openChar]
                    if currentString ~= "" then
                        table.insert(args, Commands._StringToTypedObject(currentString))
                        currentString = ""
                    end
                else
                    currentString = currentString .. char
                end
            elseif not inQuotedString and char == " " then
                if currentString ~= "" then
                    table.insert(args, Commands._StringToTypedObject(currentString))
                    currentString = ""
                end
            elseif inQuotedString then
                if char == escapeChar then
                    prevCharEscape = true
                else
                    if char == closeChar and not prevCharEscape then
                        inQuotedString = false
                        table.insert(args, Commands._StringToTypedObject(currentString))
                        currentString = ""
                    elseif char == closeChar and prevCharEscape then
                        prevCharEscape = false
                        currentString = currentString .. char
                    elseif prevCharEscape then
                        prevCharEscape = false
                        currentString = currentString .. escapeChar .. char
                    else
                        currentString = currentString .. char
                    end
                end
            end
        else
            currentString = currentString .. char
            if char == openChar then
                jsonSteppedIn = jsonSteppedIn + 1
            elseif char == closeChar then
                if jsonSteppedIn > 0 then
                    jsonSteppedIn = jsonSteppedIn - 1
                else
                    inJson = false
                    table.insert(args, Commands._StringToTypedObject(currentString))
                    currentString = ""
                end
            end
        end
    end
    if currentString ~= "" then
        table.insert(args, Commands._StringToTypedObject(currentString))
    end

    return args
end

Commands._StringToTypedObject = function(text)
    if text == "nil" then
        return nil
    end
    local castedText = tonumber(text)
    if castedText ~= nil then
        return castedText
    end
    castedText = Utils.ToBoolean(text)
    if castedText ~= nil then
        return castedText
    end
    castedText = game.json_to_table(text)
    if castedText ~= nil then
        return castedText
    end
    return text
end

return Commands
