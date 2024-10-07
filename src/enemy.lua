-- src/enemy.lua

local Utils = require("src.utils")
local ExperienceOrb = require("src.experienceorb")  -- Añade esta línea

local Enemy = {}
Enemy.__index = Enemy

local CHUNK_SIZE = 500 -- Tamaño de cada chunk en píxeles
local UPDATE_DISTANCE = 1000 -- Distancia máxima para actualizar enemigos

function Enemy:new(x, y)
    local this = {
        x = x,
        y = y,
        speed = 100,
        size = 60,
        health = 100,
        damage = 1,
        isDead = false,
        image = love.graphics.newImage("assets/images/enemigo.png"),
        lastUpdateTime = 0,
        isActive = true,
        experienceValue = 10  -- Valor de experiencia que dará al morir
    }
    setmetatable(this, Enemy)
    return this
end

function Enemy:reset(x, y)
    self.x = x
    self.y = y
    self.health = 100
    self.isDead = false
    self.isActive = true
end

function Enemy:update(dt, player)
    if self.isDead then return end

    local distanceToPlayer = Utils.distance(player.x, player.y, self.x, self.y)
    self.isActive = distanceToPlayer < UPDATE_DISTANCE

    if self.isActive then
        -- Eliminamos la comprobación de tiempo y actualizamos en cada frame
        local angle = math.atan2(player.y - self.y, player.x - self.x)
        self.x = self.x + math.cos(angle) * self.speed * dt
        self.y = self.y + math.sin(angle) * self.speed * dt
    end
end

function Enemy:draw()
    love.graphics.draw(
        self.image,
        self.x,
        self.y,
        0,
        self.size / self.image:getWidth(),
        self.size / self.image:getHeight(),
        self.image:getWidth() / 2,
        self.image:getHeight() / 2
    )
    
    -- Dibujar Barra de Vida
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", self.x - self.size / 2, self.y - self.size / 2 - 15, self.size, 5)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", self.x - self.size / 2, self.y - self.size / 2 - 15, (self.health / 100) * self.size, 5)
    love.graphics.setColor(1, 1, 1)
end

function Enemy:takeDamage(amount)
    self.health = self.health - amount
    if self.health <= 0 then
        self.isDead = true
        return ExperienceOrb:new(self.x, self.y, self.experienceValue)
    end
    return nil
end

return Enemy