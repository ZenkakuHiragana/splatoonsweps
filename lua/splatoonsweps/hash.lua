
local ss = SplatoonSWEPs
if not ss then return end

-- Spatial hashing for better query performance of surfaces

local dot = Vector().Dot
local floor = math.floor
local ipairs = ipairs
local wrap = coroutine.wrap
local yield = coroutine.yield
local vector_one = ss.vector_one
local vector_tenth = vector_one * 0.1
local vector_16384 = vector_one * 16384
local GRID_SIZE = 128
local MAX_COS_DIFF = ss.MAX_COS_DIFF
local MAX_GRID_INDEX = 32768 / GRID_SIZE
local MAX_GRID_INDEX_SQR = MAX_GRID_INDEX * MAX_GRID_INDEX
local function posToGrid(pos)
    pos = (pos + vector_16384) / GRID_SIZE
    return floor(pos.x), floor(pos.y), floor(pos.z)
end

local function gridToHash(x, y, z)
    return x + y * MAX_GRID_INDEX + z * MAX_GRID_INDEX_SQR
end

local function hashpairs(mins, maxs)
    local x0, y0, z0 = posToGrid(mins)
    local x1, y1, z1 = posToGrid(maxs)
    return wrap(function()
        for z = z0, z1 do
            for y = y0, y1 do
                for x = x0, x1 do
                    -- local gmin = Vector(x, y, z) * GRID_SIZE - vector_16384
                    -- local gmax = gmin + vector_one * GRID_SIZE
                    -- debugoverlay.Box(Vector(), gmin, gmax, FrameTime() * 20, Color(0, 255, 0, 16))
                    yield(gridToHash(x, y, z))
                end
            end
        end
    end)
end

function ss.GenerateHashTable()
    -- A hash table to represent grid
    -- = { [hash] = { i1, i2, i3, ... }, ... }
    ss.SurfaceHash = {}
    for i, s in ipairs(ss.SurfaceArray) do
        for h in hashpairs(s.mins, s.maxs) do
            ss.SurfaceHash[h] = ss.SurfaceHash[h] or {}
            ss.SurfaceHash[h][#ss.SurfaceHash[h] + 1] = i
        end
    end
end

function ss.CollectSurfaces(mins, maxs, normal)
    return wrap(function()
        for h in hashpairs(mins - vector_tenth, maxs + vector_tenth) do
            for _, i in ipairs(ss.SurfaceHash and ss.SurfaceHash[h] or {}) do
                local s = ss.SurfaceArray[i]
                if s.IsSmallProp or dot(s.Normal, normal) > MAX_COS_DIFF then yield(s) end
            end
        end
    end)
end

function ss.GetGridBBox(pos)
    local mins = Vector(posToGrid(pos)) * GRID_SIZE - vector_16384
    local maxs = mins + vector_one * GRID_SIZE
    return mins, maxs
end
