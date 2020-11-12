local SettingsManager = {}
local Utils = require("utility/utils")
local Logging = require("utility/logging")

SettingsManager.ExpectedValueTypes = {}
SettingsManager.ExpectedValueTypes.string = {name = "string", hasChildren = false}
SettingsManager.ExpectedValueTypes.number = {name = "number", hasChildren = false}
SettingsManager.ExpectedValueTypes.boolean = {name = "boolean", hasChildren = false}
SettingsManager.ExpectedValueTypes.arrayOfStrings = {name = "arrayOfStrings", hasChildren = true, childExpectedValueType = SettingsManager.ExpectedValueTypes.string}
SettingsManager.ExpectedValueTypes.arrayOfNumbers = {name = "arrayOfNumbers", hasChildren = true, childExpectedValueType = SettingsManager.ExpectedValueTypes.number}
SettingsManager.ExpectedValueTypes.arrayOfBooleans = {name = "arrayOfBooleans", hasChildren = true, childExpectedValueType = SettingsManager.ExpectedValueTypes.boolean}

SettingsManager.CreateGlobalGroupSettingsContainer = function(globalGroupsContainer, id, globalSettingContainerName)
    globalGroupsContainer[id] = globalGroupsContainer[id] or {}
    globalGroupsContainer[id][globalSettingContainerName] = globalGroupsContainer[id][globalSettingContainerName] or {}
    return globalGroupsContainer[id][globalSettingContainerName]
end

--[[
    If only 1 value is passed it sets ID 0 as that value. If array of expected values is recieved then each ID abvoe 0 uses the array value and ID 0 is set as the defaultValue.
    Value is converted to the expected type. If nil is returned this is deemed as invalid data entry and default value is returned alogn with non stopping error message.
    The expectedType value is passed to callback function "valueHandlingFunction" to be processed uniquely for each setting. If this is ommitted then the value is just straight assigned without any processing.
    Clears all instances of the setting from all groups in the groups container before updating. Only way to remove old stale data.
]]
SettingsManager.HandleSettingWithArrayOfValues = function(settingType, settingName, expectedValueType, defaultSettingsContainer, defaultValue, globalGroupsContainer, globalSettingContainerName, globalSettingName, valueHandlingFunction)
    if expectedValueType == nil or expectedValueType == "" then
        Logging.LogPrint("Setting '[" .. settingType .. "][" .. settingName .. "]' has no value type coded.")
        return
    elseif expectedValueType.name == nil or SettingsManager.ExpectedValueTypes[expectedValueType.name] == nil then
        Logging.LogPrint("Setting '[" .. settingType .. "][" .. settingName .. "]' has an invalid value type coded: '" .. tostring(expectedValueType.name) .. "'")
        return
    end

    for _, group in pairs(globalGroupsContainer) do
        group[globalSettingContainerName][globalSettingName] = nil
    end
    valueHandlingFunction = valueHandlingFunction or function(value)
            return value
        end
    local values = settings[settingType][settingName].value
    local tableOfValues = game.json_to_table(values)

    local isMultipleGroups
    if tableOfValues == nil or type(tableOfValues) ~= "table" then
        isMultipleGroups = false
    else -- is a table type of value for setting
        if not expectedValueType.hasChildren then
            isMultipleGroups = true
        else
            for k, v in pairs(tableOfValues) do
                if v ~= nil and type(v) == "table" then
                    isMultipleGroups = true
                    break
                end
            end
            isMultipleGroups = isMultipleGroups or false
        end
    end

    if isMultipleGroups then
        for id, value in pairs(tableOfValues) do
            local thisGlobalSettingContainer = SettingsManager.CreateGlobalGroupSettingsContainer(globalGroupsContainer, id, globalSettingContainerName)
            local typedValue = SettingsManager._ValueToType(value, expectedValueType)
            if typedValue ~= nil then
                thisGlobalSettingContainer[globalSettingName] = valueHandlingFunction(typedValue)
            else
                thisGlobalSettingContainer[globalSettingName] = valueHandlingFunction(defaultValue)
                Logging.LogPrint("Setting '[" .. settingType .. "][" .. settingName .. "]' for entry number '" .. id .. "' has an invalid value type. Expected a '" .. expectedValueType.name .. "' but got the value '" .. tostring(value) .. "', so using default value of '" .. tostring(defaultValue) .. "'")
            end
        end
        defaultSettingsContainer[globalSettingName] = valueHandlingFunction(defaultValue)
    else
        local value = tableOfValues or values
        local typedValue = SettingsManager._ValueToType(value, expectedValueType)
        if typedValue ~= nil then
            defaultSettingsContainer[globalSettingName] = valueHandlingFunction(typedValue)
        else
            defaultSettingsContainer[globalSettingName] = valueHandlingFunction(defaultValue)
            if not (expectedValueType.hasChildren and value == "") then
                -- If its an arrayOf type setting and an empty string is input don't show an error. Blank string is valid as well as an empty array JSON.
                Logging.LogPrint("Setting '[" .. settingType .. "][" .. settingName .. "]' isn't a valid JSON array and has an invalid value type for a single value. Expected a single or array of '" .. expectedValueType.name .. "' but got the value '" .. tostring(value) .. "', so using default value of '" .. tostring(defaultValue) .. "'")
            end
        end
    end
end

SettingsManager.GetSettingValueForId = function(globalGroupsContainer, id, globalSettingContainerName, settingName, defaultSettingsContainer)
    local thisGroup = globalGroupsContainer[id]
    if thisGroup ~= nil and thisGroup[globalSettingContainerName] ~= nil and thisGroup[globalSettingContainerName][settingName] ~= nil then
        return thisGroup[globalSettingContainerName][settingName]
    end
    if defaultSettingsContainer ~= nil and defaultSettingsContainer[settingName] ~= nil then
        return defaultSettingsContainer[settingName]
    end
    error("Trying to get mod setting '" .. settingName .. "' that doesn't exist")
end

-- Strips any % characters from a number value to avoid silly user entry issues.
SettingsManager._ValueToType = function(value, expectedType)
    if expectedType.name == SettingsManager.ExpectedValueTypes.string.name then
        if type(value) == "string" then
            return value
        else
            return nil
        end
    elseif expectedType.name == SettingsManager.ExpectedValueTypes.number.name then
        value = string.gsub(value, "%%", "")
        return tonumber(value)
    elseif expectedType.name == SettingsManager.ExpectedValueTypes.boolean.name then
        return Utils.ToBoolean(value)
    elseif expectedType.hasChildren then
        if type(value) ~= "table" then
            return nil
        end

        local tableOfTypedValues = {}
        for k, v in pairs(value) do
            local typedV = SettingsManager._ValueToType(v, expectedType.childExpectedValueType)
            if typedV ~= nil then
                tableOfTypedValues[k] = typedV
            else
                return nil
            end
        end
        return tableOfTypedValues
    end
end

return SettingsManager
