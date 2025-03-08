hs.window.animationDuration = 0
cmdCtrl = {"cmd", "ctrl"}

require("modules/caffeine")
require("modules/scrolling")
require("modules/shortcuts")
require("modules/titleCase")
require("modules/window")

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
