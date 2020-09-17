local Logging = {}
local Constants = require("constants")

Logging.PositionToString = function(position)
    if position == nil then
        return "nil position"
    end
    return "(" .. position.x .. ", " .. position.y .. ")"
end

Logging.BoundingBoxToString = function(boundingBox)
    if boundingBox == nil then
        return "nil boundingBox"
    end
    return "((" .. boundingBox.left_top.x .. ", " .. boundingBox.left_top.y .. "), (" .. boundingBox.right_bottom.x .. ", " .. boundingBox.right_bottom.y .. "))"
end

Logging.Log = function(text, enabled)
    if enabled ~= nil and not enabled then
        return
    end
    if game ~= nil then
        if Constants.LogFileName == nil or Constants.LogFileName == "" then
            game.print("ERROR - No Constants.LogFileName set")
            log("ERROR - No Constants.LogFileName set")
        end
        game.write_file(Constants.LogFileName, tostring(text) .. "\r\n", true)
        log(tostring(text))
    else
        log(tostring(text))
    end
end

Logging.LogPrint = function(text, enabled)
    if enabled ~= nil and not enabled then
        return
    end
    if game ~= nil then
        --Won't print on 0 tick (startup) due to core game limitation. Either use the EventScheduler.GamePrint to do this or handle it another way at usage time.
        game.print(tostring(text))
    end
    Logging.Log(text)
end

return Logging
