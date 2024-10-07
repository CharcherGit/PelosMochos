-- src/weapons.lua

local Bullet = require("src.bullet")

local Weapons = {}

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

function Weapons.createBullet(player, bulletPool, angle, bulletType)
    local bullet
    if #bulletPool > 0 then
        bullet = table.remove(bulletPool)
        bullet:reset(player.x, player.y, angle, player.damage, bulletType)
    else
        bullet = Bullet:new(player.x, player.y, angle, player.damage, bulletType)
    end
    return bullet
end

return Weapons