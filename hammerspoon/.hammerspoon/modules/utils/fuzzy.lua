-- Fuzzy text matching module for Hammerspoon.
-- Provides VSCode-like fuzzy file matching functionality (Cmd + P).
local fuzzy = {}

fuzzy.config = {
    caseSensitive = false,       -- Set to true to make matching case-sensitive.
    normalizeAccents = true,     -- Set to false to treat accented characters as distinct.
    minScore = 0.1,              -- Minimum score threshold to consider a match valid.
    exactMatchBonus = 10,        -- Score bonus for exact substring matches.
    consecutiveBonus = 1,        -- Score bonus for consecutive character matches.
    partialMatchWeight = 5       -- Weight for partial character-by-character matches.
}

-- Normalizes text by converting accented characters to their non-accented equivalents.
-- Standard Lua string functions don't handle UTF-8 properly (because they're multiple bytes).
local function normalizeText(str)
    if not str then return "" end
    -- Return original string if accent normalization is disabled.
    if not fuzzy.config.normalizeAccents then
        return str
    end
    local replacements = {
        ["á"] = "a", ["à"] = "a", ["â"] = "a", ["ã"] = "a", ["ä"] = "a", ["å"] = "a",
        ["é"] = "e", ["è"] = "e", ["ê"] = "e", ["ë"] = "e",
        ["í"] = "i", ["ì"] = "i", ["î"] = "i", ["ï"] = "i",
        ["ó"] = "o", ["ò"] = "o", ["ô"] = "o", ["õ"] = "o", ["ö"] = "o", ["ø"] = "o",
        ["ú"] = "u", ["ù"] = "u", ["û"] = "u", ["ü"] = "u",
        ["ý"] = "y", ["ÿ"] = "y",
        ["ç"] = "c", ["ñ"] = "n",
        ["Á"] = "A", ["À"] = "A", ["Â"] = "A", ["Ã"] = "A", ["Ä"] = "A", ["Å"] = "A",
        ["É"] = "E", ["È"] = "E", ["Ê"] = "E", ["Ë"] = "E",
        ["Í"] = "I", ["Ì"] = "I", ["Î"] = "I", ["Ï"] = "I",
        ["Ó"] = "O", ["Ò"] = "O", ["Ô"] = "O", ["Õ"] = "O", ["Ö"] = "O", ["Ø"] = "O",
        ["Ú"] = "U", ["Ù"] = "U", ["Û"] = "U", ["Ü"] = "U",
        ["Ý"] = "Y", ["Ÿ"] = "Y",
        ["Ç"] = "C", ["Ñ"] = "N"
    }
    local result = str
    for accented, plain in pairs(replacements) do
        result = result:gsub(accented, plain)
    end
    return result
end

-- Prepares string for matching by normalizing and handling case sensitivity.
local function prepareString(str)
    if not str then return "" end
    local result = normalizeText(str)
    if not fuzzy.config.caseSensitive then
        result = string.lower(result)
    end
    return result
end

-- Splits a pattern into individual search terms.
local function splitTerms(pattern)
    local terms = {}
    for term in pattern:gmatch("%S+") do
        table.insert(terms, term)
    end
    return terms
end

-- Determines if a pattern matches a string using fuzzy matching algorithm.
-- Returns true if all terms in pattern match in sequence within str.
function fuzzy.match(pattern, str)
    -- Input validation.
    if type(pattern) ~= "string" or type(str) ~= "string" then
        return false
    end
    -- Prepare strings for matching.
    pattern = prepareString(pattern)
    str = prepareString(str)
    -- If the pattern is empty, it matches everything.
    if pattern == "" then return true end
    -- Split the pattern into individual terms.
    local terms = splitTerms(pattern)
    -- Each term must have all characters match in sequence.
    for _, term in ipairs(terms) do
        local pos = 1
        -- Check if all characters in the term appear in order.
        for i = 1, #term do
            local c = term:sub(i, i)
            pos = str:find(c, pos, true)
            -- If character not found, this term doesn't match.
            if not pos then
                return false
            end
            -- Move to next position for next character.
            pos = pos + 1
        end
    end
    -- All terms matched successfully.
    return true
end

-- Calculates a score between 0 and 1 for how well pattern matches str.
-- Higher scores indicate better matches.
function fuzzy.score(pattern, str)
    -- Input validation.
    if type(pattern) ~= "string" or type(str) ~= "string" then
        return 0
    end
    -- Prepare strings for scoring.
    pattern = prepareString(pattern)
    str = prepareString(str)
    -- Perfect match gets perfect score.
    if pattern == str then return 1.0 end
    -- Empty pattern gets zero score.
    if pattern == "" then return 0 end
    -- Split into terms.
    local terms = splitTerms(pattern)
    local score = 0
    local maxScore = #terms * fuzzy.config.exactMatchBonus
    for _, term in ipairs(terms) do
        -- Exact substring match is worth more.
        if str:find(term, 1, true) then
            score = score + fuzzy.config.exactMatchBonus
        else
            -- Character-by-character matching.
            local lastPos = 0
            local consecutiveMatches = 0
            local charScore = 0
            for i = 1, #term do
                local c = term:sub(i, i)
                local pos = str:find(c, lastPos + 1, true)
                if pos then
                    charScore = charScore + 1
                    -- Bonus for consecutive matches.
                    if pos == lastPos + 1 then
                        consecutiveMatches = consecutiveMatches + 1
                        charScore = charScore + (consecutiveMatches * fuzzy.config.consecutiveBonus)
                    else
                        consecutiveMatches = 0
                    end
                    lastPos = pos
                end
            end
            -- Calculate partial match score.
            score = score + (charScore / #term) * fuzzy.config.partialMatchWeight
        end
    end
    -- Normalize score to range 0-1.
    local finalScore = score / maxScore
    if finalScore < fuzzy.config.minScore then
        return 0
    end
    return finalScore
end

return fuzzy
