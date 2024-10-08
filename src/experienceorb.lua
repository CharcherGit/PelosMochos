-- src/experienceorb.lua

local Utils = require("src.utils")  -- Add this line at the top of the file

local ExperienceOrb = {}
ExperienceOrb.__index = ExperienceOrb

function ExperienceOrb:new(x, y, value)
    local this = {
        x = x,
        y = y,
        value = value,
        size = 10,  -- Tamaño ligeramente aumentado
        innerColor = {0.8, 0.3, 1, 1},  -- Color púrpura claro
        outerColor = {0.5, 0.1, 0.8, 1},  -- Color púrpura oscuro
        glowColor = {1, 0.7, 1, 0.5},  -- Brillo rosado
        isCollected = false,
        angle = 0,
        orbitRadius = 3,
        orbitSpeed = 5,
        pulseSpeed = 3,
        attractionRange = 200,
        attractionSpeed = 250
    }
    setmetatable(this, ExperienceOrb)
    return this
end

function ExperienceOrb:update(dt, player)
    if not self.isCollected then
        self.angle = self.angle + self.orbitSpeed * dt
        
        -- Atracción hacia el jugador
        local distance = Utils.distance(self.x, self.y, player.x, player.y)
        if distance < self.attractionRange then
            local angle = math.atan2(player.y - self.y, player.x - self.x)
            local attractionForce = (1 - distance / self.attractionRange) * self.attractionSpeed
            self.x = self.x + math.cos(angle) * attractionForce * dt
            self.y = self.y + math.sin(angle) * attractionForce * dt
            
            -- Efecto de "tubería" mejorado
            local distanceRatio = distance / self.attractionRange
            self.size = 10 * (0.8 + 0.4 * distanceRatio)
            self.orbitRadius = 3 * distanceRatio
        end
        
        -- Recolección
        if distance < player.size / 2 + self.size / 2 then
            self.isCollected = true
            player:addExperience(self.value)
        end
    end
end

function ExperienceOrb:draw()
    if not self.isCollected then
        love.graphics.push()
        love.graphics.translate(self.x, self.y)
        
        -- Efecto de pulsación
        local scale = 1 + math.sin(love.timer.getTime() * self.pulseSpeed) * 0.1
        
        -- Dibujar brillo exterior
        love.graphics.setColor(self.glowColor)
        love.graphics.circle("fill", 0, 0, self.size * scale * 1.3)
        
        -- Dibujar orbe exterior
        love.graphics.setColor(self.outerColor)
        love.graphics.circle("fill", 0, 0, self.size * scale)
        
        -- Dibujar orbe interior
        love.graphics.setColor(self.innerColor)
        love.graphics.circle("fill", 0, 0, self.size * scale * 0.7)
        
        -- Dibujar brillo orbital
        local glowX = math.cos(self.angle) * self.orbitRadius
        local glowY = math.sin(self.angle) * self.orbitRadius
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.circle("fill", glowX, glowY, self.size * 0.2)
        
        -- Dibujar reborde
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.circle("line", 0, 0, self.size * scale)
        
        love.graphics.pop()
    end
end

return ExperienceOrb