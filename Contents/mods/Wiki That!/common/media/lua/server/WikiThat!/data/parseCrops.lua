---CACHE
local cropDictionary = require "WikiThat!/data/crops"
-- cropDictionary.__sprites__ = {}

local WT_parseCrops = {}

local toParse = {
    farming_vegetableconf.sprite,
    farming_vegetableconf.unhealthySprite,
    farming_vegetableconf.dyingSprite,
    farming_vegetableconf.deadSprite,
    farming_vegetableconf.trampledSprite,
}

---Parser the vegetable sprites and store the sprite ID associated to its crop ID.
WT_parseCrops.parseVegetableSprites = function()
    for i = 1, #toParse do
        local vegetable_sprites = toParse[i]
        for crop, sprites in pairs(vegetable_sprites) do repeat
            for j = 1, #sprites do
                local sprite = sprites[j]
                cropDictionary.__sprites__[sprite] = crop
            end
        until true end
    end
end

WT_parseCrops.parseVegetableSprites()

return WT_parseCrops