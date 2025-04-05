-- CSVPrettyPrint.lua
-- Module for pretty-printing CSV data.
-- Formats CSV data from clipboard and inserts at cursor position.

local M = {}

M.config = {
    style = CSV_PRETTY_STYLE or "simple",
    centered = CSV_CENTERED or false,
    removeQuotes = false
}

local styles = {
    simple = {
        headerSep = "—",
        colSep = "  ",
    },
    markdown = {
        headerSep = "-",
        colSep = " | ",
        left = "| ",
        right = " |",
    }
}

local function detectDelimiter(csvText)
    -- Count occurrences of common delimiters.
    local counts = {
        [','] = 0,
        [';'] = 0,
        ['\t'] = 0,
        ['|'] = 0
    }

    -- Only check the first few lines to determine delimiter.
    local lineCount = 0
    for line in csvText:gmatch("[^\r\n]+") do
        if lineCount < 5 and line:match("%S") then
            for delim, _ in pairs(counts) do
                for _ in line:gmatch(delim) do
                    counts[delim] = counts[delim] + 1
                end
            end
            lineCount = lineCount + 1
        end
    end

    -- Find the most common delimiter.
    local maxCount = 0
    local bestDelimiter = ','  -- Default to comma.

    for delim, count in pairs(counts) do
        if count > maxCount then
            maxCount = count
            bestDelimiter = delim
        end
    end

    return bestDelimiter
end

local function detectQuoteChar(csvText)
    -- Count occurrences of potential quote characters.
    local counts = {
        ['"'] = 0,
        ["'"] = 0
    }

    local lineCount = 0
    for line in csvText:gmatch("[^\r\n]+") do
        if lineCount < 5 and line:match("%S") then
            for quote, _ in pairs(counts) do
                for _ in line:gmatch(quote) do
                    counts[quote] = counts[quote] + 1
                end
            end
            lineCount = lineCount + 1
        end
    end

    local bestQuote = '"'  -- Default to double quote
    if counts["'"] > counts['"'] then
        bestQuote = "'"
    end

    return bestQuote
end

