-- Natural scrolling for mouse (while preserving trackpad behaviour).
reverse_mouse_scroll = hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(event)
    -- detect if this is touchpad or mouse
    local isTrackpad = event:getProperty(hs.eventtap.event.properties.scrollWheelEventIsContinuous)
    if isTrackpad == 1 then
        return false -- trackpad: pass the event along
    end

    event:setProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1,
        -event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1))
    return false -- pass the event along
end):start()
