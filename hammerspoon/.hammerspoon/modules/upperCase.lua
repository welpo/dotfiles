-- Lowercase converter.
local textUtils = require("modules/utils/textUtils")

local function toUpperCase()
    local text = textUtils.getTextSelection()
    if not text or text == "" then return end
    local result = string.upper(text)
    textUtils.replaceSelectedText(result)
end

hs.hotkey.bind({"cmd", "alt"}, "U", toUpperCase)
