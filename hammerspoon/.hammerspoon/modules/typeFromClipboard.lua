-- Type clipboard contents.
-- If clipboard exceeds 100 characters, requires a second press to confirm.

local MAX_SAFE_LENGTH = 100
local confirmed = false
local confirmTimer = nil

function typeFromClipboard()
    local contents = hs.pasteboard.getContents()
    if not contents or #contents == 0 then
        hs.alert.show("Clipboard is empty")
        return
    end

    if #contents > MAX_SAFE_LENGTH and not confirmed then
        local lines = select(2, contents:gsub("\n", "\n")) + 1
        hs.alert.show(string.format(
            "Clipboard: %d chars, %d lines — press again to type",
            #contents, lines
        ), 3)
        confirmed = true
        if confirmTimer then confirmTimer:stop() end
        confirmTimer = hs.timer.doAfter(3, function()
            confirmed = false
        end)
        return
    end

    confirmed = false
    hs.eventtap.keyStrokes(contents)
end
