-- src/weapons.lua

local Bullet = require("src.bullet")
local Utils = require("src.utils")

local Weapons = {}

-- Añade estas constantes después de las existentes
local MISSILE_MAX_RANGE = 500  -- Rango máximo del misil en píxeles
local MISSILE_EXPLOSION_RADIUS = 100  -- Radio de explosión del misil
local MISSILE_SPEED = 200  -- Velocidad del misil
local MISSILE_COOLDOWN = 5  -- Tiempo de recarga del lanzamisiles en segundos
local MISSILE_EXPLOSION_DURATION = 0.5  -- Duración de la explosión en segundos
local MISSILE_DAMAGE_AREA_DURATION = 5  -- Duración del área de daño en segundos
local MISSILE_SIZE = 40  -- Tamaño del misil
local EXPLOSION_SIZE = 200  -- Tamaño de la explosión
local GROUND_FIRE_SIZE = 150  -- Tamaño del fuego en el suelo

local FLAME_COUNT = 10  -- Número de llamas a dibujar
local FLAME_ANIMATION_SPEED = 5  -- Velocidad de la animación

function Weapons.standardGun(player, bullets, bulletPool, camera)
    local currentTime = love.timer.getTime()
    if currentTime - player.lastShot > player.shootCooldown then
        local mx, my = love.mouse.getPosition()
        local mouseXWorld = mx + camera.x
        local mouseYWorld = my + camera.y
        local angle = math.atan2(mouseYWorld - player.y, mouseXWorld - player.x)
        
        local bullet = Weapons.createBullet(player, bulletPool, angle, "standard")
        table.insert(bullets, bullet)
        
        player.lastShot = currentTime
    end
end

function Weapons.circleShot(player, bullets, bulletPool)
    local currentTime = love.timer.getTime()
    if currentTime - player.lastCircleShot > player.circleShotCooldown then
        for i = 1, 8 do
            local angle = (i - 1) * math.pi / 4
            local bullet = Weapons.createBullet(player, bulletPool, angle, "circle")
            table.insert(bullets, bullet)
        end
        player.lastCircleShot = currentTime
    end
end

function Weapons.boomerang(player, bullets, bulletPool)
    local currentTime = love.timer.getTime()
    if currentTime - player.lastBoomerang > player.boomerangCooldown and not player.activeBoomerang then
        local angle = math.random() * 2 * math.pi  -- Ángulo aleatorio
        
        local bullet = Weapons.createBullet(player, bulletPool, angle, "boomerang")
        bullet.initialX = player.x
        bullet.initialY = player.y
        bullet.maxHeight = player.y - 200  -- Altura máxima que alcanzará el boomerang
        bullet.returnTimer = 1  -- Tiempo antes de que el boomerang regrese
        bullet.state = "going"  -- Estado inicial del boomerang
        table.insert(bullets, bullet)
        
        player.lastBoomerang = currentTime
        player.activeBoomerang = bullet  -- Guardamos una referencia al boomerang activo
    end
end

function Weapons.missileLauncher(player, bullets, bulletPool)
    local currentTime = love.timer.getTime()
    if currentTime - (player.lastMissile or 0) > (player.missileCooldown or MISSILE_COOLDOWN) then
        local angle = math.random() * 2 * math.pi  -- Ángulo aleatorio
        local distance = math.random(MISSILE_MAX_RANGE / 2, MISSILE_MAX_RANGE)
        
        local targetX = player.x + math.cos(angle) * distance
        local targetY = player.y + math.sin(angle) * distance
        
        local missile = Weapons.createBullet(player, bulletPool, angle, "missile")
        missile.targetX = targetX
        missile.targetY = targetY
        missile.speed = MISSILE_SPEED
        missile.explosionRadius = MISSILE_EXPLOSION_RADIUS
        missile.state = "flying"
        missile.size = MISSILE_SIZE
        missile.explosionSize = EXPLOSION_SIZE
        missile.image = love.graphics.newImage("assets/images/weapons/misil.png")
        missile.explosionImage = love.graphics.newImage("assets/images/weapons/misil_explosion.png")
        missile.groundFireImage = love.graphics.newImage("assets/images/weapons/misil_llamas_suelo.png")
        
        table.insert(bullets, missile)
        
        player.lastMissile = currentTime
    end
end

