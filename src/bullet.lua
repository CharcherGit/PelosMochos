-- src/bullet.lua

local Utils = require("src.utils")  -- Añade esta línea al principio del archivo

local Bullet = {}
Bullet.__index = Bullet

function Bullet:new(x, y, angle, damage, bulletType)
    local speed = 500
    local size = bulletType == "boomerang" and 60 or 20  -- Tamaño más grande para el boomerang
    local this = {
        x = x,
        y = y,
        dx = math.cos(angle) * speed,
        dy = math.sin(angle) * speed,
        damage = damage,
        size = size,
        bulletType = bulletType,
        image = love.graphics.newImage(bulletType == "boomerang" and "assets/images/weapons/boomerang.png" or "assets/images/bala.png"),
        initialX = x,
        initialY = y,
        maxDistance = 400,  -- Distancia máxima que puede recorrer el boomerang
        distanceTraveled = 0,  -- Nueva propiedad para rastrear la distancia recorrida
        state = "going"
    }
    setmetatable(this, Bullet)
    return this
end

function Bullet:reset(x, y, angle, damage, bulletType)
    self.x = x
    self.y = y
    self.dx = math.cos(angle) * 500
    self.dy = math.sin(angle) * 500
    self.damage = damage
    self.bulletType = bulletType
    self.size = bulletType == "boomerang" and 60 or 20
    self.image = love.graphics.newImage(bulletType == "boomerang" and "assets/images/weapons/boomerang.png" or "assets/images/bala.png")
    self.initialX = x
    self.initialY = y
    self.maxDistance = 400
    self.distanceTraveled = 0
    self.state = "going"
end

function Bullet:update(dt, player)
    if self.bulletType == "boomerang" then
        self:updateBoomerang(dt, player)
    else
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt
    end
end

function Bullet:updateBoomerang(dt, player)
    if self.state == "going" then
        local oldX, oldY = self.x, self.y
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt
        
        self.distanceTraveled = self.distanceTraveled + Utils.distance(oldX, oldY, self.x, self.y)
        
        if self.distanceTraveled >= self.maxDistance then
            self.state = "returning"
        end
    elseif self.state == "returning" then
        local angle = math.atan2(player.y - self.y, player.x - self.x)
        self.dx = math.cos(angle) * 500
        self.dy = math.sin(angle) * 500
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt
        
        -- Comprobar si el boomerang ha tocado al jugador
        if Utils.distance(self.x, self.y, player.x, player.y) < (player.size + self.size) / 2 then
            self.state = "hit"
        end
    end
end

function Bullet:draw()
    love.graphics.draw(
        self.image,
        self.x,
        self.y,
        love.timer.getTime() * 10,  -- Rotación constante para el boomerang
        self.size / self.image:getWidth(),
        self.size / self.image:getHeight(),
        self.image:getWidth() / 2,
        self.image:getHeight() / 2
    )
end

function Bullet:isAlive(mapWidth, mapHeight, player)
    if self.bulletType == "boomerang" then
        return self.state ~= "hit" and self.x >= 0 and self.x <= mapWidth and self.y >= 0 and self.y <= mapHeight
    else
        return self.x >= 0 and self.x <= mapWidth and self.y >= 0 and self.y <= mapHeight
    end
end

return Bullet