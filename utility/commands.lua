local Commands = {}
local Utils = require("utility/utils")

function Commands.Register(name, helpText, commandFunction, adminOnly)
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

--Supports string arguments with spaces within single or double quotes. No escaping of quotes within a command needed. Tables as json can NOT have spaces in them
function Commands.GetArgumentsFromCommand(parameterString)
    local args = {}
    local longArg = ""
    if parameterString ~= nil then
        for text in string.gmatch(parameterString or "nil", "%S+") do
            if (string.sub(text, 1, 1) == "'" and string.sub(text, -1) == "'") or (string.sub(text, 1, 1) == '"' and string.sub(text, -1) == '"') then
                table.insert(args, Commands._CheckValueType(text))
            elseif string.sub(text, 1, 1) == "'" or string.sub(text, 1, 1) == '"' then
                longArg = text
            elseif string.sub(text, -1) == "'" or string.sub(text, -1) == '"' then
                longArg = longArg .. " " .. text
                table.insert(args, Commands._CheckValueType(longArg))
                longArg = ""
            elseif longArg ~= "" then
                longArg = longArg .. " " .. text
            else
                table.insert(args, Commands._CheckValueType(text))
            end
        end
    end
    return args
end

function Commands._CheckValueType(text)
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
    return Commands._StripLeadingTrailingQuotes(text)
end

function Commands._StripLeadingTrailingQuotes(text)
    if string.sub(text, 1, 1) == "'" and string.sub(text, -1) == "'" then
        return string.sub(text, 2, -2)
    elseif string.sub(text, 1, 1) == '"' and string.sub(text, -1) == '"' then
        return string.sub(text, 2, -2)
    else
        return text
    end
end

return Commands
