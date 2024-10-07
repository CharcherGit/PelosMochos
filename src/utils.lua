-- src/utils.lua

local Utils = {}

function Utils.distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

function Utils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

return Utils