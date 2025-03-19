-- Sentence Case converter.
local textUtils = require("modules/textUtils")

local function toSentenceCase()
    local text = textUtils.getTextSelection()
    if not text or text == "" then return end
    local lowerText = string.lower(text)
    local sentenceEnders = {"%.", "!", "%?", "%…"}
    local result = lowerText

    if #result > 0 then
        result = string.upper(string.sub(result, 1, 1)) .. string.sub(result, 2)
    end

    -- Find all sentence endings and capitalise next character.
    for _, punctuation in ipairs(sentenceEnders) do
        result = string.gsub(result, punctuation .. "(%s+)([a-z])", function(space, letter)
            return punctuation .. space .. string.upper(letter)
        end)
    end

    -- Treat newlines as sentence separators.
    result = string.gsub(result, "(\r\n|\n|\r)([a-z])", function(newline, letter)
        return newline .. string.upper(letter)
    end)

    -- Capitalise first letter after colons in some cases (e.g., subtitles or explanations).
    result = string.gsub(result, ":(%s+)([a-z])", function(space, letter)
        return ":" .. space .. string.upper(letter)
    end)

    -- Always capitalise "i" as a standalone word.
    result = string.gsub(result, "(%s+)i(%s+)", "%1I%2")
    result = string.gsub(result, "^i(%s+)", "I%1")

    textUtils.replaceSelectedText(result)
end

hs.hotkey.bind({"cmd", "alt"}, "S", toSentenceCase)
