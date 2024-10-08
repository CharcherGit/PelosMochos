-- main.lua

local Player = require("src.player")
local Enemy = require("src.enemy")
local Bullet = require("src.bullet")
local Map = require("src.map")
local Camera = require("src.camera")
local UI = require("src.ui")
local TitleScreen = require("src.titlescreen")
local Utils = require("src.utils")
require "tiledmap"

local CHUNK_SIZE = 500
local UPDATE_DISTANCE = 1000

local player, enemies, map, camera, ui, titleScreen
local gameState = "title"
local music

local SHADOW_OFFSET_X = 5  -- Desplazamiento horizontal de la sombra
local SHADOW_OFFSET_Y = 5  -- Desplazamiento vertical de la sombra

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Initialize Map
    map = Map:new("assets/maps/map01.tmx")  -- Change this to your Tiled map file
    print("Map loaded")
    print("gMapLayers:", gMapLayers and #gMapLayers or "nil")
    print("gMapObjects:", gMapObjects and #gMapObjects or "nil")
    for i, obj in ipairs(map.collisionObjects) do
        print(string.format("Object %d: x=%f, y=%f, width=%f, height=%f, type=%s",
                            i, obj.x, obj.y, obj.width, obj.height, obj.type))
    end
    
    -- Initialize Player
    player = Player:new(map.pixelWidth / 2, map.pixelHeight / 2, map)
    
    -- Inicializar Enemigos
    enemies = {}
    enemyPool = {}
    for i = 1, 50 do
        table.insert(enemyPool, Enemy:new(map))
    end
    enemySpawnTimer = 0
    enemySpawnInterval = 2
    maxEnemies = 100
    
    -- Inicializar Balas
    bullets = {}
    bulletPool = {}
    for i = 1, 100 do
        table.insert(bulletPool, Bullet:new(0, 0, 0, 0))
    end
    
    -- Inicializar Cámara
    camera = Camera:new(player.x, player.y, love.graphics.getWidth(), love.graphics.getHeight(), map)
    
    -- Inicializar UI
    ui = UI:new(player)
    
    -- Inicializar sistema de mejoras
    upgradeTimer = 0
    upgradeInterval = 30  -- Mejora cada 30 segundos
    
    -- Inicializar orbes de experiencia
    experienceOrbs = {}
    
    -- Create a canvas for experience orbs
    orbCanvas = love.graphics.newCanvas()
    
    titleScreen = TitleScreen:new()
    
    -- Inicializar y reproducir la música
    music = love.audio.newSource("assets/audio/music.mp3", "stream")
    music:setLooping(true)
    music:play()
end

function love.update(dt)
    if gameState == "title" then
        titleScreen:update(dt)
    elseif gameState == "game" then
        -- Actualizar Jugador
        player:update(dt, bullets, bulletPool, camera, enemies)  -- Añadido 'enemies' aquí

        -- Actualizar Balas
        for i = #bullets, 1, -1 do
            local bullet = bullets[i]
            bullet:update(dt, player, enemies)  -- Añadido 'enemies' aquí
            if not bullet:isAlive(map.pixelWidth, map.pixelHeight, player) then
                table.insert(bulletPool, table.remove(bullets, i))
                if bullet.bulletType == "boomerang" and bullet == player.activeBoomerang then
                    player.activeBoomerang = nil  -- Permite lanzar otro boomerang
                end
            end
        end

        -- Spawn de Enemigos
        enemySpawnTimer = enemySpawnTimer + dt
        if enemySpawnTimer > enemySpawnInterval and #enemies < maxEnemies then
            local spawnDistance = UPDATE_DISTANCE + 100 -- Spawn justo fuera de la distancia de actualización
            local angle = math.random() * math.pi * 2
            local spawnX = player.x + math.cos(angle) * spawnDistance
            local spawnY = player.y + math.sin(angle) * spawnDistance
            
            local enemy
            if #enemyPool > 0 then
                enemy = table.remove(enemyPool)
                enemy:reset(spawnX, spawnY)
            else
                enemy = Enemy:new(spawnX, spawnY)
            end
            table.insert(enemies, enemy)
            enemySpawnTimer = 0
        end

        -- Actualizar Enemigos
        for i = #enemies, 1, -1 do
            local enemy = enemies[i]
            enemy:update(dt, player)
            
            if enemy.isDead then
                table.insert(enemyPool, table.remove(enemies, i))
            end
        end

        -- Colisiones Balas-Enemigos
        for i = #enemies, 1, -1 do
            local enemy = enemies[i]
            for j = #bullets, 1, -1 do
                local bullet = bullets[j]
                if Utils.distance(enemy.x, enemy.y, bullet.x, bullet.y) < (enemy.size + bullet.size) / 2 then
                    local experienceOrb = enemy:takeDamage(bullet.damage)
                    if experienceOrb then
                        table.insert(experienceOrbs, experienceOrb)
                    end
                    if bullet.bulletType ~= "missile" then  -- No eliminar misiles al impactar
                        table.insert(bulletPool, table.remove(bullets, j))
                    end
                    if enemy.isDead then
                        table.insert(enemyPool, table.remove(enemies, i))
                        break
                    end
                end
            end
        end

        -- Colisiones Jugador-Enemigos
        for _, enemy in ipairs(enemies) do
            if Utils.distance(player.x, player.y, enemy.x, enemy.y) < (player.size + enemy.size) / 2 then
                local damage = math.max(enemy.damage - player.defense, 1)
                player:takeDamage(damage)
                if player.isDead then
                    break
                end
            end
        end

        -- Actualizar Cámara
        camera:update(player.x, player.y)
        
        -- Sistema de mejoras
        upgradeTimer = upgradeTimer + dt
        if upgradeTimer >= upgradeInterval then
            player:upgrade()
            upgradeTimer = 0
        end

        -- Actualizar UI
        ui:update(dt)
        
        -- Actualizar orbes de experiencia
        for i = #experienceOrbs, 1, -1 do
            local orb = experienceOrbs[i]
            orb:update(dt, player)
            if orb.isCollected then
                table.remove(experienceOrbs, i)
            end
        end
    end
end

function love.draw()
    if gameState == "title" then
        titleScreen:draw()
    elseif gameState == "game" then
        camera:apply()
        
        -- Dibujar el mapa
        map:draw()
        
        -- Calcular la dirección de la luz basada en la posición del jugador
        local centerX, centerY = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2
        local lightAngle = math.atan2(player.y - centerY, player.x - centerX)
        local shadowOffsetX = math.cos(lightAngle) * SHADOW_OFFSET_X
        local shadowOffsetY = math.sin(lightAngle) * SHADOW_OFFSET_Y
        
        -- Dibujar sombras de enemigos
        love.graphics.setColor(0, 0, 0, 0.2)
        for _, enemy in ipairs(enemies) do
            if enemy.isActive then
                love.graphics.ellipse("fill", 
                    enemy.x + shadowOffsetX, 
                    enemy.y + shadowOffsetY + enemy.size * 0.4, 
                    enemy.size * 0.3, 
                    enemy.size * 0.2)
            end
        end
        
        -- Dibujar sombra del jugador
        if not player.isDead then
            love.graphics.ellipse("fill", 
                player.x + shadowOffsetX, 
                player.y + shadowOffsetY + player.size * 0.4, 
                player.size * 0.3, 
                player.size * 0.2)
        end
        
        love.graphics.setColor(1, 1, 1, 1)  -- Restaurar color
        
        -- Dibujar enemigos
        for _, enemy in ipairs(enemies) do
            if enemy.isActive then
                enemy:draw()
            end
        end
        
        -- Dibujar jugador
        if not player.isDead then
            player:draw()
        end
        
        -- Dibujar balas
        for _, bullet in ipairs(bullets) do
            bullet:draw()
        end
        
        camera:release()

        -- Draw experience orbs on a separate canvas
        love.graphics.setCanvas(orbCanvas)
        love.graphics.clear()
        camera:apply()
        for _, orb in ipairs(experienceOrbs) do
            orb:draw()
        end
        camera:release()
        love.graphics.setCanvas()

        -- Draw the main game canvas
        love.graphics.draw(orbCanvas)

        -- Draw UI
        ui:draw()
    end
end

function love.keypressed(key)
    if gameState == "title" and key == "return" then
        gameState = "game"
    end
end