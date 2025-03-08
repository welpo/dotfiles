-- Caffeinate functionality
local caffeine = hs.menubar.new()
local caffeineMode = "off"

function setCaffeineDisplay(mode)
    if mode == "off" then
        -- Hide icon completely when inactive
        caffeine:removeFromMenuBar()
    elseif mode == "screenSaverOnly" then
        -- Show screen saver icon when in screen saver mode
        if caffeine:isInMenuBar() == false then
            caffeine:returnToMenuBar()
        end
        caffeine:setTitle("🎬")
    elseif mode == "fullyAwake" then
        -- Show coffee cup icon when fully awake
        if caffeine:isInMenuBar() == false then
            caffeine:returnToMenuBar()
        end
        caffeine:setTitle("☕️")
    end
end

function setCaffeineState(mode)
    if mode == "off" then
        -- Disable all caffeinate modes
        hs.caffeinate.set("displayIdle", false)
        hs.caffeinate.set("systemIdle", false)
    elseif mode == "screenSaverOnly" then
        -- Allow screen saver but prevent system sleep
        hs.caffeinate.set("displayIdle", false)
        hs.caffeinate.set("systemIdle", true)
    elseif mode == "fullyAwake" then
        -- Prevent both screen saver and system sleep
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

if caffeine then
    caffeine:setClickCallback(cycleCaffeineModes)
    setCaffeineState("off")
end

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "C", cycleCaffeineModes)
