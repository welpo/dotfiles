-- MODE Report Finder - Spotlight-like search for MODE reports.
-- Configuration options:
-- 1. Set MODE_CACHE_FILE in your init.lua before requiring this module.
-- 2. Optionally set MODE_SORT_FIELD and MODE_SORT_ORDER for custom sorting.

-- For fuzzy search.
local fuzzy = require("modules/utils/fuzzy")

-- Default configuration.
MODE_SORT_FIELD = MODE_SORT_FIELD or "lastSavedAt"  -- Options: "editedAt", "updatedAt", "createdAt", "lastSavedAt".
MODE_SORT_ORDER = MODE_SORT_ORDER or "desc"         -- Options: "desc", "asc".

-- Cache setup.
local reportCache = nil
local lastCacheTime = 0
local CACHE_LIFETIME = 3600 -- 1 hour cache lifetime.

local function loadCacheFromDisk()
    local startTime = hs.timer.secondsSinceEpoch()

    if not MODE_CACHE_FILE then
        print("No MODE_CACHE_FILE configured.")
        return nil
    end

    local cacheFile = io.open(MODE_CACHE_FILE, "r")
    if not cacheFile then
        print("No cache file found.")
        return nil
    end

    print("Reading cache file...")
    local cacheJson = cacheFile:read("*all")
    cacheFile:close()

    local readTime = hs.timer.secondsSinceEpoch() - startTime
    print(string.format("Read cache file in %.2f seconds", readTime))

    print("Parsing JSON...")
    local parseStart = hs.timer.secondsSinceEpoch()
    local success, cache = pcall(function()
        return hs.json.decode(cacheJson)
    end)

    local parseTime = hs.timer.secondsSinceEpoch() - parseStart
    print(string.format("Parsed JSON in %.2f seconds", parseTime))

    if success and cache and cache.timestamp and cache.reports then
        print("Loaded cache from disk with " .. #cache.reports .. " reports.")
        local totalTime = hs.timer.secondsSinceEpoch() - startTime
        print(string.format("Total cache load time: %.2f seconds", totalTime))
        return cache
    else
        print("Failed to parse cache file.")
        return nil
    end
end

local function getReportsFromCache()
    local currentTime = os.time()
    if reportCache and (currentTime - lastCacheTime < CACHE_LIFETIME) then
        print("Using in-memory cache (" .. #reportCache .. " reports).")
        return reportCache
    end
    local diskCache = loadCacheFromDisk()
    if diskCache then
        reportCache = diskCache.reports
        lastCacheTime = diskCache.timestamp
        print("Loaded " .. #reportCache .. " reports from disk cache.")
        return reportCache
    end

    return nil
end

-- Initialise chooser.
local chooser = hs.chooser.new(function(selection)
    if selection then
        local reportUrl = selection.reportUrl
        hs.urlevent.openURL(reportUrl)
    end
end)

-- Configure the chooser appearance.
chooser:placeholderText("Search MODE Reports…")
chooser:searchSubText(true)
chooser:width(600)

local function sortReportsByField(choices, field, order)
    table.sort(choices, function(a, b)
        -- Handle nil values.
        if not a[field] and not b[field] then return false end
        if not a[field] then return order == "asc" end
        if not b[field] then return order == "desc" end
        -- Compare dates (they're ISO format strings, which sort correctly).
        if order == "desc" then
            return a[field] > b[field]
        else
            return a[field] < b[field]
        end
    end)
    return choices
end

function showModeFinder()
    local reports = getReportsFromCache()
    if not reports or #reports == 0 then
        hs.alert.show("No cached MODE reports found. Please run the cache update.")
        return
    end

    print("Found " .. #reports .. " reports in cache.")
    local choices = {}

    for i, report in ipairs(reports) do
        local name = report.name or "Untitled report"
        local spaceName = report.spaceName or "Unknown space"
        local createdBy = report.creator or "Unknown"
        local reportUrl = report.reportUrl or ""
        local updatedAt = report.updatedAt
        local editedAt = report.editedAt
        local createdAt = report.createdAt
        local lastSavedAt = report.lastSavedAt

        local choiceImage = hs.image.imageFromPath(os.getenv("HOME") .. "/.hammerspoon/modules/mode/mode-icon.svg") or hs.image.imageFromName("NSApplicationIcon")

        if report.localPreviewImage then
            local cachedImage = hs.image.imageFromPath(report.localPreviewImage)
            if cachedImage then
                choiceImage = cachedImage
            else
                print("Failed to load cached image for report " .. i .. ": " .. report.localPreviewImage)
            end
        end

        table.insert(choices, {
            text = name,
            subText = spaceName .. " • " .. createdBy,
            reportUrl = reportUrl,
            image = choiceImage,
            name = name,
            space = spaceName,
            searchText = spaceName .. " " .. name .. " " .. createdBy,
            updatedAt = updatedAt,
            editedAt = editedAt,
            createdAt = createdAt,
            lastSavedAt = lastSavedAt
        })
    end

    sortReportsByField(choices, MODE_SORT_FIELD, MODE_SORT_ORDER)

    chooser:queryChangedCallback(function(query)
        if query == "" then
            chooser:choices(choices)
            return
        end

        -- Apply fuzzy matching to filter and sort results.
        local filteredChoices = {}
        for _, choice in ipairs(choices) do
            if fuzzy.match(query, choice.searchText) then
                local score = fuzzy.score(query, choice.searchText)
                local scoredChoice = hs.fnutils.copy(choice)
                scoredChoice.score = score
                table.insert(filteredChoices, scoredChoice)
            end
        end

        table.sort(filteredChoices, function(a, b)
            return (a.score or 0) > (b.score or 0)
        end)

        chooser:choices(filteredChoices)
    end)

    chooser:choices(choices)
    chooser:show()
end
