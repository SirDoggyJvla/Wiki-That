--[[

Mod options

]]--

local options = PZAPI.ModOptions:create("WikiThat", getText("IGUI_WikiThat"))
-- options:addTitle("Wiki That!")
-- options:addSeparator()
local OPTION_PAUSE = options:addTickBox("WikiThat_Pause", getText("IGUI_WikiThat_ModOptions_Pause"), true)

return {
    Pause = OPTION_PAUSE,
}