function Weapons.createBullet(player, bulletPool, angle, bulletType)
    local bullet
    if #bulletPool > 0 then
        bullet = table.remove(bulletPool)
        bullet:reset(player.x, player.y, angle, player.damage, bulletType)
    else
        bullet = Bullet:new(player.x, player.y, angle, player.damage, bulletType)
    end
    
    if bulletType == "missile" then
        bullet.update = Weapons.updateMissile
        bullet.draw = Weapons.drawMissile
        bullet.animationTime = 0  -- Inicializa el tiempo de animación
    end
    
    return bullet
end

function Weapons.updateMissile(missile, dt, player, enemies)
    missile.animationTime = missile.animationTime + dt
    if missile.state == "flying" then
        local angle = math.atan2(missile.targetY - missile.y, missile.targetX - missile.x)
        missile.x = missile.x + math.cos(angle) * missile.speed * dt
        missile.y = missile.y + math.sin(angle) * missile.speed * dt
        
        if Utils.distance(missile.x, missile.y, missile.targetX, missile.targetY) < 5 then
            missile.state = "exploding"
            missile.explosionTimer = MISSILE_EXPLOSION_DURATION
            missile.explosionScale = 0
        end
    elseif missile.state == "exploding" then
        missile.explosionTimer = missile.explosionTimer - dt
        missile.explosionScale = math.min(1, missile.explosionScale + dt * 4)  -- Crecer hasta tamaño completo en 0.25 segundos
        
        if missile.explosionTimer <= 0 then
            missile.state = "damageArea"
            missile.damageAreaTimer = MISSILE_DAMAGE_AREA_DURATION
        end
    elseif missile.state == "damageArea" then
        missile.damageAreaTimer = missile.damageAreaTimer - dt
        
        if enemies then
            for _, enemy in ipairs(enemies) do
                if Utils.distance(missile.x, missile.y, enemy.x, enemy.y) <= missile.explosionRadius then
                    enemy:takeDamage(missile.damage * dt)
                end
            end
        end
        
        if missile.damageAreaTimer <= 0 then
            missile.state = "finished"
        end
    end
end

function Weapons.drawMissile(missile)
    if missile.state == "flying" then
        local angle = math.atan2(missile.targetY - missile.y, missile.targetX - missile.x)
        love.graphics.draw(missile.image, missile.x, missile.y, angle + math.pi/2, 
            missile.size / missile.image:getWidth(), 
            missile.size / missile.image:getHeight(), 
            missile.image:getWidth()/2, missile.image:getHeight())
    elseif missile.state == "exploding" then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(missile.explosionImage, missile.x, missile.y, 0, 
            missile.explosionScale * missile.explosionSize / missile.explosionImage:getWidth(), 
            missile.explosionScale * missile.explosionSize / missile.explosionImage:getHeight(), 
            missile.explosionImage:getWidth()/2, missile.explosionImage:getHeight()/2)
    elseif missile.state == "damageArea" then
        local alpha = missile.damageAreaTimer / MISSILE_DAMAGE_AREA_DURATION
        love.graphics.setColor(1, 1, 1, alpha)
        
        -- Dibujar múltiples llamas
        for i = 1, FLAME_COUNT do
            local angle = (i - 1) * (2 * math.pi / FLAME_COUNT)
            local radius = missile.explosionRadius * 0.8  -- Ajusta este valor para cambiar la distribución de las llamas
            local x = missile.x + math.cos(angle) * radius
            local y = missile.y + math.sin(angle) * radius
            
            -- Animación simple de escala
            local scale = 1 + math.sin(love.timer.getTime() * FLAME_ANIMATION_SPEED + i) * 0.2
            
            love.graphics.draw(missile.groundFireImage, x, y, angle,
                scale * missile.explosionRadius / missile.groundFireImage:getWidth() * 0.4,
                scale * missile.explosionRadius / missile.groundFireImage:getHeight() * 0.4,
                missile.groundFireImage:getWidth()/2, missile.groundFireImage:getHeight()/2)
        end
        
        -- Dibujar un círculo alrededor del área de daño para mayor claridad
        love.graphics.setColor(1, 0, 0, alpha * 0.5)
        love.graphics.circle("line", missile.x, missile.y, missile.explosionRadius)
        
        love.graphics.setColor(1, 1, 1, 1)
    end
end

-- Añade esta función para inicializar el shader
function Weapons.initializeShaders()
    Weapons.flameShader = love.graphics.newShader[[
        extern number time;
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
        {
            vec4 pixel = Texel(texture, texture_coords);
            float brightness = sin(time * 5.0 + texture_coords.y * 10.0) * 0.2 + 0.8;
            return pixel * color * vec4(brightness, brightness, brightness, 1.0);
        }
    ]]
end

return Weapons