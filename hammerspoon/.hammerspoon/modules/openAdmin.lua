-- Module to open URLs with an ID from clipboard or selection.
-- Configuration options:
-- 1. Set ADMIN_URL in your init.lua before requiring this module, or
-- 2. Set SECRETS_PATH to customize secrets file location, or
-- 3. Default: Uses ~/.secrets.lua with `admin_url = 'https://example.com/id/'`
local textUtils = require("modules/utils/textUtils")

-- Initialise admin_url from configuration sources.
if not ADMIN_URL then
    local secretsPath = SECRETS_PATH or (os.getenv("HOME") .. "/.secrets.lua")
    local env = {}
    local chunk, err = loadfile(secretsPath, "t", env)
    if chunk then
        chunk()
        ADMIN_URL = env.admin_url
        if not ADMIN_URL then
            hs.alert.show("admin_url not found in secrets file.")
        end
    else
        hs.alert.show("Error loading secrets: " .. (err or "unknown error"))
    end
end

function openAdminWithId()
    if not ADMIN_URL then
        hs.alert.show("Admin URL not configured.")
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
        hs.urlevent.openURL(ADMIN_URL .. id)
        hs.alert.show("Opening admin page for account " .. id .. " (from " .. source .. ")")
    else
        hs.alert.show("No account ID found in selection or clipboard.")
    end

    -- Restore original clipboard after a short delay.
    hs.timer.doAfter(0.1, function()
        hs.pasteboard.setContents(originalClipboard)
    end)
end
