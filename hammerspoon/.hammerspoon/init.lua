-- Global settings.
hs.window.animationDuration = 0
local cmdCtrl = {"cmd", "ctrl"}
local COMFORTABLE_WIDTH_RATIO = 0.65  -- 65% of screen width.
local COMFORTABLE_HEIGHT_RATIO = 0.80  -- 80% of screen height.

-- Initialise window switcher.
local switcher = hs.window.switcher.new(
    hs.window.filter.new()
        :setCurrentSpace(true)
        :setDefaultFilter{}
)

-- Window switcher UI config.
switcher.ui.showTitles = true
switcher.ui.showThumbnails = false
switcher.ui.showSelectedThumbnail = false
switcher.ui.textSize = 10
switcher.ui.fontName = '.AppleSystemUIFont'
switcher.ui.backgroundColor = {0.2, 0.2, 0.2, 0.55}
switcher.ui.titleBackgroundColor = {0, 0, 0, 0}
switcher.ui.titleColor = {1, 1, 1, 1}
switcher.ui.highlightColor = {0.4, 0.4, 0.4, 0.9}
switcher.ui.maxTitleWidth = 400
switcher.ui.titleHeight = 17

-- Window management.
function centerWindowInScreen()
    local win = hs.window.focusedWindow()
    if not win then return end

    local screen = win:screen()
    local screenFrame = screen:frame()
    local winFrame = win:frame()

    winFrame.x = screenFrame.x + (screenFrame.w - winFrame.w) / 2
    winFrame.y = screenFrame.y + (screenFrame.h - winFrame.h) / 2

    win:setFrame(winFrame)
end

function moveWindowToNextScreen()
    local win = hs.window.focusedWindow()
    if not win then return end

    local screen = win:screen()
    local nextScreen = screen:next()

    local currentFrame = win:frame()
    local nextScreenFrame = nextScreen:frame()

    local newFrame = {
        w = currentFrame.w,
        h = currentFrame.h,
        x = nextScreenFrame.x + (nextScreenFrame.w - currentFrame.w) / 2,
        y = nextScreenFrame.y + (nextScreenFrame.h - currentFrame.h) / 2
    }

    win:setFrame(newFrame)
end

function comfortableMaximize()
    local win = hs.window.focusedWindow()
    if not win then return end

    local screen = win:screen()
    local screenFrame = screen:frame()

    local newFrame = {
        w = screenFrame.w * COMFORTABLE_WIDTH_RATIO,
        h = screenFrame.h * COMFORTABLE_HEIGHT_RATIO,
    }

    newFrame.x = screenFrame.x + (screenFrame.w - newFrame.w) / 2
    newFrame.y = screenFrame.y + (screenFrame.h - newFrame.h) / 2

    win:setFrame(newFrame)
end

function openTerminal()
    hs.application.launchOrFocus("Terminal")
end

function moveWindowToHalf(direction)
    local win = hs.window.focusedWindow()
    if not win then return end

    local screen = win:screen()
    local screenFrame = screen:frame()
    local newFrame = {
        x = screenFrame.x,
        y = screenFrame.y,
        w = screenFrame.w,
        h = screenFrame.h
    }

    if direction == "left" then
        newFrame.w = screenFrame.w / 2
    elseif direction == "right" then
        newFrame.x = screenFrame.x + (screenFrame.w / 2)
        newFrame.w = screenFrame.w / 2
    elseif direction == "up" then
        newFrame.h = screenFrame.h / 2
    elseif direction == "down" then
        newFrame.y = screenFrame.y + (screenFrame.h / 2)
        newFrame.h = screenFrame.h / 2
    end

    win:setFrame(newFrame)
end

-- Keyboard shortcuts.
-- Window management.
hs.hotkey.bind(cmdCtrl, "C", centerWindowInScreen)
hs.hotkey.bind(cmdCtrl, "W", moveWindowToNextScreen)
hs.hotkey.bind(cmdCtrl, "left", function() moveWindowToHalf("left") end)
hs.hotkey.bind(cmdCtrl, "right", function() moveWindowToHalf("right") end)
hs.hotkey.bind(cmdCtrl, "up", function() moveWindowToHalf("up") end)
hs.hotkey.bind(cmdCtrl, "down", function() moveWindowToHalf("down") end)
hs.hotkey.bind(cmdCtrl, "E", comfortableMaximize)
hs.hotkey.bind("alt", "tab", function() switcher:next() end)
hs.hotkey.bind({"alt", "shift"}, "tab", function() switcher:previous() end)
-- Open stuff.
hs.hotkey.bind({"cmd", "shift"}, "return", openTerminal)
hs.hotkey.bind({"cmd", "shift"}, "D", function()
    os.execute("open ~/Desktop")
end)
hs.hotkey.bind({"cmd", "shift"}, "J", function()
    os.execute("open ~/Downloads")
end)
-- Media controls.
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
