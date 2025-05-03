hs.window.animationDuration = 0
cmdCtrl = {"cmd", "ctrl"}
local hostname = hs.host.localizedName():lower()
local isWorkComputer = hostname:find("oo") ~= nil

require("modules/shortcuts")  -- keyboard shortcuts.
require("modules/window")
require("modules/caffeine")
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "C", cycleCaffeineModes)
require("modules/lowerCase")
hs.hotkey.bind({"cmd", "alt"}, "L", toLowerCase)
require("modules/scrolling")
require("modules/sentenceCase")
hs.hotkey.bind({"cmd", "alt"}, "S", toSentenceCase)
require("modules/titleCase")
hs.hotkey.bind({"cmd", "alt"}, "T", toTitleCase)
require("modules/upperCase")
hs.hotkey.bind({"cmd", "alt"}, "U", toUpperCase)
require("modules/typeFromClipboard")
hs.hotkey.bind({"cmd", "alt"}, "V", typeFromClipboard)

CSV_CENTERED = false
local csvPretty = require("modules/CSVPrettyPrint")
hs.hotkey.bind({"cmd", "alt"}, "C", function()
    csvPretty.formatAndInsertCSV({style = "simple"})
end)
hs.hotkey.bind({"cmd", "alt"}, "M", function()
    csvPretty.formatAndInsertCSV({style = "markdown"})
end)


-- Auto-reload config on changes (doesn't always work 😞).
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


if isWorkComputer then
    require("modules/identifyFactCSV")
    hs.hotkey.bind(cmdCtrl, "I", identifyFact)
    require("modules/formatEpoch")
    hs.hotkey.bind({"cmd", "alt"}, "E", displayDateFromSelection)
    require("modules/openAdmin")
    hs.hotkey.bind({"cmd", "ctrl"}, "A", openAdminWithId)
    -- MODE Report Finder.
    MODE_CACHE_FILE=os.getenv("HOME") .. "/.mode_reports_cache.json"
    require("modules/mode/reportFinder")
    require("modules/mode/cacheBuilder")
    hs.hotkey.bind({"cmd", "shift"}, "M", showModeFinder)
    -- Force cache refresh.
    hs.hotkey.bind({"cmd", "shift", "ctrl"}, "M", updateModeCache)
    print("Loaded work-specific modules")
end
