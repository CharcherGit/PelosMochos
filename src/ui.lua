-- src/ui.lua

local UI = {}
UI.__index = UI

function UI:new(player)
    local this = {
        player = player,
        font = love.graphics.newFont(14)
    }
    setmetatable(this, UI)
    return this
end

function UI:update(dt)
    -- Aquí puedes actualizar elementos de la UI si es necesario
end

function UI:draw()
    -- Barra de Vida del Jugador
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 10, 10, 200, 20)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 10, 10, (self.player.health / 100) * 200, 20)
    love.graphics.setColor(1, 1, 1)
    
    -- Texto de Vida del Jugador
    love.graphics.setFont(self.font)
    love.graphics.print("Vida: " .. tostring(self.player.health), 10, 35)

    -- Estadísticas del Jugador
    love.graphics.print("Daño Bala: " .. tostring(self.player.damage), 10, 55)
    love.graphics.print("Velocidad: " .. tostring(self.player.speed), 10, 75)
    love.graphics.print("Defensa: " .. tostring(self.player.defense), 10, 95)
    
    -- Experiencia y Nivel del Jugador
    love.graphics.print("Nivel: " .. tostring(self.player.level), 10, 115)
    love.graphics.print("Experiencia: " .. tostring(self.player.experience) .. " / " .. tostring(self.player.experienceToNextLevel), 10, 135)
    
    -- Barra de Experiencia
    love.graphics.setColor(0.5, 0.5, 1)
    love.graphics.rectangle("fill", 10, 155, 200, 10)
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle("fill", 10, 155, (self.player.experience / self.player.experienceToNextLevel) * 200, 10)
    love.graphics.setColor(1, 1, 1)
    
    -- Game Over
    if self.player.isDead then
        love.graphics.setFont(love.graphics.newFont(36))
        love.graphics.printf("Game Over", 0, love.graphics.getHeight() / 2 - 18, love.graphics.getWidth(), "center")
    end
end

return UI