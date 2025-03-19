-- Lowercase converter.
local textUtils = require("modules/textUtils")

local function toLowerCase()
    local text = textUtils.getTextSelection()
    if not text or text == "" then return end
    local result = string.lower(text)
    textUtils.replaceSelectedText(result)
end

hs.hotkey.bind({"cmd", "alt"}, "U", toLowerCase)

return toLowerCase
