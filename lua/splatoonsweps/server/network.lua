
-- util.AddNetworkString's

---@class ss
local ss = SplatoonSWEPs
if not ss then return end

util.AddNetworkString "SplatoonSWEPs: Change throwing"
util.AddNetworkString "SplatoonSWEPs: Register knockback"
util.AddNetworkString "SplatoonSWEPs: Play damage sound"
util.AddNetworkString "SplatoonSWEPs: Play bubbler hit sound"
util.AddNetworkString "SplatoonSWEPs: Ready to splat"
util.AddNetworkString "SplatoonSWEPs: Redownload ink data"
util.AddNetworkString "SplatoonSWEPs: Send a sound"
util.AddNetworkString "SplatoonSWEPs: Send an error message"
util.AddNetworkString "SplatoonSWEPs: Send an ink queue"
util.AddNetworkString "SplatoonSWEPs: Send ink cleanup"
util.AddNetworkString "SplatoonSWEPs: Send player data"
util.AddNetworkString "SplatoonSWEPs: Send turf inked"
util.AddNetworkString "SplatoonSWEPs: Strip weapon"
util.AddNetworkString "SplatoonSWEPs: Super jump"
util.AddNetworkString "SplatoonSWEPs: Sync disrupted entity state"
util.AddNetworkString "SplatoonSWEPs: Sync invincible entity state"
util.AddNetworkString "SplatoonSWEPs: Sync marked entity state"
net.Receive("SplatoonSWEPs: Ready to splat", function(_, ply)
    ss.PlayersReady[#ss.PlayersReady + 1] = ply
    ss.InitializeMoveEmulation(ply)
    ss.SynchronizePlayerStats(ply)
end)

local RedownloadProgress = {} ---@type table<Player, integer>
net.Receive("SplatoonSWEPs: Redownload ink data", function(_, ply)
    local data = file.Read(string.format("splatoonsweps/%s.txt", game.GetMap()))
    local startpos = RedownloadProgress[ply] or 1
    local header, bool, uint, float = 3, 1, 2, 4
    local bps = 65536 - header - bool - uint - float
    local chunk = data:sub(startpos, startpos + bps - 1)
    local size = chunk:len()
    local current = math.floor(startpos / bps)
    local total = math.floor(data:len() / bps)
    RedownloadProgress[ply] = startpos + size
    net.Start "SplatoonSWEPs: Redownload ink data"
    net.WriteBool(size < bps or data:len() < startpos + bps)
    net.WriteUInt(size, 16)
    net.WriteData(chunk, size)
    net.WriteFloat(current / total)
    net.Send(ply)
    print(string.format("Redownloading ink data to %s (%d/%d)", tostring(ply), current, total))
end)

net.Receive("SplatoonSWEPs: Send ink cleanup", function(_, ply)
    if not ply:IsAdmin() then return end
    ss.ClearAllInk()
end)

net.Receive("SplatoonSWEPs: Strip weapon", function(_, ply)
    local weaponID = net.ReadUInt(ss.WEAPON_CLASSNAMES_BITS)
    local weaponClass = ss.WeaponClassNames[weaponID]
    if not weaponClass then return end
    local weapon = ply:GetWeapon(weaponClass)
    if not IsValid(weapon) then return end
    ply:StripWeapon(weaponClass)
end)

net.Receive("SplatoonSWEPs: Super jump", function(len, ply)
    local ent = net.ReadEntity() --[[@as ENT.SquidBeakon]]
    if not IsValid(ent) then return end
    if not ent.IsSquidBeakon then return end
    ss.EnterSuperJumpState(ply, ent)
end)
