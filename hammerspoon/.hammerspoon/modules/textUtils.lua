-- Common text utilities for text transformers.
local M = {}

-- Replace selected text with new text while preserving clipboard.
function M.replaceSelectedText(newText)
    -- Save current clipboard.
    local oldClipboard = hs.pasteboard.getContents()
    -- Set new text to clipboard.
    hs.pasteboard.setContents(newText)
    -- Paste over selection.
    hs.eventtap.keyStroke({"cmd"}, "v")
    -- Restore clipboard after a delay.
    hs.timer.doAfter(0.1, function()
        hs.pasteboard.setContents(oldClipboard)
    end)
end

-- Get currently selected text while preserving clipboard.
function M.getTextSelection()
    local oldText = hs.pasteboard.getContents()
    hs.eventtap.keyStroke({"cmd"}, "c")
    local text = hs.pasteboard.getContents()
    hs.pasteboard.setContents(oldText)
    return text
end

return M
