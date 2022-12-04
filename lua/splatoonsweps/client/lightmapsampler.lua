
local ss = SplatoonSWEPs
if not ss then return end

function ss.PrecacheLightmap()
    local path = string.format("maps/%s.bsp", game.GetMap())
    local bsp = file.Open(path, "rb", "GAME")
    if not bsp then return end

    util.TimerCycle()
    local header = ss.ReadHeader(bsp)
    local entities = ss.ReadLump(bsp, header.lumps, "ENTITIES")[1]
    local lighting = ss.ReadLump(bsp, header.lumps, "LIGHTING")
    bsp:Close()

    local brightness_max = 500
    local amb = render.GetAmbientLightColor():ToColor()
    for ent in entities:gmatch "{\n.-\n}" do
        local t = util.KeyValuesToTable("@" .. ent)
        if t.classname == "light_environment" then
            brightness_max = tonumber(t._light:Split " "[4])
            break
        end
    end

    brightness_max = brightness_max * 0.5
    print(brightness_max)
    local gamma_recip = 1 / 2.2
    local rgb_mul = 255^(-gamma_recip - 1)
    local overbrightFactor = brightness_max * rgb_mul
    local function GetRGB(r, g, b, e)
        if e > 127 then e = e - 256 end
        local mul = 2^(e * gamma_recip) * overbrightFactor
        local vrgb = Vector(
            math.min(r ^ gamma_recip * mul, 1),
            math.min(g ^ gamma_recip * mul, 1),
            math.min(b ^ gamma_recip * mul, 1))
        local max_comp_recip = math.max(vrgb.x, vrgb.y, vrgb.z)
        if max_comp_recip > 1 then vrgb:Mul(1 / max_comp_recip) end
        return vrgb:ToColor()
    end

    draw.NoTexture()
    render.PushRenderTarget(ss.RenderTarget.Lightmap)
    render.ClearDepth()
    render.ClearStencil()
    render.Clear(amb.r, amb.g, amb.b, 255)
    cam.Start2D()
    for _, surf in ipairs(ss.SurfaceArray) do
        local li = surf.LightmapInfo
        if not li.Available then continue end
        local e11 = li.BasisS
        local e12 = -li.BasisT -- I don't know why I must negate this basis but it works
        local e13 = e11:Cross(e12)
        local lightmapOffset = li.MinsInLuxels - li.Offset
        local lightmapToWorld = Matrix()
        lightmapToWorld:SetForward(e11)
        lightmapToWorld:SetRight(e12)
        lightmapToWorld:SetUp(e13)
        lightmapToWorld:Invert()

        -- This is identical to lightmapToWorld = lightmapToWorld:GetTransposed() unless it's broken.
        local lightmapToWorldElements = lightmapToWorld:ToTable()
        lightmapToWorldElements[1][2], lightmapToWorldElements[2][1] = lightmapToWorldElements[2][1], lightmapToWorldElements[1][2]
        lightmapToWorldElements[1][3], lightmapToWorldElements[3][1] = lightmapToWorldElements[3][1], lightmapToWorldElements[1][3]
        lightmapToWorldElements[2][3], lightmapToWorldElements[3][2] = lightmapToWorldElements[3][2], lightmapToWorldElements[2][3]
        lightmapToWorld = Matrix(lightmapToWorldElements)

        local e21 = surf.AnglesUV:Forward()
        local e22 = surf.AnglesUV:Right()
        local e23 = surf.AnglesUV:Up()
        local worldToUV = Matrix()
        worldToUV:SetForward(e21)
        worldToUV:SetRight(e22)
        worldToUV:SetUp(e23)
        worldToUV:SetTranslation(surf.OriginUV)
        worldToUV:Invert()

        local lightmapScale = lightmapToWorld:GetScale() -- Luxel -> Hammer units
        local w = lightmapScale.x * ss.UnitsToPixels
        local h = lightmapScale.y * ss.UnitsToPixels
        local uvstart = surf.OffsetUV * ss.UVToPixels
        local uvbound = surf.BoundaryUV * ss.UVToPixels
        local uvend   = uvstart + uvbound

        uvstart = Vector(math.floor(uvstart.x) - 1, math.floor(uvstart.y) - 1)
        uvend   = Vector(math.ceil(uvend.x)    + 1, math.ceil(uvend.y)    + 1)

        local lightmapOrigin = worldToUV * lightmapToWorld * lightmapOffset
        local lightmapDirection = worldToUV * lightmapToWorld * (Vector(1, 0) + lightmapOffset) - lightmapOrigin
        local rotation = math.deg(math.acos(lightmapDirection:GetNormalized().y))
        render.SetScissorRect(uvstart.x, uvstart.y, uvend.x, uvend.y, true)
        for t = 0, li.SizeInLuxels.y do
            for s = 0, li.SizeInLuxels.x do
                local sample = lighting[s + t * (li.SizeInLuxels.x + 1) + 1 + li.SampleOffset / 4] or 0
                local r = bit.band(bit.rshift(sample, 0),  0xFF)
                local g = bit.band(bit.rshift(sample, 8),  0xFF)
                local b = bit.band(bit.rshift(sample, 16), 0xFF)
                local e = bit.band(bit.rshift(sample, 24), 0xFF)
                local c = GetRGB(r, g, b, e)
                local p = worldToUV * lightmapToWorld * (Vector(s, t) + lightmapOffset)
                p = Vector(p.y, p.z) * ss.UnitsToPixels + uvstart
                surface.SetDrawColor(c)
                surface.DrawTexturedRectRotated(p.x, p.y, w + 1, h + 1, rotation)
            end
        end
        render.SetScissorRect(0, 0, 0, 0, false)
    end
    cam.End2D()
    render.PopRenderTarget()
    print(util.TimerCycle())
end
