-- Identify facts from a CSV database using selection or clipboard.
local textUtils = require("modules/utils/textUtils")

-- Global configuration variable CSV_PATH: path to CSV file
-- Optional: Set SECRETS_PATH to customize secrets file location

local cache = nil

-- Load secrets and CSV data.
local function loadData()
    if cache then return cache end

    -- First check for direct configuration.
    local csvPath = CSV_PATH

    -- Fall back to secrets file if direct path not set.
    if not csvPath then
        local secretsPath = SECRETS_PATH or (os.getenv("HOME") .. "/.secrets.lua")
        local env = {}
        local chunk, err = loadfile(secretsPath, "t", env)
        if chunk then
            chunk()
            csvPath = env.facts_csv_path
            if not csvPath then
                hs.alert.show("facts_csv_path not found in secrets file.")
            end
        else
            hs.alert.show("Error loading secrets: " .. (err or "unknown error"))
        end
    end

    if not csvPath then
        hs.alert.show("CSV path not configured. Set CSV_PATH in init.lua.")
        return nil
    end

    -- Parse CSV.
    local data = {byId = {}, byTypeId = {}}
    local f = io.open(csvPath, "r")
    if not f then hs.alert.show("CSV file not found: " .. csvPath); return nil end

    f:read("*line") -- Skip header.
    for l in f:lines() do
        local tid, id, _, t, _, n, d = l:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),(.*)")
        if id then
            n, d = (n or ""):gsub("%s+$", ""), (d or ""):gsub("%s+$", "")
            data.byId[id] = {name = n, desc = d, type = t}
            data.byTypeId[tid] = {type = t}
        end
    end
    f:close()
    cache = data
    return data
end

-- Identify fact or fact type.
function identifyFact()
    local data = loadData()
    if not data then return end

    local txt = (textUtils.getTextSelection() or hs.pasteboard.getContents() or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if txt == "" or not txt:match("^%d+$") then
        hs.alert.show(txt == "" and "No selection found" or "Not a numeric ID: " .. txt)
        return
    end

    if #txt <= 2 then
        local info = data.byTypeId[txt]
        hs.alert.show(info and ("Type " .. txt .. ": " .. info.type) or "Unknown type: " .. txt)
    else
        local info = data.byId[txt]
        if info then
            local same = info.name:lower():gsub("%s+", "") == info.desc:lower():gsub("%s+", "")
            hs.alert.show("Fact " .. txt .. ": " .. (same and info.desc or (info.name .. " - " .. info.desc)))
        else
            hs.alert.show("Unknown fact: " .. txt)
        end
    end
end
