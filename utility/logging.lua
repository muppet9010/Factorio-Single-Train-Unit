local Logging = {}
local Constants = require("constants")

function Logging.PositionToString(position)
    if position == nil then
        return "nil position"
    end
    return "(" .. position.x .. ", " .. position.y .. ")"
end

function Logging.BoundingBoxToString(boundingBox)
    if boundingBox == nil then
        return "nil boundingBox"
    end
    return "((" .. boundingBox.left_top.x .. ", " .. boundingBox.left_top.y .. "), (" .. boundingBox.right_bottom.x .. ", " .. boundingBox.right_bottom.y .. "))"
end

function Logging.Log(text, enabled)
    if enabled ~= nil and not enabled then
        return
    end
    if game ~= nil then
        game.write_file(Constants.LogFileName, tostring(text) .. "\r\n", true)
    else
        log(tostring(text))
    end
end

function Logging.LogPrint(text, enabled)
    if enabled ~= nil and not enabled then
        return
    end
    if game ~= nil then
        game.print(tostring(text))
    end
    Logging.Log(text)
end

return Logging
