-- src/player.lua

local Bullet = require("src.bullet")
local Utils = require("src.utils")
local Weapons = require("src.weapons")

local Player = {}
Player.__index = Player

function Player:new(x, y, map)
    local this = {
        x = x,
        y = y,
        speed = 120,
        size = 120,
        lastShot = 0,
        shootCooldown = 0.5,
        circleShotCooldown = 5,
        boomerangCooldown = 3,
        lastCircleShot = 0,
        lastBoomerang = 0,
        health = 100,
        damage = 20,
        defense = 0,
        isDead = false,
        map = map,
        image = love.graphics.newImage("assets/images/personaje.png"),
        upgradeLevel = 0,
        activeBoomerang = nil,
        experience = 0,
        level = 1,
        experienceToNextLevel = 100
    }
    setmetatable(this, Player)
    return this
end

function Player:update(dt, bullets, bulletPool, camera)
    -- Mover jugador
    local movement = self.speed * dt
    if love.keyboard.isDown("w") then
        self.y = Utils.clamp(self.y - movement, self.size / 2, self.map.pixelHeight - self.size / 2)
    end
    if love.keyboard.isDown("s") then
        self.y = Utils.clamp(self.y + movement, self.size / 2, self.map.pixelHeight - self.size / 2)
    end
    if love.keyboard.isDown("a") then
        self.x = Utils.clamp(self.x - movement, self.size / 2, self.map.pixelWidth - self.size / 2)
    end
    if love.keyboard.isDown("d") then
        self.x = Utils.clamp(self.x + movement, self.size / 2, self.map.pixelWidth - self.size / 2)
    end

    -- Disparo estándar
    Weapons.standardGun(self, bullets, bulletPool, camera)

    -- Disparo circular
    Weapons.circleShot(self, bullets, bulletPool)

    -- Boomerang
    Weapons.boomerang(self, bullets, bulletPool, camera)
end

function Player:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        self.image,
        self.x,
        self.y,
        self.angle or 0,
        self.size / self.image:getWidth(),
        self.size / self.image:getHeight(),
        self.image:getWidth() / 2,
        self.image:getHeight() / 2
    )
end

function Player:takeDamage(amount)
    self.health = self.health - amount
    if self.health <= 0 then
        self.isDead = true
    end
end

function Player:upgrade()
    self.upgradeLevel = self.upgradeLevel + 1
    self.damage = self.damage + 5
    self.shootCooldown = math.max(0.1, self.shootCooldown - 0.05)
end

function Player:addExperience(value)
    self.experience = self.experience + value
    if self.experience >= self.experienceToNextLevel then
        self:levelUp()
    end
end

function Player:levelUp()
    self.level = self.level + 1
    self.experience = self.experience - self.experienceToNextLevel
    self.experienceToNextLevel = math.floor(self.experienceToNextLevel * 1.2)
    
    -- Mejora de estadísticas al subir de nivel
    self.health = self.health + 10
    self.damage = self.damage + 5
    self.defense = self.defense + 1
    self.speed = self.speed + 10
    
    -- Puedes añadir más mejoras o habilidades aquí
end

return Player