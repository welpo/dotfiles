-- Title Case converter

local function replaceSelectedText(newText)
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
local function getTextSelection()
    local oldText = hs.pasteboard.getContents()
    hs.eventtap.keyStroke({"cmd"}, "c")
    local text = hs.pasteboard.getContents()
    hs.pasteboard.setContents(oldText)
    if text ~= oldText then
        return text
    else
        return ""
    end
end

-- Based on APA rules.
local doNotCapitalize = {
    -- Articles.
    "a", "an", "the",

    -- Short coordinating conjunctions.
    "and", "but", "or", "nor", "so", "yet", "for",

    -- Short subordinating conjunctions.
    "as", "if",

    -- Short prepositions.
    "at", "by", "for", "in", "of", "off", "on", "out",
    "per", "to", "up", "via", "re", "vs"
}

-- Convert list to lookup table for faster checking.
local doNotCapitalizeMap = {}
for _, word in ipairs(doNotCapitalize) do
    doNotCapitalizeMap[word] = true
end

local function toTitleCase()
    local text = getTextSelection()
    if not text or text == "" then return end

    -- Split by spaces, process, then join.
    local result = ""
    local isFirstWord = true
    local isAfterColon = false

    -- Iterate through each word and space.
    for word, space in string.gmatch(text, "([^%s]+)(%s*)") do
        local processedWord = word
        local lowerWord = string.lower(word)

        -- Check if word ends with a colon.
        local endsWithColon = string.match(word, ":$") ~= nil

        -- Check if this is a hyphenated word.
        if string.find(word, "-") then
            local parts = {}
            for part in string.gmatch(word, "[^-]+") do
                local lowerPart = string.lower(part)
                if isFirstWord or isAfterColon or not doNotCapitalizeMap[lowerPart] or #lowerPart >= 4 then
                    table.insert(parts, string.upper(string.sub(lowerPart, 1, 1)) .. string.sub(lowerPart, 2))
                else
                    table.insert(parts, lowerPart)
                end
            end
            processedWord = table.concat(parts, "-")
        else
            -- Normal word processing.
            if isFirstWord or isAfterColon or not doNotCapitalizeMap[lowerWord] or #lowerWord >= 4 then
                processedWord = string.upper(string.sub(lowerWord, 1, 1)) .. string.sub(lowerWord, 2)
            else
                processedWord = lowerWord
            end
        end

        -- Append the processed word and its trailing space to the result.
        result = result .. processedWord .. space

        -- Update state for next word.
        isFirstWord = false
        isAfterColon = endsWithColon
    end

    replaceSelectedText(result)
end

hs.hotkey.bind({"cmd", "alt"}, "T", toTitleCase)
