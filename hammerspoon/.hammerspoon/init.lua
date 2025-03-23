hs.window.animationDuration = 0
cmdCtrl = {"cmd", "ctrl"}

require("modules/caffeine")
require("modules/lowerCase")
require("modules/upperCase")
require("modules/openAdmin")
require("modules/scrolling")
require("modules/sentenceCase")
require("modules/shortcuts")
require("modules/titleCase")
require("modules/window")
-- MODE Report Finder
MODE_CACHE_FILE="/tmp/mode_reports_cache.json"
local modeReportFinder = require("modules/mode/reportFinder")
local modeCacheBuilder = require("modules/mode/cacheBuilder")

-- Auto-reload config on changes.
function reloadConfig(files)
    local doReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

local configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("hammerspoon config loaded")

-- Type clipboard.
function typeFromClipboard()
    local contents = hs.pasteboard.getContents()
    if contents then
        hs.eventtap.keyStrokes(contents)
    end
end

hs.hotkey.bind({"cmd", "alt"}, "V", typeFromClipboard)

hs.hotkey.bind({"cmd", "shift"}, "M", modeReportFinder.showFinder)
-- Refresh MODE cache every 2 hours.
local updateTimer = modeCacheBuilder.setupPeriodicUpdates(2)
-- Force cache rebuild.
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "M", function()
    modeCacheBuilder.updateCache()
end)
