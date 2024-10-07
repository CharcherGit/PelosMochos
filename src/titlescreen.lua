local TitleScreen = {}

function TitleScreen:new()
    local this = {
        logo = love.graphics.newImage("assets/images/logo.png"),
        music = nil,  -- Remove the music from here
        zoom = 1,
        zoomDirection = 1,
        zoomSpeed = 0.1,
        zoomMin = 0.9,
        zoomMax = 1.1,
        enemyImage = love.graphics.newImage("assets/images/enemigo.png"),
        enemies = {}
    }
    
    -- Crear enemigos de fondo
    for i = 1, 10 do
        table.insert(this.enemies, {
            x = love.math.random(0, love.graphics.getWidth()),
            y = love.math.random(0, love.graphics.getHeight()),
            dx = love.math.random(50, 150) * (love.math.random() < 0.5 and 1 or -1),
            dy = love.math.random(50, 150) * (love.math.random() < 0.5 and 1 or -1),
            rotation = 0,
            rotationSpeed = love.math.random(1, 3) * (love.math.random() < 0.5 and 1 or -1)
        })
    end

    setmetatable(this, self)
    self.__index = self
    return this
end

function TitleScreen:update(dt)
    self.zoom = self.zoom + self.zoomDirection * self.zoomSpeed * dt
    if self.zoom > self.zoomMax or self.zoom < self.zoomMin then
        self.zoomDirection = -self.zoomDirection
    end

    -- Actualizar enemigos de fondo
    for _, enemy in ipairs(self.enemies) do
        enemy.x = enemy.x + enemy.dx * dt
        enemy.y = enemy.y + enemy.dy * dt
        enemy.rotation = enemy.rotation + enemy.rotationSpeed * dt

        -- Rebotar en los bordes
        if enemy.x < 0 or enemy.x > love.graphics.getWidth() then
            enemy.dx = -enemy.dx
        end
        if enemy.y < 0 or enemy.y > love.graphics.getHeight() then
            enemy.dy = -enemy.dy
        end
    end
end

function TitleScreen:draw()
    -- Dibujar enemigos de fondo
    love.graphics.setColor(0.5, 0.5, 0.5, 0.3)  -- Color gris semitransparente
    for _, enemy in ipairs(self.enemies) do
        love.graphics.draw(
            self.enemyImage,
            enemy.x,
            enemy.y,
            enemy.rotation,
            0.5,  -- Escala
            0.5,
            self.enemyImage:getWidth() / 2,
            self.enemyImage:getHeight() / 2
        )
    end

    -- Dibujar logo
    love.graphics.setColor(1, 1, 1)
    local scale = self.zoom * math.min(love.graphics.getWidth() / self.logo:getWidth(), love.graphics.getHeight() / self.logo:getHeight())
    love.graphics.draw(self.logo, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 0, scale, scale, self.logo:getWidth() / 2, self.logo:getHeight() / 2)
    
    -- Dibujar texto
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("Press Enter to Play", 0, love.graphics.getHeight() * 0.8, love.graphics.getWidth(), "center")
end

return TitleScreen