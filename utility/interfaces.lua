--local Logging = require("utility/logging")

local Interfaces = {}
MOD = MOD or {}
MOD.interfaces = MOD.interfaces or {}

function Interfaces.RegisterInterface(interfaceName, interfaceFunction)
    MOD.interfaces[interfaceName] = interfaceFunction
end

function Interfaces.Call(interfaceName, ...)
    if MOD.interfaces[interfaceName] ~= nil then
        return MOD.interfaces[interfaceName](...)
    else
        error("WARNING: interface called that doesn't exist: " .. interfaceName)
    end
end

return Interfaces
