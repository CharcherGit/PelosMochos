-- src/camera.lua

local Camera = {}
Camera.__index = Camera

function Camera:new(x, y, screenWidth, screenHeight, map)
    local this = {
        x = x - screenWidth / 2,
        y = y - screenHeight / 2,
        screenWidth = screenWidth,
        screenHeight = screenHeight,
        map = map
    }
    setmetatable(this, Camera)
    return this
end

function Camera:update(playerX, playerY)
    self.x = playerX - self.screenWidth / 2
    self.y = playerY - self.screenHeight / 2

    -- Limit camera position to map bounds
    self.x = math.max(0, math.min(self.x, self.map.pixelWidth - self.screenWidth))
    self.y = math.max(0, math.min(self.y, self.map.pixelHeight - self.screenHeight))
end

function Camera:apply()
    love.graphics.push()
    love.graphics.translate(-math.floor(self.x), -math.floor(self.y))
end

function Camera:release()
    love.graphics.pop()
end

return Camera