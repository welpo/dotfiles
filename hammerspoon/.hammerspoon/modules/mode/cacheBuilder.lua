-- MODE Report Cache Builder - Handles API interactions and cache building.
-- Configure before requiring:
-- 1. Set MODE_SECRETS directly in init.lua before requiring, or
-- 2. Set SECRETS_PATH to customise secrets file location, or
-- 3. Default: Uses ~/.secrets.lua with MODE credentials

-- Configuration constants - can be overridden in init.lua before requiring.
IMAGE_CACHE_DIR = IMAGE_CACHE_DIR or "/tmp/hammerspoon_mode"
MODE_CACHE_FILE = MODE_CACHE_FILE or (os.getenv("HOME") .. "/.hammerspoon/mode_cache.json")
WAIT_SECONDS_BETWEEN_REQUESTS = WAIT_SECONDS_BETWEEN_REQUESTS or 1.0

-- Load secrets.
local secrets = {}
if not MODE_SECRETS then
    local secretsPath = SECRETS_PATH or (os.getenv("HOME") .. "/.secrets.lua")
    local chunk, err = loadfile(secretsPath, "t", secrets)
    if chunk then
        chunk()
        MODE_SECRETS = {
            mode_workspace = secrets.mode_workspace,
            mode_api_token = secrets.mode_api_token,
            mode_api_secret = secrets.mode_api_secret
        }
    else
        hs.alert.show("Error loading secrets: " .. (err or "unknown error"))
    end
end

local modeUrl = 'https://app.mode.com'

-- Rate limiting config.
local requestQueue = {}
local isProcessingQueue = false

-- Private functions.
local function processRequestQueue()
    if isProcessingQueue or #requestQueue == 0 then return end
    isProcessingQueue = true
    local nextRequest = table.remove(requestQueue, 1)
    print("Processing request: " .. nextRequest.url)
    hs.http.asyncGet(nextRequest.url, nextRequest.headers, function(status, body, headers)
        nextRequest.callback(status, body, headers)
        -- Schedule the next request.
        hs.timer.doAfter(WAIT_SECONDS_BETWEEN_REQUESTS, function()
            isProcessingQueue = false
            processRequestQueue()
        end)
    end)
end

local function queueApiRequest(endpoint, callback)
    if not MODE_SECRETS or not MODE_SECRETS.mode_workspace then
        hs.alert.show("MODE credentials not configured.")
        callback(nil)
        return
    end

    local workspace = MODE_SECRETS.mode_workspace
    local url = modeUrl .. "/api/" .. workspace .. endpoint
    -- Authentication.
    local auth = MODE_SECRETS.mode_api_token .. ":" .. MODE_SECRETS.mode_api_secret
    local authBase64 = hs.base64.encode(auth)
    local headers = {["Authorization"] = "Basic " .. authBase64}
    print("Queueing request: " .. url)
    -- Add request to the queue.
    table.insert(requestQueue, {
        url = url,
        headers = headers,
        callback = function(status, body, headers)
            if status >= 200 and status < 300 then
                -- Parse JSON response.
                local success, data = pcall(function()
                    return hs.json.decode(body)
                end)

                if success and data then
                    print("Successful response from: " .. url)
                    callback(data)
                else
                    print("Error parsing JSON from: " .. url)
                    print(body)
                    callback(nil)
                end
            else
                print("API Error (" .. status .. ") from: " .. url)
                print(body)
                if status == 429 then
                    print("Rate limit exceeded! Backing off for 30 seconds.")
                    requestQueue = {}
                    hs.timer.doAfter(30, function()
                        isProcessingQueue = false
                        callback(nil)
                    end)
                    return
                end
                callback(nil)
            end
        end
    })
    processRequestQueue()
end

