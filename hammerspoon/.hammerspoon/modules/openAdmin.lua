-- Module to open URLs with an ID from clipboard or selection.
-- Requires setting up ~/.secrets.lua with: `admin_url = 'https://example.com/id/'`
local textUtils = require("modules/utils/textUtils")

do
    local secretsPath = os.getenv("HOME") .. "/.secrets.lua"
    local env = {}
    local chunk, err = loadfile(secretsPath, "t", env)
    if chunk then
        chunk()
        admin_url = env.admin_url
        if not admin_url then
            hs.alert.show("admin_url not found in secrets file")
        end
    else
        hs.alert.show("Error loading secrets: " .. (err or "unknown error"))
    end
end

function openAdminWithId()
    if not admin_url then
        hs.alert.show("Admin URL not configured")
        return
    end

    -- Save original clipboard content.
    local originalClipboard = hs.pasteboard.getContents()
    local id = nil
    local source = nil

    -- Check if selected text contains a number.
    local selectedText = textUtils.getTextSelection()
    if selectedText and string.match(selectedText, "^%d+$") then
        id = selectedText
        source = "selection"
    -- If no valid selection, check the clipboard for a number.
    elseif originalClipboard and string.match(originalClipboard, "^%d+$") then
        id = originalClipboard
        source = "clipboard"
    end

    if id then
        hs.urlevent.openURL(admin_url .. id)
        hs.alert.show("Opening admin page for account " .. id .. " (from " .. source .. ")")
    else
        hs.alert.show("No account ID found in selection or clipboard")
    end

    -- Restore original clipboard after a short delay.
    hs.timer.doAfter(0.1, function()
        hs.pasteboard.setContents(originalClipboard)
    end)
end

hs.hotkey.bind(cmdCtrl, "A", openAdminWithId)
