require "ISUI/ISRichTextPanel"
local originalProcessCommand = ISRichTextPanel.processCommand
function ISRichTextPanel:processCommand(command, x, y, lineImageHeight, lineHeight)
    if string.find(command, "FLUIDBOXCENTRE:") then
        local prepare = string.split(command, ":")
        local split = string.split(prepare[2], ",")

        local w = tonumber(string.trim(split[1]))
        local h = tonumber(string.trim(split[2]))
        local r = tonumber(string.trim(split[3]))
        local g = tonumber(string.trim(split[4]))
        local b = tonumber(string.trim(split[5]))

        if(x + w >= self.width - (self.marginLeft + self.marginRight)) then
            x = 0
            y = y + lineHeight
        end

        if(lineImageHeight < (h / 2) + 8) then
            lineImageHeight = (h / 2) + 16
        end

        local mx = (self.width - self.marginLeft - self.marginRight) / 2
        local entry = {
            x=mx - (w/2), y=y,
            w=w, h=h,
            r=r, g=g, b=b,
        }

        self.fluidbox = self.fluidbox or {} -- init
        table.insert(self.fluidbox, entry)

        -- new position values
        x = x + w + 7
        y = y + h / 2
    end

    command = string.gsub(command, "&WT_SPACE_PATTERN;", " ")
    return originalProcessCommand(self, command, x, y, lineImageHeight, lineHeight)
end

local originalPaginate = ISRichTextPanel.paginate
function ISRichTextPanel:paginate()
    self.fluidbox = nil -- reset
    return originalPaginate(self)
end

local originalRender = ISRichTextPanel.render
function ISRichTextPanel:render()
    originalRender(self)

    local fluidbox = self.fluidbox
    if not fluidbox then return end

    for i=1,#fluidbox do
        local entry = fluidbox[i]
        if entry.drawn then break end -- only draw one per render call

        local x,y = entry.x, entry.y
        local w,h = entry.w, entry.h
        local r,g,b = entry.r, entry.g, entry.b

        -- draw centered rectangle
        self:drawRect(x + self.marginLeft, y + self.marginTop, w, h, 1, r, g, b)
    end
end