
local ss = SplatoonSWEPs
if not ss then return end

-- A wrapper function for hooks.  The func will run only if the player is inkling.
function ss.hook(func)
    if isstring(func) then
        return function(ply, ...)
            local w = ss.IsValidInkling(ply or CLIENT and LocalPlayer() or nil)
            if w then return ss[func](w, ply, ...) end
        end
    else
        return function(ply, ...)
            local w = ss.IsValidInkling(ply or CLIENT and LocalPlayer() or nil)
            if w then return func(w, ply, ...) end
        end
    end
end

-- Faster table.remove() function from stack overflow
-- https://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating
-- tableremovefunc takes a function to remove elements.
-- Returning true in the function to remove.
function ss.tableremovefunc(t, toremove)
    local k = 1
    for i = 1, #t do
        if toremove(t[i]) then
            t[i] = nil
        else -- Move i's kept value to k's position, if it's not already there.
            if i ~= k then t[k], t[i] = t[i] end
            k = k + 1 -- Increment position of where we'll place the next kept value.
        end
    end

    return t
end

-- tableremove takes a number to remove element.
function ss.tableremove(t, removal)
    local k = 1
    for i = 1, #t do
        if i == removal then
            t[i] = nil
        else -- Move i's kept value to k's position, if it's not already there.
            if i ~= k then t[k], t[i] = t[i] end
            k = k + 1 -- Increment position of where we'll place the next kept value.
        end
    end

    return t
end

-- Even faster than table.remove() and this removes the first element.
function ss.tablepop(t)
    local zero, one = t[0], t[1]
    for i = 1, #t do
        t[i - 1], t[i] = t[i]
    end

    t[0] = zero
    return one
end

-- Faster than table.insert() and this inserts an element at the beginning.
function ss.tablepush(t, v)
    local n = #t
    for i = n, 1, -1 do
        t[i + 1], t[i] = t[i]
    end

    t[1] = v
end

