-- Display dates from epoch timestamps in the centre of the screen.
local textUtils = require("modules/utils/textUtils")

-- Configuration - set these in init.lua before requiring.
DATE_DISPLAY_DURATION = 4  -- How long to show the date alert.
DATE_FORMAT = "%Y-%m-%d %H:%M:%S"  -- Standard datetime format.

-- Display date from selected text.
function displayDateFromSelection()
    local text = textUtils.getTextSelection()
    -- Try to convert to number, handling both standard epochs and millisecond epochs.
    local timestamp = tonumber(text)
    if timestamp then
        -- If timestamp seems too large (milliseconds), convert to seconds.
        if timestamp > 10000000000 then
            timestamp = timestamp / 1000
        end
        local dateString = os.date(DATE_FORMAT or "%Y-%m-%d %H:%M:%S", timestamp)
        hs.alert.show(dateString, DATE_DISPLAY_DURATION or 4)
    else
        hs.alert.show("Not a valid timestamp: " .. text, DATE_DISPLAY_DURATION or 4)
    end
end
