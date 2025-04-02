-- Caffeine Module for Hammerspoon.
-- Provides control over display and system sleep behaviour.
--
-- Usage:
--   1. Save this file to ~/.hammerspoon/modules/caffeine.lua
--   2. In your init.lua:
--      require("modules/caffeine")
--      hs.hotkey.bind({"cmd", "ctrl", "shift"}, "C", cycleCaffeineModes)

-- Create menubar item.
local caffeine = hs.menubar.new()
local caffeineMode = "off"

-- Configure menu bar icon based on current caffeine mode.
local function setCaffeineDisplay(mode)
    if mode == "off" then
        caffeine:removeFromMenuBar()
    elseif mode == "screenSaverOnly" then
        if caffeine:isInMenuBar() == false then
            caffeine:returnToMenuBar()
        end
        caffeine:setTitle("🎬")
    elseif mode == "fullyAwake" then
        if caffeine:isInMenuBar() == false then
            caffeine:returnToMenuBar()
        end
        caffeine:setTitle("☕️")
    end
end

-- Set system sleep behaviour based on selected mode.
local function setCaffeineState(mode)
    if mode == "off" then
        hs.caffeinate.set("displayIdle", false)
        hs.caffeinate.set("systemIdle", false)
    elseif mode == "screenSaverOnly" then
        hs.caffeinate.set("displayIdle", false)
        hs.caffeinate.set("systemIdle", true)
    elseif mode == "fullyAwake" then
        hs.caffeinate.set("displayIdle", true)
        hs.caffeinate.set("systemIdle", true)
    end

    caffeineMode = mode
    setCaffeineDisplay(mode)
end

function cycleCaffeineModes()
    if caffeineMode == "off" then
        setCaffeineState("screenSaverOnly")
        hs.alert.show("Screen Saver Mode - Screen saver will run, but system won't sleep")
    elseif caffeineMode == "screenSaverOnly" then
        setCaffeineState("fullyAwake")
        hs.alert.show("Fully Awake Mode - Screen saver and sleep prevented")
    else
        setCaffeineState("off")
        hs.alert.show("Caffeine disabled")
    end
end

setCaffeineState("off")