-- There is an annoying limitation on util.JSONToTable(),
-- which is that the amount of a table is up to 15000.
-- Therefore, GMOD can't save/restore a table if #source > 15000.
-- This function sanitises a table with a large amount of data.
-- Argument:
--   table source | A table containing a large amount of data.
-- Returning:
--   table        | A nested table.  Each element has up to 15000 data.
function ss.SanitizeJSONLimit(source)
    local s = {}
    for chunk = 1, math.ceil(#source / 15000) do
        local t = {}
        for i = 1, 15000 do
            local index = (chunk - 1) * 15000 + i
            local value = source[index]
            if index > #source then break end
            if istable(value) and getmetatable(value) and getmetatable(value).__class then
                value = -value
            end

            t[#t + 1] = value
        end

        s[chunk] = t
    end

    return s
end

-- Restores a table saved with ss.SanitizeJSONLimit().
-- Argument:
--   table source | A nested table made by ss.SanitizeJSONLimit().
-- Returning:
--   table        | A sequential table.
function ss.DesanitizeJSONLimit(source)
    local s = {}
    for _, chunk in ipairs(source) do
        for _, v in ipairs(chunk) do s[#s + 1] = v end
    end

    return s
end

-- Compares each component and returns the smaller one.
-- Arguments:
--   Vector a, b | Two vectors to compare.
-- Returning:
--   Vector      | A vector which contains the smaller components.
function ss.MinVector(a, b)
    return Vector(math.min(a.x, b.x), math.min(a.y, b.y), math.min(a.z, b.z))
end

-- Compares each component and returns the larger one.
-- Arguments:
--   Vector a, b | Two vectors to compare.
-- Returning:
--   Vector      | A vector which contains the larger components.
function ss.MaxVector(a, b)
    return Vector(math.max(a.x, b.x), math.max(a.y, b.y), math.max(a.z, b.z))
end

-- Takes two AABBs and returns if they are colliding each other.
-- Arguments:
--   Vector mins1, maxs1 | The first AABB.
--   Vector mins2, maxs2 | The second AABB.
-- Returning:
--   bool                | Whether or not the two AABBs intersect each other.
function ss.CollisionAABB(mins1, maxs1, mins2, maxs2)
    return mins1.x < maxs2.x and maxs1.x > mins2.x and
            mins1.y < maxs2.y and maxs1.y > mins2.y and
            mins1.z < maxs2.z and maxs1.z > mins2.z
end

-- Basically same as SplatoonSWEPs:CollisionAABB(), but ignores Z-component.
-- Arguments:
--   Vector mins1, maxs1 | The first AABB.
--   Vector mins2, maxs2 | The second AABB.
-- Returning:
--   bool                | Whether or not the two AABBs intersect each other.
function ss.CollisionAABB2D(mins1, maxs1, mins2, maxs2)
    return mins1.x < maxs2.x and maxs1.x > mins2.x and
            mins1.y < maxs2.y and maxs1.y > mins2.y
end

-- Short for WorldToLocal()
-- Arguments:
--   Vector source | A 3D vector to be converted into 2D space.
--   Vector orgpos | The origin of new 2D system.
--   Angle  organg | The angle of new 2D system.
-- Returning:
--   Vector        | A converted 2D vector.
function ss.To2D(source, orgpos, organg)
    local localpos = WorldToLocal(source, angle_zero, orgpos, organg)
    return Vector(localpos.y, localpos.z, 0)
end

-- Short for LocalToWorld()
-- Arguments:
--   Vector source | A 2D vector to be converted into 3D space.
--   Vector orgpos | The origin of 2D system in world coordinates.
--   Angle organg  | The angle of 2D system relative to the world.
-- Returning:
--   Vector        | A converted 3D vector.
function ss.To3D(source, orgpos, organg)
    local localpos = Vector(0, source.x, source.y)
    return LocalToWorld(localpos, angle_zero, orgpos, organg)
end

-- Returns true if two numbers are close to equal.
-- Arguments:
--   number a, b | Numbers to compare.
-- Returning:
--   bool        | Mostly like a == b.
function ss.IsClose(a, b)
    return math.abs(a - b) <= ss.eps * math.max(1, math.abs(a), math.abs(b))
end

-- util.IsInWorld() only exists in serverside.
-- This is shared version of it.
-- Argument:
--   Vector pos | A vector to test.
-- Returning:
--   bool       | The given vector is in world or not.
function ss.IsInWorld(pos)
    return not util.TraceLine {
        start = pos,
        endpos = pos,
        collisiongroup = COLLISION_GROUP_WORLD,
    }.HitWorld
end

-- For Charger's interpolation.
-- Arguments:
--   number frac | Fraction.
--   number min  | Minimum value.
--   number max  | Maximum value.
--   number full | An optional value returned when frac == 1.
-- Returning:
--   number      | Interpolated value.
function ss.Lerp3(frac, min, max, full)
    return frac < 1 and Lerp(frac, min, max) or full or max
end

-- Get either -1 or +1.
-- Argument:
--   string seed | The random seed used by util.SharedRandom(), which can be nil.
-- Returning:
--   number sign | Either -1 or +1.
function ss.RandomSign(seed)
    local rand = seed and util.SharedRandom(seed, 0, 1, CurTime()) or math.random()
    return math.Round(rand) * 2 - 1
end

-- Generates a biased random value ranges from 0 to 1, used by weapon spread.
-- Arguments:
--   number bias | How much the bias is.
--                 0 makes it always return 0.
--                 0.5 means non-biased.
--                 1 makes it return either 1 or -1.
--   string seed | The random seed used by util.SharedRandom(), which can be nil.
function ss.GetBiasedRandom(bias, seed)
    local sign = ss.RandomSign(seed)
    local selectrand = seed and util.SharedRandom(seed, 0, 1, CurTime() * 2) or math.random()
    local select = bias > selectrand
    local fracmin = select and bias or 0
    local fracmax = select and 1    or bias
    local frac = seed and util.SharedRandom(seed, fracmin, fracmax, CurTime() * 3) or math.Rand(fracmin, fracmax)
    return sign * frac
end

-- Short for checking isfunction()
-- Arguments:
--   function func | The function to call safely.
--   vararg        | The arguments to give the function.
-- Returning:
--   vararg        | Returning values from the function.
function ss.ProtectedCall(func, ...)
    if isfunction(func) then return func(...) end
end

-- Modify the source table with given units
-- Arguments:
--   table source | The parameter table = {[string ParameterName] = [number Value]}
--   table units  | The table which describes what units each parameter should have {[string ParameterName] = [string Unit]}
function ss.ConvertUnits(source, units)
    for name, value in pairs(source) do
        if isnumber(value) then
            local unit = units[name]
            local converter = unit and ss.UnitsConverter[unit] or 1
            source[name] = value * converter
        end
    end
end

-- Get player timescale.
-- Argument:
--   Entity ply    | If given, it returns player's local timescale instead.
-- Returning:
--   number scale  | The game timescale.
local HostTimeScale = GetConVar "host_timescale"
function ss.GetTimeScale(ply)
    if IsValid(ply) and ply:IsPlayer() then
        return ply:GetLaggedMovementValue()
    else
        return game.GetTimeScale() * HostTimeScale:GetFloat()
    end
end

-- Checks if the given entity is a valid inkling (if it has a SplatoonSWEPs weapon).
-- Argument:
--   Entity ply | The entity to be checked.  It is not always player.
-- Returning:
--   Entity     | The weapon the entity has.
--   nil        | The entity is not an inkling.
function ss.IsValidInkling(ply)
    if not IsValid(ply) then return end
    local w = ss.ProtectedCall(ply.GetActiveWeapon, ply)
    return IsValid(w) and w.IsSplatoonWeapon and not w:GetHolstering() and w or nil
end

-- Checks if the given two colors are the same, considering FF setting.
-- Arguments:
--   number c1, c2 | The colors to be compared.  Can also be Splatoon weapons.
-- Returning:
--   bool          | The colors are the same.
function ss.IsAlly(c1, c2)
    if isentity(c1) and IsValid(c1) and isentity(c2) and IsValid(c2) and c1 == c2 then
        return not ss.GetOption "hurtowner"
    end

    c1 = isentity(c1) and IsValid(c1) and c1:GetNWInt "inkcolor" or c1
    c2 = isentity(c2) and IsValid(c2) and c2:GetNWInt "inkcolor" or c2
    return not ss.GetOption "ff" and c1 == c2
end

-- Play a sound that only can be heard by one player.
-- Arguments:
--   Player ply       | The player who can hear it.  Can be a table of players serverside.
--   string soundName | The sound to play.
function ss.EmitSound(ply, soundName, soundLevel, pitchPercent, volume, channel)
    if not (istable(ply) or IsValid(ply) and ply:IsPlayer()) then return end
    if SERVER and ss.mp then
        net.Start "SplatoonSWEPs: Send a sound"
        net.WriteString(soundName)
        net.WriteUInt(soundLevel or 75, 9)
        net.WriteUInt(pitchPercent or 100, 8)
        net.WriteFloat(volume or 1)
        net.WriteUInt((channel or CHAN_AUTO) + 1, 8)
        net.Send(ply)
    elseif not istable(ply) and (CLIENT and IsFirstTimePredicted() or ss.sp) then
        ply:EmitSound(soundName, soundLevel, pitchPercent, volume, channel)
    end
end

-- Play a sound properly in a weapon predicted hook.
-- Arguments:
--   Player ply | The owner of the weapon.
--   Entity ent | The weapon.
--   vararg     | The arguments of Entity:EmitSound()
function ss.EmitSoundPredicted(ply, ent, ...)
    ss.SuppressHostEventsMP(ply)
    ent:EmitSound(...)
    ss.EndSuppressHostEventsMP(ply)
end

function ss.SuppressHostEventsMP(ply)
    if ss.sp or CLIENT then return end
    if IsValid(ply) and ply:IsPlayer() then
        SuppressHostEvents(ply)
    end
end

function ss.EndSuppressHostEventsMP(ply)
    if ss.sp or CLIENT then return end
    if IsValid(ply) and ply:IsPlayer() then
        SuppressHostEvents(NULL)
    end
end

function ss.GetGravityDirection()
    local g = physenv.GetGravity()
    if not g then return -vector_up end
    return g:GetNormalized()
end

function ss.RegisterEntity(ent)
    local color = ent:GetNWInt("inkcolor", -1)
    if color < 0 then return end
    ss.EntityFilters[color] = ss.EntityFilters[color] or {}
    ss.EntityFilters[color][ent] = true
end

function ss.MakeAllyFilter(weapon, ...)
    local owner = weapon:GetOwner()
    local color = weapon:GetNWInt "inkcolor"
    local entities = { weapon, owner }
    for ent in pairs(ss.EntityFilters[color] or {}) do
        if IsValid(ent) then
            entities[#entities + 1] = ent
        else
            ss.EntityFilters[color][ent] = nil
        end
    end

    return entities
end

function ss.class(name)
    local def = ss.ClassDefinitions
    if not def[name] then
        return function(t) def[name] = t end
    else
        local function deepcopy(t, lookup)
            if t == nil then return nil end

            local copy = setmetatable({}, deepcopy(getmetatable(t)))
            for k, v in pairs(t) do
                if istable(v) then
                    lookup = lookup or {}
                    lookup[t] = copy
                    if lookup[v] then
                        copy[k] = lookup[v]
                    else
                        copy[k] = deepcopy(v, lookup)
                    end
                elseif isvector(v) then
                    copy[k] = Vector(v)
                elseif isangle(v) then
                    copy[k] = Angle(v)
                elseif ismatrix(v) then
                    copy[k] = Matrix(v)
                else
                    copy[k] = v
                end
            end

            return copy
        end

        local instance = deepcopy(def[name])
        local function read(self, key)
            assert(rawget(-self, key) ~= nil, "no matching field '" .. key .. "'")
            return rawget(-self, key)
        end

        local function write(self, key, value)
            local v = rawget(-self, key)
            local t = type(v)
            local u = type(value)
            if t == "table" then t = (getmetatable(v) or {}).__class or t end
            if u == "table" then u = (getmetatable(value) or {}).__class or u end
            assert(v ~= nil, "no matching field '" .. key .. "'")
            assert(t == u, "type mismatch, expected: '" .. t .. "', given: '" .. u .. "'")
            rawset(-self, key, value)
        end

        local function str(self)
            return "[instanceof " .. getmetatable(self).__class .. "]"
        end

        local function raw(self)
            return getmetatable(self).instance
        end

        return setmetatable({}, {
            instance = instance,
            __call = function() end,
            __class = name,
            __index = read,
            __newindex = write,
            __tostring = str,
            __unm = raw,
        })
    end
end
