--[[

This file patches ISObjectClickHandler to prevent the world objects context menu from opening.
The hook needs to be done here, because the game has two different triggers called later for
the world objects context menu, which makes the disassemble menu appear even when disabling
the code which triggers OnFillWorldObjectContextMenu.

]]


local patch = {}

---CACHE
local WT = require "WikiThat!/module"

patch.ISObjectClickHandler_doRClick = ISObjectClickHandler.doRClick
ISObjectClickHandler.doRClick = function (object, x, y)
    if WT.moodleRightClicked then
        WT.moodleRightClicked = false
        return
    end
    return patch.ISObjectClickHandler_doRClick(object, x, y)
end