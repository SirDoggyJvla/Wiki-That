local patch = {
    url = "https://steamcommunity.com/linkfilter/?u=https://pzwiki.net",
}

-- cache values
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local BUTTON_HGT = FONT_HGT_SMALL + 6
local UI_BORDER_SPACING = 10
local JOYPAD_TEX_SIZE = 32

-- store original
patch.original_instantiate = MainScreen.instantiate

-- current width
local btnWidth = UI_BORDER_SPACING*2 + math.max(
    getTextManager():MeasureStringX(UIFont.Small, getText("UI_Details")),
    getTextManager():MeasureStringX(UIFont.Small, getText("UI_NewGame_Mods")),
    getTextManager():MeasureStringX(UIFont.Small, getText("UI_TermsOfService_MainMenu")),
    getTextManager():MeasureStringX(UIFont.Small, getText("UI_ResetLua")),
    getTextManager():MeasureStringX(UIFont.Small, getText("UI_ReportBug")),
    getTextManager():MeasureStringX(UIFont.Small, "Wiki That!")
)

-- patched instantiate
function MainScreen:instantiate()
    patch.original_instantiate(self)

    self:createWTButton()
end

-- create wiki button
function MainScreen:createWTButton()
    local buttonH = getDebug() and self.resetLua.y or self.termsOfService.y
    buttonH = buttonH - UI_BORDER_SPACING - self.termsOfService.height

    -- create wiki button
    local wikiDictionary = ISButton:new(self.width - btnWidth - UI_BORDER_SPACING*4, buttonH, btnWidth, BUTTON_HGT, "Wiki Dictionary", self, patch.openWiki)
    wikiDictionary:initialise()
    wikiDictionary.borderColor = {r=1, g=0, b=0, a=1}
    wikiDictionary.backgroundColor = {r=1, g=0, b=0, a=0.5}
    wikiDictionary.textColor = {r=1, g=1, b=1, a=1}
    self:addChild(wikiDictionary)
    wikiDictionary:setAnchorLeft(false)
    wikiDictionary:setAnchorTop(false)
    wikiDictionary:setAnchorRight(true)
    wikiDictionary:setAnchorBottom(true)
    self.wikiDictionary = wikiDictionary
end

-- open wiki url
patch.openWiki = function()
    local url = patch.url
    if isSteamOverlayEnabled() then
        activateSteamOverlayToWebPage(url)
    else
        openUrl(url)
    end
end
