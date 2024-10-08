-- src/map.lua

local Utils = require("src.utils")
require "tiledmap"

local Map = {}
Map.__index = Map

function Map:new(mapPath)
    local this = {
        mapPath = mapPath,
        shadowLayer = {}  -- Nueva capa para almacenar objetos con sombras
    }
    setmetatable(this, Map)
    this:load()
    return this
end

function Map:load()
    TiledMap_Load(self.mapPath)
    self.width = gMapWidth
    self.height = gMapHeight
    self.tileWidth = gTileWidth
    self.tileHeight = gTileHeight
    self.pixelWidth = self.width * self.tileWidth
    self.pixelHeight = self.height * self.tileHeight
    
    self:loadShadowObjects()
    self:loadCollisionObjects()  -- Asegúrate de que esta línea esté presente
    
    print("Map dimensions:", self.width, self.height)
    print("Tile dimensions:", self.tileWidth, self.tileHeight)
    print("Pixel dimensions:", self.pixelWidth, self.pixelHeight)
end

function Map:loadShadowObjects()
    -- Iterar sobre las capas superiores a la capa 1
    for z = 2, #gMapLayers do
        for y = 1, self.height do
            for x = 1, self.width do
                local gid = TiledMap_GetMapTile(x, y, z)
                if gid ~= kMapTileTypeEmpty then
                    table.insert(self.shadowLayer, {
                        x = (x - 1) * self.tileWidth,
                        y = (y - 1) * self.tileHeight,
                        width = self.tileWidth,
                        height = self.tileHeight
                    })
                end
            end
        end
    end
end

function Map:loadCollisionObjects()
    self.collisionObjects = TiledMap_GetCollisionObjects()
    print("Loaded " .. #self.collisionObjects .. " collision objects")
end

function Map:draw()
    -- Dibujar la capa base (capa 1)
    TiledMap_DrawNearCam(1)
    
    -- Dibujar sombras
    love.graphics.setColor(0, 0, 0, 0.3)  -- Color de sombra semi-transparente
    for _, obj in ipairs(self.shadowLayer) do
        love.graphics.ellipse("fill", obj.x + obj.width/2, obj.y + obj.height, obj.width * 0.8, obj.height * 0.4)
    end
    love.graphics.setColor(1, 1, 1, 1)  -- Restaurar color
    
    -- Dibujar las capas superiores
    for z = 2, #gMapLayers do
        TiledMap_DrawNearCam(z)
    end
end

function Map:checkCollision(x, y, width, height)
    for _, obj in ipairs(self.collisionObjects) do
        if obj.type == "rectangle" then
            if x < obj.x + obj.width and
               x + width > obj.x and
               y < obj.y + obj.height and
               y + height > obj.y then
                return true  -- Colisión detectada
            end
        elseif obj.type == "ellipse" then
            local centerX = obj.x + obj.width / 2
            local centerY = obj.y + obj.height / 2
            local dx = math.abs(x + width / 2 - centerX)
            local dy = math.abs(y + height / 2 - centerY)
            if (dx / (obj.width / 2))^2 + (dy / (obj.height / 2))^2 <= 1 then
                return true  -- Colisión detectada
            end
        end
    end
    return false  -- No hay colisión
end

return Map