-- Type clipboard contents.
function typeFromClipboard()
    local contents = hs.pasteboard.getContents()
    if contents then
        hs.eventtap.keyStrokes(contents)
    end
end
