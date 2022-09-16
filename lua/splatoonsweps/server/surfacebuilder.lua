
local ss = SplatoonSWEPs
if not ss then return end

ss.class "PaintableSurface" {
    Angles         = Angle(),
    Contents       = CONTENTS_EMPTY,
    Index          = 0,
    InkColorGrid   = {}, -- number[][]
    IsWaterSurface = false,
    Normal         = Vector(),
    Origin         = Vector(),
    Triangles      = {}, -- number[][3]
    Vertices2D     = {}, -- Vector[]
    Vertices3D     = {}, -- Vector[]
    ---
    maxs           = -ss.vector_one * math.huge,
    mins           =  ss.vector_one * math.huge,
    Boundary2D     =  ss.vector_one * math.huge,
}

-- Index to SURFEDGES array -> actual vertex
local function surfEdgeToVertex(index)
    local surfedge  = ss.BSP.Raw.SURFEDGES[index]
    local edge      = ss.BSP.Raw.EDGES    [math.abs(surfedge) + 1]
    local vertindex = edge[surfedge < 0 and 2 or 1]
    return ss.BSP.Raw.VERTEXES[vertindex + 1]
end
-- Minimizes AABB of given convex.
local function get2DComponents(surf)
    local desiredDir = nil
    local add90deg   = false
    local minarea    = math.huge
    local convex     = {}
    for i, v in ipairs(surf.Vertices3D) do
        convex[i] = ss.To2D(v, surf.Origin, surf.Angles)
    end

    for i = 1, #convex do
        local p0, p1 = convex[i], convex[i % #convex + 1]
        local dp = p1 - p0
        if dp:LengthSqr() > 0 then
            local dir  = dp:GetNormalized()

            -- Rotaion matrix
            local rx = Vector( dir.x, dir.y)
            local ry = Vector(-dir.y, dir.x)

            local xmax, xmin = -math.huge, math.huge
            local ymax, ymin = -math.huge, math.huge
            for _, v in ipairs(convex) do
                local x, y = v:Dot(rx), v:Dot(ry)
                xmin = math.min(xmin, x)
                ymin = math.min(ymin, y)
                xmax = math.max(xmax, x)
                ymax = math.max(ymax, y)
            end

            local xlength = xmax - xmin
            local ylength = ymax - ymin
            if minarea > xlength * ylength then
                desiredDir = dir
                add90deg = xlength < ylength
                minarea = xlength * ylength
            end
        end
    end

    -- Rotation matrix
    local rx = Vector( desiredDir.x, desiredDir.y)
    local ry = Vector(-desiredDir.y, desiredDir.x)

    --  cos(x)  sin(x)   +90deg    -sin(x)  cos(x)
    -- -sin(x)  cos(x)  -------->  -cos(x) -sin(x)
    if add90deg then rx, ry = ry, -rx end
    surf.Angles.roll = -math.deg(math.atan2(ry.x, rx.x))

    local mins = ss.vector_one * math.huge
    for _, v in ipairs(convex) do
        v.x, v.y = v:Dot(rx), v:Dot(ry)
        mins = ss.MinVector(mins, v)
    end

    surf.Origin = ss.To3D(mins, surf.Origin, surf.Angles)

    local mins2D, maxs2D
    for _, v in ipairs(convex) do
        v:Sub(mins)
        mins2D = ss.MinVector(mins2D or v, v)
        maxs2D = ss.MaxVector(maxs2D or v, v)
    end

    surf.Vertices2D = convex
    surf.Boundary2D = maxs2D - mins2D
end

local TextureFilterBits = bit.bor(
    SURF_SKY, SURF_NOPORTAL, SURF_TRIGGER,
    SURF_NODRAW, SURF_HINT, SURF_SKIP)
-- Construct a polygon from a raw face data
local function buildFace(faceindex, rawFace)
    -- Collect texture information and see if it's valid
    local rawTexInfo   = ss.BSP.Raw.TEXINFO
    local rawTexData   = ss.BSP.Raw.TEXDATA
    local rawTexDict   = ss.BSP.Raw.TEXDATA_STRING_TABLE
    local rawTexIndex  = ss.BSP.Raw.TexDataStringTableToIndex
    local rawTexString = ss.BSP.Raw.TEXDATA_STRING_DATA
    local texInfo      = rawTexInfo[rawFace.texInfo + 1]
    local texData      = rawTexData[texInfo.texData + 1]
    local texOffset    = rawTexDict[texData.nameStringTableID + 1]
    local texIndex     = rawTexIndex[texOffset]
    local texName      = rawTexString[texIndex]:lower()
    local texMaterial  = Material(texName)
    if bit.band(texInfo.flags, TextureFilterBits) ~= 0 then return end
    if texMaterial:GetString "$surfaceprop" == "metalgrate" then return end
    if texName:find "tools/" then return end

    -- Collect geometrical information
    local rawPlanes = ss.BSP.Raw.PLANES
    local plane     = rawPlanes[rawFace.planeNum + 1]
    local firstedge = rawFace.firstEdge + 1
    local lastedge  = rawFace.firstEdge + rawFace.numEdges
    local normal    = plane.normal

    -- Collect "raw" vertex list
    local rawVertices = {}
    for i = firstedge, lastedge do
        rawVertices[#rawVertices + 1] = surfEdgeToVertex(i)
    end

    -- Filter out colinear vertices and calculate the center
    -- This is also good time to calculate bounding box
    local filteredVertices = {}
    local vertexSum = Vector()
    local maxs, mins = nil, nil
    for i, current in ipairs(rawVertices) do
        local before = rawVertices[(#rawVertices + i - 2) % #rawVertices + 1]
        local after  = rawVertices[i % #rawVertices + 1]
        local cross  = (before - current):Cross(after - current)
        if normal:Dot(cross:GetNormalized()) > 0 then
            vertexSum:Add(current)
            filteredVertices[#filteredVertices + 1] = current
            maxs = ss.MaxVector(maxs or current, current)
            mins = ss.MinVector(mins or current, current)
        end
    end

    -- Check if it's valid to add to polygon list
    if #filteredVertices < 3 then return end
    local center = vertexSum / #filteredVertices
    local contents = util.PointContents(center - normal * 0.01)
    local isDisplacement = rawFace.dispInfo >= 0
    local isSolid = bit.band(contents, MASK_SOLID) > 0
    local isWater = texName:find "water"
    if not (isDisplacement or isSolid or isWater) then return end

    local surf = ss.class "PaintableSurface"
    surf.Angles         = normal:Angle()
    surf.Contents       = contents
    surf.IsWaterSurface = tobool(isWater)
    surf.maxs           = maxs
    surf.mins           = mins
    surf.Normal         = normal
    surf.Origin         = center
    surf.Vertices3D     = filteredVertices
    if not isDisplacement then
        if not isWater then get2DComponents(surf) end
        for i = 2, #filteredVertices - 1 do
            surf.Triangles[#surf.Triangles + 1] = { 1, i, i + 1 }
        end
        return surf
    end

    -- Collect displacement info
    local rawDispInfo     = ss.BSP.Raw.DISPINFO
    local rawDispVerts    = ss.BSP.Raw.DISP_VERTS
    local dispInfo        = rawDispInfo[rawFace.dispInfo + 1]
    local power           = 2 ^ dispInfo.power + 1
    local numMeshVertices = power ^ 2
    do
        -- dispInfo.startPosition isn't always equal to
        -- surf.Vertices3D[1] so find correct one and sort them
        local indices, mindist, startindex = {}, math.huge, 0
        for i, v in ipairs(surf.Vertices3D) do
            local dist = dispInfo.startPosition:DistToSqr(v)
            if dist < mindist then
                startindex, mindist = i, dist
            end
        end

        for i = 1, 4 do
            indices[i] = (i + startindex - 2) % 4 + 1
        end

        -- Sort them using index table
        surf.Vertices3D[1], surf.Vertices3D[2],
        surf.Vertices3D[3], surf.Vertices3D[4]
            = surf.Vertices3D[indices[1]], surf.Vertices3D[indices[2]],
              surf.Vertices3D[indices[3]], surf.Vertices3D[indices[4]]
    end

    --  ^ y
    --  |
    -- (4) -------- (3)
    --  |            |
    --  ^            ^
    -- v1           v2
    --  |            |
    -- (1) -u1->--- (2) --> x
    local u1 = surf.Vertices3D[4] - surf.Vertices3D[1]
    local v1 = surf.Vertices3D[2] - surf.Vertices3D[1]
    local v2 = surf.Vertices3D[3] - surf.Vertices3D[4]
    local triangles = {} -- Indices of triangle mesh
    local vertices  = {} -- List of vertices
    maxs, mins = nil, nil
    for i = 1, numMeshVertices do
        -- Calculate x-y offset
        local dispVert = rawDispVerts[dispInfo.dispVertStart + i]
        local xi, yi = (i - 1) % power, math.floor((i - 1) / power)
        local x,  y  = xi / (power - 1), yi / (power - 1)
        local origin = u1 * x + LerpVector(x, v1, v2) * y

        -- Calculate mesh vertex position
        local displacement = dispVert.vec * dispVert.dist
        local localPos     = origin   + displacement
        local worldPos     = dispInfo.startPosition + localPos
        vertices[#vertices + 1] = worldPos

        -- Modifies indices a bit to invert triangle orientation
        local invert = Either(i % 2 == 1, 1, 0)

        -- Generate triangle indices from displacement mesh
        if xi < power - 1 and yi < power - 1 then
            triangles[#triangles + 1],
            triangles[#triangles + 2]
                = { i + invert + power, i + 1,     i             },
                  { i - invert + 1,     i + power, i + power + 1 }
        end

        -- Set bounding box
        maxs = ss.MaxVector(maxs or worldPos, worldPos)
        mins = ss.MinVector(mins or worldPos, worldPos)
    end

    surf.maxs = maxs
    surf.mins = mins
    surf.Triangles = triangles
    surf.Vertices3D = vertices
    if not isWater then get2DComponents(surf) end
    return surf
end

--                    +
--                  //|
--                / / |
--              /  +  |
--            /   /   |
--          /    /  + |
--        / +  _+     |
--      /   _-    \   |
--    /  _+        +  |
--  / _-     +      \ |
-- +------------------+
-- Samples some points (indicated by plus signs above)
-- and sees if any part of given convex is explosed to the world.
function ss.IsConvexExposed(verts, normal)
    local issolid = true
    local center = Vector()
    for _, v in ipairs(verts) do center:Add(v) end
    center = center / #verts
    local sample_points = {center}
    for i = 1, #verts do
        local v1 = verts[i]
        local v2 = verts[i % #verts + 1]
        table.Add(sample_points, {
            center * ss.eps + v1 * (1 - ss.eps),
            center * 0.5 + v1 * 0.5,
            (center + v1 + v2) / 3,
        })
    end

    for _, v in ipairs(sample_points) do
        local c = util.PointContents(v + normal * ss.eps)
        issolid = issolid and bit.band(c, MASK_VISIBLE) > 0
        if not issolid then return true end
    end
end

local function buildStaticProp(prop)
    local name = ss.BSP.Raw.sprp.name[prop.propType]
    if prop.solid ~= SOLID_VPHYSICS then return end
    if not name then return end
    if not file.Exists(name, "GAME") then return end
    if not file.Exists(name:sub(1, -4) .. "phy", "GAME") then return end

    local mdl = ents.Create "prop_physics"
    if not IsValid(mdl) then return end
    mdl:SetModel(name)
    mdl:Spawn()
    local ph = mdl:GetPhysicsObject()
    local mat = IsValid(ph) and ph:GetMaterial()
    mdl:Remove()

    if not IsValid(ph) then return end
    if mat:find "chain" or mat:find "grate" then return end

    local surfaces = {}
    for _, t in ipairs(ph:GetMeshConvexes()) do
        for _, surf in ipairs(ss.ProcessStaticPropConvex(
            prop.origin, prop.angle, ph:GetContents(), t)) do
            if #surf.Vertices3D < 3 then continue end
            surfaces[#surfaces + 1] = surf
        end
    end

    return surfaces
end

local MIN_NORMAL_LENGTH_SQR = 1
local PROJECTION_NORMALS = {
    Vector( 1,  0,  0),
    Vector( 0,  1,  0),
    Vector( 0,  0,  1),
    Vector(-1,  0,  0),
    Vector( 0, -1,  0),
    Vector( 0,  0, -1),
}
function ss.ProcessStaticPropConvex(origin, angle, contents, phys)
    local surfaces = {}
    local maxs_all = {}
    local mins_all = {}
    for _, n in ipairs(PROJECTION_NORMALS) do
        surfaces[tostring(n)] = ss.class "PaintableSurface"
        maxs_all[tostring(n)] = ss.vector_one * -math.huge
        mins_all[tostring(n)] = ss.vector_one * math.huge
    end

    for i = 1, #phys, 3 do
        local v1 = phys[i].pos
        local v2 = phys[i + 1].pos
        local v3 = phys[i + 2].pos
        local v2v1 = v1 - v2
        local v2v3 = v3 - v2
        local n = v2v1:Cross(v2v3) -- normal around v1<-v2->v3
        if n:LengthSqr() < MIN_NORMAL_LENGTH_SQR then continue end -- normal is valid then
        n:Normalize()

        if not ss.IsConvexExposed({ v1, v2, v3 }, n) then continue end

        -- Find proper plane for projection
        local plane_index, max_dot = 1, -1
        for k, pn in ipairs(PROJECTION_NORMALS) do
            local dot = n:Dot(pn)
            if dot > max_dot then
                plane_index = k
                max_dot = dot
            end
        end

        local pn = PROJECTION_NORMALS[plane_index]
        v1 = LocalToWorld(v1, angle_zero, origin, angle)
        v2 = LocalToWorld(v2, angle_zero, origin, angle)
        v3 = LocalToWorld(v3, angle_zero, origin, angle)
        n = LocalToWorld(n, angle_zero, vector_origin, angle)
        maxs_all[tostring(pn)] = ss.MaxVector(maxs_all[tostring(pn)], v1)
        maxs_all[tostring(pn)] = ss.MaxVector(maxs_all[tostring(pn)], v2)
        maxs_all[tostring(pn)] = ss.MaxVector(maxs_all[tostring(pn)], v3)
        mins_all[tostring(pn)] = ss.MinVector(mins_all[tostring(pn)], v1)
        mins_all[tostring(pn)] = ss.MinVector(mins_all[tostring(pn)], v2)
        mins_all[tostring(pn)] = ss.MinVector(mins_all[tostring(pn)], v3)

        local surf = surfaces[tostring(pn)]
        surf.Angles = pn:Angle()
        surf.Contents = contents
        surf.Normal = pn
        surf.Origin:Add(v1 + v2 + v3)
        table.Add(surf.Triangles, {
            #surf.Triangles + 1,
            #surf.Triangles + 2,
            #surf.Triangles + 3
        })
        table.Add(surf.Vertices3D, { v1, v2, v3 })
    end

    for _, n in ipairs(PROJECTION_NORMALS) do
        local surf = surfaces[tostring(n)]
        if #surf.Vertices3D < 3 then continue end
        surf.Origin:Div(#surf.Vertices3D)
        surf.maxs = maxs_all[tostring(n)]
        surf.mins = mins_all[tostring(n)]
        get2DComponents(surf)
    end

    return surfaces
end

local function addSurface(surf)
    if not surf then return end
    if surf.IsWaterSurface then
        surf.Index = #ss.WaterSurfaces + 1
        ss.WaterSurfaces[#ss.WaterSurfaces + 1] = surf
    else
        surf.Index = #ss.SurfaceArray + 1
        ss.SurfaceArray[#ss.SurfaceArray + 1] = surf
    end
end

function ss.GenerateSurfaces()
    ss.SurfaceArray = {}
    ss.WaterSurfaces = {}
    for i, face in ipairs(ss.BSP.Raw.FACES) do
        addSurface(buildFace(i, face))
    end

    for _, prop in ipairs(ss.BSP.Raw.sprp.prop or {}) do
        for _, surf in ipairs(buildStaticProp(prop) or {}) do
            addSurface(surf)
        end
    end

    ss.BSP.Polygons = t
end
