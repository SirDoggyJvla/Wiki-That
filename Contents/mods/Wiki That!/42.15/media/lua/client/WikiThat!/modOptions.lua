--[[

Mod options

]]--

local Translations = require "WikiThat!/translations"

local options = PZAPI.ModOptions:create("WikiThat", getText(Translations.MAIN))
-- options:addTitle("Wiki That!")
-- options:addSeparator()
local OPTION_PAUSE = options:addTickBox("WikiThat_Pause", getText(Translations.MODOPTIONS_PAUSE), true)
local OPTION_BROWSER = options:addTickBox("WikiThat_Browser", getText(Translations.MODOPTIONS_BROWSER), false)

return {
    __options__ = options,
    Pause = OPTION_PAUSE,
    Browser = OPTION_BROWSER,
}