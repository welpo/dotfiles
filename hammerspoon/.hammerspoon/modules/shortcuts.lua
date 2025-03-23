-- App, folder, and media keyboard shortcuts

local quickOpen = {
    -- Folder shortcuts.
    {mods = {"cmd", "shift"}, key = "D", action = function() os.execute("open ~/Desktop") end},
    {mods = {"cmd", "shift"}, key = "J", action = function() os.execute("open ~/Downloads") end},

    -- App shortcuts.
    {mods = cmdCtrl, key = "N", app = "Anytype"},
    {mods = cmdCtrl, key = "D", app = "DataGrip"},
    {mods = cmdCtrl, key = "V", app = "Visual Studio Code"},
    {mods = cmdCtrl, key = "S", app = "Slack"},
    {mods = cmdCtrl, key = "B", app = "Firefox"},
    {mods = cmdCtrl, key = "R", app = "Reminders"},
    {mods = cmdCtrl, key = "M", app = "Mail"},
    {mods = {"cmd", "shift"}, key = "return", app = "Terminal"},
    {mods = cmdCtrl, key = "P", app = "System Preferences"},
}

-- Register shortcuts
for _, shortcut in ipairs(quickOpen) do
    if shortcut.app then
        hs.hotkey.bind(shortcut.mods, shortcut.key, function()
            hs.application.launchOrFocus(shortcut.app)
        end)
    else
        hs.hotkey.bind(shortcut.mods, shortcut.key, shortcut.action)
    end
end

-- Media control hotkeys
hs.hotkey.bind({"cmd"}, "F11", function()
    hs.eventtap.event.newSystemKeyEvent('PLAY', true):post()
    hs.eventtap.event.newSystemKeyEvent('PLAY', false):post()
end)

hs.hotkey.bind({"cmd"}, "F10", function()
    hs.eventtap.event.newSystemKeyEvent('PREVIOUS', true):post()
    hs.eventtap.event.newSystemKeyEvent('PREVIOUS', false):post()
end)

hs.hotkey.bind({"cmd"}, "F12", function()
    hs.eventtap.event.newSystemKeyEvent('NEXT', true):post()
    hs.eventtap.event.newSystemKeyEvent('NEXT', false):post()
end)