local function fetchUserDisplayName(username, callback)
    if not MODE_SECRETS then
        callback(username)
        return
    end

    local url = modeUrl .. "/api/" .. username
    -- Authenticate.
    local auth = MODE_SECRETS.mode_api_token .. ":" .. MODE_SECRETS.mode_api_secret
    local authBase64 = hs.base64.encode(auth)
    local headers = {["Authorization"] = "Basic " .. authBase64}
    print("Fetching user details for: " .. username)
    -- API request.
    hs.http.asyncGet(url, headers, function(status, body, headers)
        if status >= 200 and status < 300 then
            -- Parse JSON response.
            local success, data = pcall(function()
                return hs.json.decode(body)
            end)
            if success and data and data.name then
                print("Found display name for " .. username .. ": " .. data.name)
                callback(data.name)
            else
                print("Error parsing user data for: " .. username)
                callback(username) -- Fallback to username.
            end
        else
            print("API Error (" .. status .. ") fetching user: " .. username)
            callback(username) -- Fallback to username.
        end
    end)
end

local function extractUsernameFromCreatorHref(href)
    if not href then return "Unknown" end
    local username = href:match("/api/([^/]+)")
    return username or "Unknown"
end

local function fetchSpaces(callback)
    queueApiRequest("/spaces?filter=all", function(data)
        if data and data._embedded and data._embedded.spaces then
            -- Filter out Personal + Archive spaces.
            local filteredSpaces = {}
            for _, space in ipairs(data._embedded.spaces) do
                if space.name ~= "Personal" and not space.name:match("%[ARCHIVE%]") then
                    table.insert(filteredSpaces, space)
                end
            end
            callback(filteredSpaces)
        else
            print("Error: Could not fetch spaces.")
            callback({})
        end
    end)
end

local function ensureImageCacheDir()
    local success, err = hs.fs.mkdir(IMAGE_CACHE_DIR)
    if not success and not string.find(err or "", "exists") then
        print("Error creating image cache directory: " .. (err or "unknown error"))
        return false
    end
    return true
end

local function downloadImage(url, token, callback)
    if not url then
        print("No URL provided for report: " .. token)
        callback(nil)
        return
    end
    -- Remove query parameters from URL for filename.
    local baseUrl = url:gsub("%?.*$", "")
    local ext = baseUrl:match("%.([^%.]+)$") or "jpg"
    local imagePath = IMAGE_CACHE_DIR .. "/" .. token .. "." .. ext
    if hs.fs.attributes(imagePath) then
        print("Image already cached: " .. imagePath)
        callback(imagePath)
        return
    end
    print("Downloading image: " .. url .. " for report: " .. token)
    -- Add to request queue.
    table.insert(requestQueue, {
        url = url,
        headers = {},
        callback = function(status, body, headers)
            if status >= 200 and status < 300 and body and #body > 0 then
                -- Save to disk.
                local success, err = pcall(function()
                    local file = io.open(imagePath, "wb")
                    if file then
                        file:write(body)
                        file:close()
                        return true
                    else
                        return false, "Could not open file for writing."
                    end
                end)
                if success then
                    local fileAttrs = hs.fs.attributes(imagePath)
                    if fileAttrs and fileAttrs.size > 0 then
                        print("Successfully saved image to: " .. imagePath .. " (Size: " .. fileAttrs.size .. " bytes)")
                        callback(imagePath)
                    else
                        print("File appears to be missing or empty after save: " .. imagePath)
                        print("File attributes: " .. (fileAttrs and hs.inspect(fileAttrs) or "nil"))
                        callback(nil)
                    end
                else
                    print("Failed to save image: " .. imagePath)
                    print("Error: " .. (err or "unknown error"))
                    callback(nil)
                end
            else
                print("Failed to download image: " .. url)
                print("Status: " .. status)
                callback(nil)
            end
        end
    })
    processRequestQueue()
end

