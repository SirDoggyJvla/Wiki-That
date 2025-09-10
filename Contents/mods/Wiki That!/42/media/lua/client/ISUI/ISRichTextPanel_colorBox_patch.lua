require "ISUI/ISRichTextPanel"
local originalProcessCommand = ISRichTextPanel.processCommand
function ISRichTextPanel:processCommand(command, x, y, lineImageHeight, lineHeight)
    if string.find(command, "FLUIDBOXCENTRE:") then
        -- local w = 50
        -- local h = 50
        -- local r,g,b = 1,1,1

        local prepare = string.split(command, ":")
        local split = string.split(prepare[2], ",")

        local w = tonumber(string.trim(split[1]))
        local h = tonumber(string.trim(split[2]))
        local r = tonumber(string.trim(split[3]))
        local g = tonumber(string.trim(split[4]))
        local b = tonumber(string.trim(split[5]))

        -- if string.find(command, ",") ~= nil then
        --     local vs = string.split(command, ",")
        --     print(#vs)
        --     for i=1,#vs do
        --         print(vs[i])
        --     end
        --     command = string.trim(vs[1])
        --     w = tonumber(string.trim(vs[2]))
        --     h = tonumber(string.trim(vs[3]))
        --     r = tonumber(string.trim(vs[4]))
        --     g = tonumber(string.trim(vs[5]))
        --     b = tonumber(string.trim(vs[6]))
        -- end
        self.colorbox = self.colorbox or {} -- init

        if(x + w >= self.width - (self.marginLeft + self.marginRight)) then
            x = 0;
            y = y +  lineHeight;
        end

        if(lineImageHeight < (h / 2) + 8) then
            lineImageHeight = (h / 2) + 16;
        end

        local mx = (self.width - self.marginLeft - self.marginRight) / 2
        local entry = {
            x=mx - (w/2),
            y=y,
            w=w,
            h=h,
            r=r,
            g=g,
            b=b,
        }
        table.insert(self.colorbox, entry)

        -- new position values
        x = x + w + 7
        y = y + h / 2
    end

    return originalProcessCommand(self, command, x, y, lineImageHeight, lineHeight)
end

local originalRender = ISRichTextPanel.render
function ISRichTextPanel:render()
    originalRender(self)

    local colorbox = self.colorbox
    if not colorbox then return end

    for i=1,#colorbox do
        local entry = colorbox[i]
        if entry.drawn then break end -- only draw one per render call

        local x,y = entry.x, entry.y
        local w,h = entry.w, entry.h
        local r,g,b = entry.r, entry.g, entry.b

        -- draw centered rectangle
        self:drawRect(x + self.marginLeft, y + self.marginTop, w, h, 1, r, g, b)
    end
end