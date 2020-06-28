--local Logging = require("utility/logging")

local Interfaces = {}
MOD = MOD or {}
MOD.interfaces = MOD.interfaces or {}

--Called from OnLoad() from each script file.
Interfaces.RegisterInterface = function(interfaceName, interfaceFunction)
    MOD.interfaces[interfaceName] = interfaceFunction
    return interfaceName
end

--Called when needed.
Interfaces.Call = function(interfaceName, ...)
    if MOD.interfaces[interfaceName] ~= nil then
        return MOD.interfaces[interfaceName](...)
    else
        error("WARNING: interface called that doesn't exist: " .. interfaceName)
    end
end

return Interfaces
