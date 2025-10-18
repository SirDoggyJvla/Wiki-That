--[[

WikiElement for Moodles

]]

local WikiElement = require "WikiThat!/Objects/WikiElement"
local WT_utility = require "WikiThat!/utility"

---@class WEMoodle : WikiElement
---@field object Moodles
---@field moodleIndex integer|nil
local WEMoodle = WikiElement:derive("WEMoodle")

---Return the moodle type from the moodle index.
---@return MoodleType
function WEMoodle:_getMoodleType()
    if self.moodleType then
        return self.moodleType
    end
    self.moodleType = MoodleType.valueOf(self.type)
    return self.moodleType
end

function WEMoodle:_getName()
    return self.object:getMoodleDisplayString(MoodleType.ToIndex(self:_getMoodleType()))
end

function WEMoodle:_getIcon()
    local moodlesUI = MoodlesUI.getInstance()
    local moodleTextureSet = WT_utility.getJavaField(moodlesUI, "currentTextureSet") --[[@as MoodleTextureSet]]
    local moodleTextures = WT_utility.getJavaField(moodleTextureSet, "MoodleTextures")
    local moodleType = self:_getMoodleType()

    return moodleTextures[MoodleType.ToIndex(self:_getMoodleType()) + 1] -- +1 because Java arrays are 0-based
end

return WEMoodle