local function fetchReportsFromSpace(space, page, allReports, callback)
    local pageParam = page > 1 and ("?page=" .. page) or ""
    queueApiRequest("/spaces/" .. space.token .. "/reports" .. pageParam, function(data)
        if data and data._embedded and data._embedded.reports then
            local reports = data._embedded.reports
            print("Found " .. #reports .. " reports in space '" .. space.name .. "' (page " .. page .. ")")
            local pendingImageDownloads = 0
            local function processReport(index)
                if index > #reports then
                    -- All reports processed, check if we need to fetch more pages.
                    if #reports == 30 then
                        fetchReportsFromSpace(space, page + 1, allReports, callback)
                    else
                        if pendingImageDownloads == 0 then
                            callback(allReports)
                        end
                    end
                    return
                end

                local report = reports[index]

                -- MODE returns a lot of data. If we save all of it, loading the cache is super slow.
                local trimmedReport = {
                    name = report.name,
                    spaceName = space.name,
                    token = report.token,
                    creator = extractUsernameFromCreatorHref(
                        report._links and report._links.creator and report._links.creator.href
                    ),
                    reportUrl = report._links and report._links.web and report._links.web.href or "",
                    -- Dates for sorting.
                    createdAt = report.created_at,
                    updatedAt = report.updated_at,  -- refers to a refresh/running queries.
                    editedAt = report.edited_at,
                    lastSavedAt = report.last_saved_at,
                }

                if report.web_preview_image then
                    pendingImageDownloads = pendingImageDownloads + 1
                    downloadImage(report.web_preview_image, report.token, function(imagePath)
                        pendingImageDownloads = pendingImageDownloads - 1
                        trimmedReport.localPreviewImage = imagePath
                        processReport(index + 1)
                    end)
                else
                    processReport(index + 1)
                end
                table.insert(allReports, trimmedReport)
            end
            processReport(1)
        else
            print("Error fetching reports for space: " .. space.name)
            callback(allReports)
        end
    end)
end

local function saveCacheToDisk(reports)
    local cache = {
        timestamp = os.time(),
        reports = reports
    }
    local success, cacheJson = pcall(function()
        return hs.json.encode(cache)
    end)
    if success then
        local cacheFile = io.open(MODE_CACHE_FILE, "w")
        if cacheFile then
            cacheFile:write(cacheJson)
            cacheFile:close()
            print("Saved cache to disk with " .. #reports .. " reports (optimised size).")
        else
            print("Failed to open cache file for writing.")
        end
    else
        print("Failed to encode cache to JSON.")
    end
end

-- Global functions.
function updateModeCache()
    -- Show loading indicator.
    hs.alert.show("Updating MODE reports cache…")
    if not ensureImageCacheDir() then
        hs.alert.show("Failed to create image cache directory.")
        return
    end

    fetchSpaces(function(spaces)
        if #spaces == 0 then
            print("No spaces found in workspace.")
            hs.alert.show("No spaces found in workspace.")
            return
        end
        local allReports = {}
        local spacesRemaining = #spaces
        local usernameCache = {} -- Cache usernames to display names.
        local pendingUserFetches = 0 -- Track pending user API calls.

        local function checkAllDone()
            if spacesRemaining == 0 and pendingUserFetches == 0 then
                -- Replace usernames with display names.
                for _, report in ipairs(allReports) do
                    local username = report.creator
                    if usernameCache[username] then
                        report.creator = usernameCache[username]
                    end
                end
                print("Completed fetching all reports (" .. #allReports .. " total) with display names.")
                saveCacheToDisk(allReports)
                hs.alert.show("MODE reports cache updated with " .. #allReports .. " reports.")
            end
        end

        -- Process one space at a time to reduce API load.
        local function processNextSpace(index)
            if index > #spaces then return end
            local space = spaces[index]
            print("Processing space " .. index .. "/" .. #spaces .. ": " .. space.name)
            fetchReportsFromSpace(space, 1, {}, function(spaceReports)
                for _, report in ipairs(spaceReports) do
                    local username = report.creator
                    if username ~= "Unknown" and not usernameCache[username] then
                        usernameCache[username] = username
                        pendingUserFetches = pendingUserFetches + 1
                        fetchUserDisplayName(username, function(displayName)
                            pendingUserFetches = pendingUserFetches - 1
                            usernameCache[username] = displayName
                            checkAllDone()
                        end)
                    end
                    table.insert(allReports, report)
                end
                spacesRemaining = spacesRemaining - 1
                if index < #spaces then
                    processNextSpace(index + 1)
                else
                    checkAllDone()
                end
            end)
        end
        processNextSpace(1)
    end)
end

function setupModePeriodicUpdates(intervalHours)
    intervalHours = intervalHours or 12
    local intervalSeconds = intervalHours * 60 * 60
    local timer = hs.timer.new(intervalSeconds, function()
        updateModeCache()
    end)
    timer:start()
    print("Set up automatic cache updates every " .. intervalHours .. " hours.")
    return timer
end

-- Auto-initialise on require.
local autoUpdateTimer = setupModePeriodicUpdates(2)
