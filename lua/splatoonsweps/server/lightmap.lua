
local ss = SplatoonSWEPs
if not ss then return end

local ipairs = ipairs
local marginInLuxels = 1
local function getLightmapBounds()
    local out = {}
    for _, surf in ipairs(ss.SurfaceArray) do
        local li = surf.LightmapInfo
        if not li.Available then continue end
        if li.SampleOffset < 0 then continue end
        local width = li.SizeInLuxels.x + 1 + marginInLuxels * 2
        local height = li.SizeInLuxels.y + 1 + marginInLuxels * 2
        out[#out + 1] = ss.MakeRectangle(width, height, 0, 0, surf)
    end

    return out
end

local ceil  = math.ceil
local clamp = math.Clamp
local floor = math.floor
local pow   = math.pow
local round = math.Round
local sqrt  = math.sqrt
local function getLightmapSampleIndex(x, y, w, h, offset)
    x = clamp(x, 1, w) - 1
    y = clamp(y, 1, h) - 1
    return (x + y * w) * 4 + (offset or 0) + 1
end

local IDAT_SIZE_LIMIT = 8192
local ZLIB_SIZE_LIMIT = 65535
local NUM_CHANNELS = 4
local BYTES_PER_CHANNEL = 2
local BYTES_PER_PX = BYTES_PER_CHANNEL * NUM_CHANNELS
local BIT_DEPTH   = BYTES_PER_CHANNEL == 1 and "\x08" or "\x10"
local CHANNEL_MAX = BYTES_PER_CHANNEL == 1 and 255    or 65535

-- ColorRGBExp32 to sRGB
-- According to Source SDK, conversion steps are as follows:
-- 0. Let x be either r, g, or b
-- 1. Convert x to linear scale luminance
--    x' = (x / 255) * 2^exp
-- 2. Apply gamma correction and overBrightFactor = 0.5
--    x" = (x' ^ (1 / 2.2)) * 0.5
-- 3. Assume x" ranges from 0 to 1 and scale it, then clamp it
--    y' = x" * 65535
--    y  = clamp(y', 0, 65535)
-- In these steps, 2^exp is likely to be very small so precision loss is a concern.
-- I put the following assumption and try to reduce the precision loss.
--    x' = (x / 255) * 2^exp ~ (x / 256) * 2^exp = x * 2 ^ (exp - 8)
--    y' = x" * 65535 ~ x" * 65536 = x" * 2^16
-- Then I could do the following transform:
--    x" = (x * 2 ^ (exp - 8)) ^ (1 / 2.2) * 2^(-1)
--       =  x ^ (1 / 2.2) * 2 ^ ((exp - 8) / 2.2) * 2^(-1)
--    y' =  x ^ (1 / 2.2) * 2 ^ ((exp - 8) / 2.2) * 2^(-1) * 2^16
--       =  x ^ (1 / 2.2) * 2 ^ ((exp - 8 + 15 * 2.2) / 2.2)
--       = (x * 2 ^ (exp - 8 + 15 * 2.2)) ^ (1 / 2.2)
local gammaInv, expConst = 1 / 2.2, -8 + 15 * 2.2
local function getRGB(r, g, b, exp)
    if exp > 127 then exp = exp - 256 end
    return clamp(round(pow(r * pow(2, exp + expConst), gammaInv)), 0, CHANNEL_MAX),
           clamp(round(pow(g * pow(2, exp + expConst), gammaInv)), 0, CHANNEL_MAX),
           clamp(round(pow(b * pow(2, exp + expConst), gammaInv)), 0, CHANNEL_MAX)
end
local function writeLightmap(bitmap, pngsize, rect, surf, samples)
    local li = surf.LightmapInfo
    local x0, y0 = rect.left, rect.bottom
    local sw = li.SizeInLuxels.x + 1
    local sh = li.SizeInLuxels.y + 1
    local sampleOffset = li.SampleOffset
    local bitmapOffset = x0 + y0 * pngsize
    for y = 1, rect.height do
        for x = 1, rect.width do
            local sx, sy = x - marginInLuxels, y - marginInLuxels
            if rect.istall == (sw > sh) then sx, sy = sy, sx end
            local sampleIndex = getLightmapSampleIndex(sx, sy, sw, sh, sampleOffset)
            local r, g, b = getRGB(samples:byte(sampleIndex, sampleIndex + 3))
            local bitmapIndex = (bitmapOffset + x - 1 + (y - 1) * pngsize) * NUM_CHANNELS
            bitmap[bitmapIndex + 1] = r
            bitmap[bitmapIndex + 2] = g
            bitmap[bitmapIndex + 3] = b
            if NUM_CHANNELS == 4 then
                bitmap[bitmapIndex + 4] = CHANNEL_MAX
            end
        end
    end
end

local band     = bit.band
local bor      = bit.bor
local bnot     = bit.bnot
local lshift   = bit.lshift
local rshift   = bit.rshift
local byte     = string.byte
local char     = string.char
local gmatch   = string.gmatch
local sub      = string.sub
local tonumber = tonumber
local utilcrc  = util.CRC
local function encode(width, height, data)
    local function i16(n)
        return char(
            band(0xFF, rshift(n, 8)),
            band(0xFF, rshift(n, 0)))
    end
    local function i32(n)
        return char(
            band(0xFF, rshift(n, 24)),
            band(0xFF, rshift(n, 16)),
            band(0xFF, rshift(n, 8)),
            band(0xFF, rshift(n, 0)))
    end
    local function adler(str, previous)
        local s1 = band  (previous or 1, 0xFFFF)
        local s2 = rshift(previous or 1, 16)
        for c in gmatch(str, ".") do
            s1 = (s1 + byte(c)) % 65521
            s2 = (s2 + s1) % 65521
        end
        return bor(lshift(s2, 16), s1)
    end
    local function crc(name, str)
        return i32(tonumber(utilcrc(name .. str)) or 0)
    end
    local function makeIDAT(chunk)
        assert(#chunk <= IDAT_SIZE_LIMIT)
        return i32(#chunk) .. "IDAT" .. chunk .. crc("IDAT", chunk)
    end
    local function deflateHeader(length, islast)
        local low    = band(0xFF, rshift(length, 0))
        local high   = band(0xFF, rshift(length, 8))
        local nlow   = band(0xFF, bnot(low))
        local nhigh  = band(0xFF, bnot(high))
        local len    = char(low, high)
        local nlen   = char(nlow, nhigh)
        local header = islast and "\x01" or "\x00"
        return header .. len .. nlen
    end

    local rawPixelDataSize = width * height * BYTES_PER_PX + height
    local numDeflateBlocks = ceil(rawPixelDataSize / ZLIB_SIZE_LIMIT)

    local idats = ""
    local blockCount = 1
    local deflateAdler32 = 1
    local deflateWritten = 0
    local deflateSize = numDeflateBlocks == 1 and rawPixelDataSize or ZLIB_SIZE_LIMIT
    local deflateBuffer = "\x78\x01" .. deflateHeader(deflateSize, numDeflateBlocks == 1)
    local function addDeflateBuffer(buf)
        if #buf < IDAT_SIZE_LIMIT then return buf end
        idats = idats .. makeIDAT(sub(buf, 1, IDAT_SIZE_LIMIT))
        return sub(buf, IDAT_SIZE_LIMIT + 1)
    end
    local function addPixelData(buf)
        if deflateWritten + #buf > deflateSize then
            blockCount = blockCount + 1
            local split = sub(buf, 1, deflateSize - deflateWritten)
            local rest = sub(buf, deflateSize - deflateWritten + 1)
            local islast = blockCount >= numDeflateBlocks

            deflateSize = islast and rawPixelDataSize % ZLIB_SIZE_LIMIT or ZLIB_SIZE_LIMIT
            local add = split .. deflateHeader(deflateSize, islast) .. rest

            deflateBuffer = addDeflateBuffer(deflateBuffer .. add)
            deflateWritten = #rest
        else
            deflateBuffer = addDeflateBuffer(deflateBuffer .. buf)
            deflateWritten = deflateWritten + #buf
        end
        deflateAdler32 = adler(buf, deflateAdler32)
    end

    for i = 1, width * height * NUM_CHANNELS do
        if i % (width * NUM_CHANNELS) == 1 then addPixelData "\x00" end
        addPixelData(BYTES_PER_CHANNEL == 1 and char(data[i] or 255) or i16(data[i] or 65535))
    end

    deflateBuffer = addDeflateBuffer(deflateBuffer .. i32(deflateAdler32))
    idats = idats .. makeIDAT(deflateBuffer)
    local ihdr = i32(width) .. i32(height) .. BIT_DEPTH .. "\x06\x00\x00\x00"
    return "\x89PNG\x0D\x0A\x1A\x0A\x00\x00\x00\x0DIHDR"
        .. ihdr .. crc("IHDR", ihdr) .. idats
        .. "\x00\x00\x00\x00IEND\xAE\x42\x60\x82"
end

function ss.BuildLightmap()
    for _, entities in ipairs(ss.BSP.Raw.ENTITIES) do
        for k in entities:gmatch "{[^}]+}" do
            local t = util.KeyValuesToTable("\"\" " .. k)
            if t.classname == "light_environment" then
                local lightColor    = t._light:Split " "
                local lightColorHDR = t._lighthdr:Split " "
                local lightScaleHDR = t._lightscalehdr
                for i = 1, 4 do
                    lightColor[i]    = tonumber(lightColor[i])
                    lightColorHDR[i] = tonumber(lightColorHDR[i])
                    if lightColorHDR[i] and lightColorHDR[i] < 0 then
                        lightColorHDR[i] = lightColor[i]
                    end
                end
                ss.LightingScales = {
                    lightColor    = lightColor,
                    lightColorHDR = lightColorHDR,
                    lightScaleHDR = tonumber(lightScaleHDR) or 1,
                }
                break
            end
        end
    end

    local samples = ss.BSP.Raw.LIGHTING
    if not samples then return end
    local rects = getLightmapBounds()
    if #rects == 0 then return end

    local packer = ss.MakeRectanglePacker(rects):packall()
    local pngsize = packer.maxsize

    local bitmap = {}
    for _, index in ipairs(packer.results) do
        local rect = packer.rects[index]
        local surf = rect.tag
        writeLightmap(bitmap, pngsize, rect, surf, samples)

        local li = surf.LightmapInfo
        local uv = li.Vertices2D
        local s0, t0 = rect.left + 1, rect.bottom + 1
        local sw = li.SizeInLuxels.x + 1
        local sh = li.SizeInLuxels.y + 1
        if surf.IsDisplacement then
            local sideLength = sqrt(#surf.Vertices3D)
            local divisor = sideLength - 1
            for i = 0, #surf.Vertices3D - 1 do
                local s =       i % sideLength  / divisor * sw
                local t = floor(i / sideLength) / divisor * sh
                if rect.istall == (sw > sh) then s, t = t, s end
                uv[i + 1] = Vector(s + s0, t + t0) / pngsize
            end
        else
            for i, v in ipairs(surf.Vertices3D) do
                local s = li.BasisS:Dot(v) + li.Offset.x - li.MinsInLuxels.x
                local t = li.BasisT:Dot(v) + li.Offset.y - li.MinsInLuxels.y
                if rect.istall == (sw > sh) then s, t = t, s end
                uv[i] = Vector(s + s0 + 1, t + t0 + 1) / pngsize
            end
        end
    end

    print "done"
    file.Write(string.format("splatoonsweps/%s.png", game.GetMap()), encode(pngsize, pngsize, bitmap))
end
