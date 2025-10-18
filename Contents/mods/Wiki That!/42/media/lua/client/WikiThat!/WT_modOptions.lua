--[[

Mod options

]]--

local options = PZAPI.ModOptions:create("WikiThat", getText("IGUI_WikiThat"))
-- options:addTitle("Wiki That!")
-- options:addSeparator()
local OPTION_PAUSE = options:addTickBox("WikiThat_Pause", getText("IGUI_WikiThat_ModOptions_Pause"), true)
local OPTION_BROWSER = options:addTickBox("WikiThat_Browser", getText("IGUI_WikiThat_ModOptions_Browser"), false)

return {
    __options__ = options,
    Pause = OPTION_PAUSE,
    Browser = OPTION_BROWSER,
}