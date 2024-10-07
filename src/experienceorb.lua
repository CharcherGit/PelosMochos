-- src/experienceorb.lua

local Utils = require("src.utils")  -- Add this line at the top of the file

local ExperienceOrb = {}
ExperienceOrb.__index = ExperienceOrb

function ExperienceOrb:new(x, y, value)
    local this = {
        x = x,
        y = y,
        value = value,
        size = 20,
        color = {1, 1, 0, 1},  -- Yellow color
        isCollected = false
    }
    setmetatable(this, ExperienceOrb)
    return this
end

function ExperienceOrb:update(dt, player)
    if not self.isCollected then
        local distance = Utils.distance(self.x, self.y, player.x, player.y)
        if distance < player.size / 2 + self.size then
            self.isCollected = true
            player:addExperience(self.value)
        end
    end
end

function ExperienceOrb:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.size)
    
    -- Draw a smaller, brighter circle inside for extra glow effect
    love.graphics.setColor(1, 1, 1, 1)  -- White color
    love.graphics.circle("fill", self.x, self.y, self.size * 0.5)
end

return ExperienceOrb