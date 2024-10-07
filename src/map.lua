-- src/map.lua

local Utils = require("src.utils")
require "tiledmap"

local Map = {}
Map.__index = Map

function Map:new(mapPath)
    local this = {
        mapPath = mapPath
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
    
    print("Map dimensions:", self.width, self.height)
    print("Tile dimensions:", self.tileWidth, self.tileHeight)
    print("Pixel dimensions:", self.pixelWidth, self.pixelHeight)
end

function Map:draw(camX, camY)
    TiledMap_DrawNearCam(camX, camY)
end

return Map