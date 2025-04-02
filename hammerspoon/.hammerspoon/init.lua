hs.window.animationDuration = 0
cmdCtrl = {"cmd", "ctrl"}
local hostname = hs.host.localizedName():lower()
local isWorkComputer = hostname:find("oo") ~= nil

require("modules/caffeine")
require("modules/lowerCase")
require("modules/upperCase")
require("modules/scrolling")
require("modules/sentenceCase")
require("modules/shortcuts")  -- keyboard shortcuts.
require("modules/titleCase")
require("modules/window")


hs.hotkey.bind({"cmd", "ctrl", "shift"}, "C", cycleCaffeineModes)
hs.hotkey.bind({"cmd", "alt"}, "L", toLowerCase)
hs.hotkey.bind({"cmd", "alt"}, "S", toSentenceCase)
hs.hotkey.bind({"cmd", "alt"}, "T", toTitleCase)
hs.hotkey.bind({"cmd", "alt"}, "U", toUpperCase)

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

if isWorkComputer then
    require("modules/identifyFactCSV")
    hs.hotkey.bind(cmdCtrl, "I", identifyFact)
    require("modules/formatEpoch")
    hs.hotkey.bind({"cmd", "ctrl"}, "E", displayDateFromSelection)
    require("modules/openAdmin")
    hs.hotkey.bind({"cmd", "ctrl"}, "A", openAdminWithId)
    -- MODE Report Finder.
    MODE_CACHE_FILE="~/.mode_reports_cache.json"
    require("modules/mode/reportFinder")
    require("modules/mode/cacheBuilder")
    hs.hotkey.bind({"cmd", "shift"}, "M", showModeFinder)
    -- Force cache refresh.
    hs.hotkey.bind({"cmd", "shift", "ctrl"}, "M", updateModeCache)
    print("Loaded work-specific modules")
end