local function formatText(text, width, isLastColumn)
    -- Trim whitespace.
    text = text:gsub("^%s*(.-)%s*$", "%1")

    if M.config.removeQuotes and #text >= 2 then
        if (text:sub(1, 1) == '"' and text:sub(-1) == '"') or
           (text:sub(1, 1) == "'" and text:sub(-1) == "'") then
            text = text:sub(2, -2)
        end
    end

    -- Align text.
    local formattedText
    if M.config.centered then
        local padding = width - #text
        local padLeft = math.floor(padding / 2)
        formattedText = string.rep(" ", padLeft) .. text
        if not isLastColumn then
            local padRight = padding - padLeft
            formattedText = formattedText .. string.rep(" ", padRight)
        end
    else
        formattedText = text
        if not isLastColumn then
            formattedText = formattedText .. string.rep(" ", width - #text)
        end
    end
    return formattedText
end

local function parseCSVLine(line, delimiter, quoteChar)
    local fields = {}
    local currentField = ""
    local inQuotes = false
    local i = 1

    -- Empty line.
    if not line or line == "" then
        return fields
    end

    while i <= #line do
        local c = line:sub(i, i)

        if c == quoteChar then
            if inQuotes and i < #line and line:sub(i+1, i+1) == quoteChar then
                -- Escaped quote inside quoted field.
                currentField = currentField .. quoteChar
                i = i + 1 -- Skip the next quote.
            else
                inQuotes = not inQuotes
            end
        elseif c == delimiter and not inQuotes then
            -- End of field.
            currentField = currentField:gsub("^%s*(.-)%s*$", "%1")
            table.insert(fields, currentField)
            currentField = ""
        else
            -- Regular character.
            currentField = currentField .. c
        end

        i = i + 1
    end

    -- Add the last field (trimming whitespace).
    currentField = currentField:gsub("^%s*(.-)%s*$", "%1")
    table.insert(fields, currentField)

    return fields
end

function M.isValidCSV(text)
    if not text or type(text) ~= "string" or text == "" then
        return false
    end

    -- Auto-detect delimiter and quote character.
    local delimiter = detectDelimiter(text)
    local quoteChar = detectQuoteChar(text)

    -- Split into lines.
    local lines = {}
    for line in text:gmatch("[^\r\n]+") do
        if line:match("%S") then
            table.insert(lines, line)
        end
    end

    if #lines < 1 then
        return false
    end

    -- Just a header is technically valid, but it's probably a mistake.
    if #lines == 1 then
        return false
    end

    -- Count fields in header.
    local headerFields = parseCSVLine(lines[1], delimiter, quoteChar)

    -- Header has no fields.
    if #headerFields == 0 then
        return false
    end

    -- Verify data rows have a similar number of fields.
    local valid = false
    for i = 2, #lines do
        local rowFields = parseCSVLine(lines[i], delimiter, quoteChar)

        -- Allow some flexibility (e.g., trailing empty fields).
        if math.abs(#rowFields - #headerFields) <= 1 then
            valid = true
            break
        end
    end

    return valid
end

-- Pretty-print CSV data with aligned columns.
function M.prettyCsv(csvText, options)
    options = options or {}

    -- Apply any provided options
    local originalConfig = {}
    for k, v in pairs(options) do
        if M.config[k] ~= nil then
            originalConfig[k] = M.config[k]
            M.config[k] = v
        end
    end

    -- Use config style or default to "simple"
    local styleName = M.config.style or "simple"
    local style = styles[styleName] or styles["simple"]

    -- Auto-detect delimiter and quote character
    local delimiter = detectDelimiter(csvText)
    local quoteChar = detectQuoteChar(csvText)

    -- Validate input
    if not M.isValidCSV(csvText) then
        -- Restore original config
        for k, v in pairs(originalConfig) do
            M.config[k] = v
        end

        return false
    end

    -- Split into lines
    local lines = {}
    for line in csvText:gmatch("[^\r\n]+") do
        if line:match("%S") then -- Skip empty lines
            table.insert(lines, line)
        end
    end

    if #lines < 1 then
        -- Restore original config
        for k, v in pairs(originalConfig) do
            M.config[k] = v
        end

        return false
    end

    -- Parse headers and calculate column widths
    local headers = parseCSVLine(lines[1], delimiter, quoteChar)
    local widths = {}
    for i, h in ipairs(headers) do
        widths[i] = #h
    end

    -- Parse data rows and update column widths
    local data = {}
    for i = 2, #lines do
        local row = parseCSVLine(lines[i], delimiter, quoteChar)
        for col, val in ipairs(row) do
            if col <= #headers then  -- Only process fields that have a header
                widths[col] = math.max(widths[col] or 0, #val)
            end
        end
        table.insert(data, row)
    end

    -- Result table to collect formatted output
    local result = {}

    -- Handle simple style
    if styleName == "simple" then
        -- Print headers
        local out = ""
        for i, h in ipairs(headers) do
            out = out .. formatText(h, widths[i], i == #headers)
            if i < #headers then
                out = out .. style.colSep
            end
        end
        table.insert(result, out)

        -- Print separator
        out = ""
        for i, w in ipairs(widths) do
            out = out .. string.rep(style.headerSep, w)
            if i < #widths then
                out = out .. style.colSep
            end
        end
        table.insert(result, out)

        -- Print data
        for _, row in ipairs(data) do
            out = ""
            for i, val in ipairs(row) do
                if i <= #headers then  -- Only process fields that have a header
                    out = out .. formatText(val, widths[i], i == #headers)
                    if i < #headers then
                        out = out .. style.colSep
                    end
                end
            end
            table.insert(result, out)
        end
    -- Handle markdown style
    elseif styleName == "markdown" then
        -- Print headers
        local header = style.left or ""
        for i, h in ipairs(headers) do
            header = header .. formatText(h, widths[i], i == #headers)
            header = header .. (i < #headers and style.colSep or (style.right or ""))
        end
        table.insert(result, header)

        -- Print separator
        local sep = style.left or ""
        for i, w in ipairs(widths) do
            sep = sep .. string.rep(style.headerSep, w)
            sep = sep .. (i < #widths and style.colSep or (style.right or ""))
        end
        table.insert(result, sep)

        -- Print data
        for _, row in ipairs(data) do
            local line = style.left or ""
            for i, val in ipairs(row) do
                if i <= #headers then  -- Only process fields that have a header
                    line = line .. formatText(val, widths[i], i == #headers)
                    line = line .. (i < #headers and style.colSep or (style.right or ""))
                end
            end
            table.insert(result, line)
        end
    -- Handle pipe and underscore styles
    elseif styleName == "pipe" or styleName == "underscore" then
        -- Print headers
        local out = ""
        for i, h in ipairs(headers) do
            out = out .. formatText(h, widths[i], i == #headers)
            if i < #headers then
                out = out .. style.colSep
            end
        end
        table.insert(result, out)

        -- Print separator
        out = ""
        for i, w in ipairs(widths) do
            out = out .. string.rep(style.headerSep, w)
            if i < #widths then
                out = out .. style.colSep
            end
        end
        table.insert(result, out)

        -- Print data
        for _, row in ipairs(data) do
            out = ""
            for i, val in ipairs(row) do
                if i <= #headers then  -- Only process fields that have a header
                    out = out .. formatText(val, widths[i], i == #headers)
                    if i < #headers then
                        out = out .. style.colSep
                    end
                end
            end
            table.insert(result, out)
        end
    else
        -- Fallback to simple style if style not found
        M.config.style = "simple"
        result = M.prettyCsv(csvText)
    end

    -- Restore original config
    for k, v in pairs(originalConfig) do
        M.config[k] = v
    end

    return result
end

function M.formatAndInsertCSV(options)
    options = options or {}

    -- Always store original clipboard content
    local originalClipboard = hs.pasteboard.getContents()

    local csvText = originalClipboard
    if not csvText then
        hs.alert.show("No text in clipboard")
        return false
    end

    -- Validate if the clipboard content is CSV
    if not M.isValidCSV(csvText) then
        hs.alert.show("Clipboard doesn't contain valid CSV data")
        return false
    end

    -- Format the CSV
    local formattedLines = M.prettyCsv(csvText, options)
    if not formattedLines then
        hs.alert.show("Failed to format CSV data")
        return false
    end

    local formattedText = table.concat(formattedLines, "\n")
    hs.pasteboard.setContents(formattedText)
    hs.eventtap.keyStroke({"cmd"}, "v")
    hs.pasteboard.setContents(originalClipboard)

    return true
end

-- Format CSV data from clipboard and display in console
function M.formatClipboardCSV(options)
    options = options or {}

    local csvText = hs.pasteboard.getContents()
    if not csvText then
        return false
    end

    -- Split lines for counting
    local lines = {}
    for line in csvText:gmatch("[^\r\n]+") do
        if line:match("%S") then
            table.insert(lines, line)
        end
    end

    if #lines > 0 then
        local formattedLines = M.prettyCsv(csvText, options)
        if formattedLines then
            return true
        else
            return false
        end
    else
        return false
    end
end

function M.init(config)
    if config then
        for k, v in pairs(config) do
            M.config[k] = v
        end
    end

    return M
end

return M
