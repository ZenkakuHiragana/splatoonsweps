
-- Serverside SplatoonSWEPs structure

---@class ss.Transferrable
---@field MapCRC              string
---@field Revision            integer
---@field MinimapAreaBounds   table<integer, { mins: Vector, maxs: Vector }>
---@field SurfaceArrayLDR     PaintableSurface[]
---@field SurfaceArrayHDR     PaintableSurface[]
---@field SurfaceArrayDetails PaintableSurface[]
---@field WaterSurfaces       PaintableSurface[]
---@field Lightmap            ss.Lightmap

---@class ss.InkShotMask
---@field width     integer
---@field height    integer
---@field [integer] boolean[]

if not SplatoonSWEPs then
---@class ss
SplatoonSWEPs = {
    ClassDefinitions        = {}, ---@type table<string, table>
    CrosshairColors         = {}, ---@type integer[]
    DisruptedEntities       = {}, ---@type table<Entity, number> [target] = time of getting disrupted
    EntityFilters           = {}, ---@type table<integer, table<Entity, boolean>> [color][target] = true
    InkColors               = {}, ---@type Color[]
    InkQueue                = {}, ---@type table<number, ss.InkQueue[]>
    InkShotMasks            = {}, ---@type ss.InkShotMask[][] Indexing order -> InkType, ThresholdIndex, x, y
    InkShotTypes            = {}, ---@type table<string, integer[]> InkShotCategory (string: "drop", "shot", etc.)  InkShotTypes (integer[])
    InkShotTypeToCategory   = {}, ---@type string[] InkShotType (integer) to InkShotCategory (string: "drop", "shot", etc.)
    InvincibleEntities      = {}, ---@type table<Entity, number> [target] = end time
    KnockbackVector         = {}, ---@type table<Entity, Vector> [target] = current knockback velocity
    LastHitID               = {}, ---@type table<Entity, integer> [target] = ink id
    Lightmap                = {}, ---@type ss.Lightmap
    MarkedEntities          = {}, ---@type table<Entity, table<integer, number>> [target][color] = time of getting marked
    MinimapAreaBounds       = {}, ---@type table<integer, { mins: Vector, maxs: Vector }>
    PaintSchedule           = {}, ---@type table<table, true>
    PlayerFilters           = {}, ---@type table<integer, table<Entity, boolean>> [color][player, npc, or nextbot] = true
    PlayerHullChanged       = {}, ---@type table<Player, boolean>
    PlayerID                = {}, ---@type table<Player, string>
    PlayerShouldResetCamera = {}, ---@type table<Player, boolean>
    PlayersReady            = {}, ---@type Player[]
    SurfaceArray            = {}, ---@type PaintableSurface[]
    SurfaceArrayLDR         = {}, ---@type PaintableSurface[]
    SurfaceArrayHDR         = {}, ---@type PaintableSurface[]
    SurfaceArrayDetails     = {}, ---@type PaintableSurface[]
    WeaponRecord            = {}, ---@type table<Entity, ss.WeaponRecord>
    WaterSurfaces           = {}, ---@type PaintableSurface[]
}
end

include "splatoonsweps/const.lua"
include "splatoonsweps/shared.lua"
include "lightmap.lua"
include "network.lua"
include "surfacebuilder.lua"

---@class ss
local ss = SplatoonSWEPs
if not ss.GetOption "enabled" then
    for h, t in pairs(hook.GetTable() --[[@as table<string, table<string, function>>]]) do
        for name in pairs(t) do
            if ss.ProtectedCall(name.find, name, "SplatoonSWEPs") then
                hook.Remove(h, name)
            end
        end
    end

    table.Empty(SplatoonSWEPs)
    ---@diagnostic disable-next-line: global-element
    SplatoonSWEPs = nil ---@type nil
    return
end

concommand.Add("sv_splatoonsweps_clear", function(ply, _, _, _)
    if not IsValid(ply) and game.IsDedicated() or IsValid(ply) and ply:IsAdmin() then
        ss.ClearAllInk()
    end
end, nil, ss.Text.CVars.Clear --[[@as string]], FCVAR_SERVER_CAN_EXECUTE)

---Clears all ink in the world.
---Sends a net message to clear ink on clientside.
---@diagnostic disable-next-line: duplicate-set-field
function ss.ClearAllInk()
    if player.GetCount() > 0 then
        net.Start "SplatoonSWEPs: Send ink cleanup"
        net.Send(ss.PlayersReady)
    end

    table.Empty(ss.InkQueue)
    table.Empty(ss.PaintSchedule)
    if not ss.SurfaceArray then return end -- Workaround for changelevel
    for _, s in ipairs(ss.SurfaceArray) do
        table.Empty(s.InkColorGrid)
    end

    collectgarbage "collect"
end

---Calls notification.AddLegacy serverside
---@param msg      string  Message to display
---@param user     Player? The receiver
---@param icon     number? Notification icon. Note that NOTIFY_Enums are only in clientside
---@param duration number? Duration of the notification in seconds
function ss.SendError(msg, user, icon, duration)
    if IsValid(user) and not user--[[@as Player]]:IsPlayer() then return end
    if not user and player.GetCount() == 0 then return end
    net.Start "SplatoonSWEPs: Send an error message"
    net.WriteUInt(icon or 1, ss.SEND_ERROR_NOTIFY_BITS)
    net.WriteUInt(duration or 8, ss.SEND_ERROR_DURATION_BITS)
    net.WriteString(msg)
    if user then
        net.Send(user)
    else
        net.Send(ss.PlayersReady)
    end
end

local NPCFactions = {
    [CLASS_NONE]              = "others",
    [CLASS_PLAYER]            = "player",
    [CLASS_PLAYER_ALLY]       = "citizen",
    [CLASS_PLAYER_ALLY_VITAL] = "citizen",
    [CLASS_ANTLION]           = "antlion",
    [CLASS_BARNACLE]          = "barnacle",
    [CLASS_BULLSEYE]          = "others",
    [CLASS_CITIZEN_PASSIVE]   = "citizen",
    [CLASS_CITIZEN_REBEL]     = "citizen",
    [CLASS_COMBINE]           = "combine",
    [CLASS_COMBINE_GUNSHIP]   = "combine",
    [CLASS_CONSCRIPT]         = "others",
    [CLASS_HEADCRAB]          = "zombie",
    [CLASS_MANHACK]           = "combine",
    [CLASS_METROPOLICE]       = "combine",
    [CLASS_MILITARY]          = "military",
    [CLASS_SCANNER]           = "combine",
    [CLASS_STALKER]           = "combine",
    [CLASS_VORTIGAUNT]        = "citizen",
    [CLASS_ZOMBIE]            = "zombie",
    [CLASS_PROTOSNIPER]       = "combine",
    [CLASS_MISSILE]           = "others",
    [CLASS_FLARE]             = "others",
    [CLASS_EARTH_FAUNA]       = "others",
    [CLASS_HACKED_ROLLERMINE] = "citizen",
    [CLASS_COMBINE_HUNTER]    = "combine",
    [CLASS_MACHINE]           = "military",
    [CLASS_HUMAN_PASSIVE]     = "citizen",
    [CLASS_HUMAN_MILITARY]    = "military",
    [CLASS_ALIEN_MILITARY]    = "alien",
    [CLASS_ALIEN_MONSTER]     = "alien",
    [CLASS_ALIEN_PREY]        = "zombie",
    [CLASS_ALIEN_PREDATOR]    = "alien",
    [CLASS_INSECT]            = "others",
    [CLASS_PLAYER_BIOWEAPON]  = "player",
    [CLASS_ALIEN_BIOWEAPON]   = "alien",
}
---Gets an ink color for the given NPC, considering its faction.
---@param n Entity?
---@return integer # Ink color for the NPC
function ss.GetNPCInkColor(n)
    if not IsValid(n) then return 1 end ---@cast n NPC
    if not isfunction(n.Classify) then
        return n.SplatoonSWEPsInkColor --[[@as integer?]] or 1
    end

    local class = n:Classify()
    local cvar = ss.GetOption "npcinkcolor"
    local colors = {
        citizen  = cvar "citizen"          --[[@as integer]],
        combine  = cvar "combine"          --[[@as integer]],
        military = cvar "military"         --[[@as integer]],
        zombie   = cvar "zombie"           --[[@as integer]],
        antlion  = cvar "antlion"          --[[@as integer]],
        alien    = cvar "alien"            --[[@as integer]],
        barnacle = cvar "barnacle"         --[[@as integer]],
        player   = ss.GetOption "inkcolor" --[[@as integer]],
        others   = cvar "others"           --[[@as integer]],
    }
    return colors[NPCFactions[class]] or colors.others or 1
end

---@param weapon SplatoonWeaponBase
---@return integer
function ss.GetBotInkColor(weapon)
    local color = math.random(1, ss.MAX_COLORS)
    weapon.BotInkColor = weapon.BotInkColor or color
    return weapon.BotInkColor
end

---@param self SplatoonWeaponBase
---@param ply Player The player
---@param speed number The fall speed
---@return integer?
function ss.GetFallDamage(self, ply, speed)
    if ss.IsInvincible(ply) then return 0 end
    if ss.GetOption "takefalldamage" then return end
    return 0
end

---@param ply Player
function ss.SynchronizePlayerStats(ply)
    ss.WeaponRecord[ply] = {
        Duration = {},
        Inked = {},
        Recent = {},
    }

    local id = ss.PlayerID[ply]
    if not id then return end
    local record = "data/splatoonsweps/record/" .. id:lower():gsub(":", "_") .. ".txt"
    if not file.Exists(record, "GAME") then return end
    local json = file.Read(record, "GAME")
    local cmpjson = util.Compress(json)
    ss.WeaponRecord[ply] = util.JSONToTable(json)
    net.Start "SplatoonSWEPs: Send player data"
    net.WriteUInt(cmpjson:len(), 16)
    net.WriteData(cmpjson, cmpjson:len())
    net.Send(ply)
end

---Mark entities with a specific color for duration seconds
---@param color integer
---@param entities Entity[]
---@param duration number
function ss.MarkEntity(color, entities, duration)
    local hit = false
    for _, ent in ipairs(entities) do
        if ent:IsPlayer() and --[[@cast ent Player]] not ent:Alive() then continue end
        if not (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) then continue end
        local w = ss.IsValidInkling(ent) ---@type Weapon?
        if w and ss.IsAlly(color, w) then continue end
        local marked = ss.MarkedEntities[ent] and ss.MarkedEntities[ent][color]
        local name = "SplatoonSWEPs: Point Sensor " .. ent:EntIndex() .. ", " .. color
        if marked then
            timer.Adjust(name, duration)
        else
            local e = EffectData()
            e:SetEntity(ent)
            e:SetColor(color)
            util.Effect("SplatoonSWEPsMarker", e, nil, true)
            ss.SetMarkedEntity(ent, color, true)
            timer.Create(name, duration, 1, function()
                if not IsValid(ent) then return end
                ss.SetMarkedEntity(ent, color, false)
            end)
        end

        hit = true
    end

    if not hit then return end

    -- Players with the same color will hear the point sensor hit sound
    ss.EmitSound(table.GetKeys(ss.PlayerFilters[color] or {}), "SplatoonSWEPs.PointSensorHit")
end

---Parses the map and stores the result to a txt file, then sends it to the clients.
local function InitPostEntity()
    -- If the local server has crashed before, RT shrinks.
    if ss.sp and file.Exists("splatoonsweps/crashdump.txt", "DATA") then
        local res = ss.GetConVar "rtresolution"
        if res then res:SetInt(0) end
        ss.SendError(ss.Text.Error.CrashDetected --[[@as string]], nil, nil, 15)
    end

    local bspPath = string.format("maps/%s.bsp", game.GetMap())
    local txtPath = string.format("splatoonsweps/%s.txt", game.GetMap())
    ---@type ss.Transferrable
    local data = util.JSONToTable(util.Decompress(file.Read(txtPath) or "") or "", true) or {}
    local mapCRC = util.CRC(file.Read(bspPath, true))
    if not file.Exists("splatoonsweps", "DATA") then file.CreateDir "splatoonsweps" end
    if data.MapCRC ~= mapCRC or data.Revision ~= ss.MAPCACHE_REVISION then
        local t0 = SysTime()
        print("\n[Splatoon SWEPs] Building inkable surface structre...")
        ss.LoadBSP()
        ss.GenerateSurfaces()
        ss.BuildLightmap()
        data.MapCRC = mapCRC
        data.Revision = ss.MAPCACHE_REVISION
        data.Lightmap = ss.Lightmap
        data.MinimapAreaBounds = ss.MinimapAreaBounds
        data.SurfaceArrayLDR = ss.SurfaceArrayLDR
        data.SurfaceArrayHDR = ss.SurfaceArrayHDR
        data.SurfaceArrayDetails = ss.SurfaceArrayDetails
        data.WaterSurfaces = ss.WaterSurfaces
        file.Write(txtPath, util.Compress(util.TableToJSON(data)))
        local total = math.Round((SysTime() - t0) * 1000, 2)
        print("Finished!  Total construction time: " .. total .. " ms.\n")
    else
        ss.MinimapAreaBounds   = data.MinimapAreaBounds
        ss.SurfaceArrayLDR     = data.SurfaceArrayLDR
        ss.SurfaceArrayHDR     = data.SurfaceArrayHDR
        ss.SurfaceArrayDetails = data.SurfaceArrayDetails
    end

    if #ss.SurfaceArrayHDR > 0 then
        ss.SurfaceArray, ss.SurfaceArrayHDR = ss.SurfaceArrayHDR, nil
    else
        ss.SurfaceArray, ss.SurfaceArrayLDR = ss.SurfaceArrayLDR, nil
    end
    table.Add(ss.SurfaceArray, ss.SurfaceArrayDetails)
    ss.SurfaceArrayLDR = nil
    ss.SurfaceArrayHDR = nil
    ss.SurfaceArrayDetails = nil

    collectgarbage "collect"

    -- This is needed due to a really annoying bug (GitHub/garrysmod-issues #1495)
    SetGlobalBool("SplatoonSWEPs: IsDedicated", game.IsDedicated())

    -- CRC check clientside
    SetGlobalString("SplatoonSWEPs: Ink map CRC", util.CRC(file.Read(txtPath)))

    ss.SURFACE_ID_BITS = select(2, math.frexp(#ss.SurfaceArray))
    resource.AddSingleFile("data/" .. txtPath)

    ss.PrecachePaintTextures()
    ss.GenerateHashTable()
    ss.ClearAllInk()
end

---NOTE: PlayerInitialSpawn is called before InitPostEntity on changelevel
---@param ply Player
local function PlayerInitialSpawn(ply)
    ss.InitializeMoveEmulation(ply)
    ss.SynchronizePlayerStats(ply)
    if not ply:IsBot() then ss.ClearAllInk() end
end

---@param ply Player
---@param id string
local function OnPlayerAuthed(ply, id)
    if ss.IsGameInProgress --[[@as boolean?]] then
        ply:Kick "Splatoon SWEPs: The game is in progress"
        return
    end

    ss.PlayerID[ply] = id
end

---@param ply Player
local function SavePlayerData(ply)
    ---@param v Player
    ---@return boolean
    local function f(v) return v == ply end
    ss.tableremovefunc(ss.PlayersReady, f)
    if not ss.WeaponRecord[ply] then return end
    local id = ss.PlayerID[ply]
    if not id then return end
    local record = "splatoonsweps/record/" .. id:lower():gsub(":", "_") .. ".txt"
    if not file.Exists("data/splatoonsweps/record", "GAME") then
        file.CreateDir "splatoonsweps/record"
    end
    file.Write(record, util.TableToJSON(ss.WeaponRecord[ply], true))

    ss.PlayerID[ply] = nil
    ss.WeaponRecord[ply] = nil
end

local function OnShutdown()
    for _, v in ipairs(player.GetAll()) do
        SavePlayerData(v)
    end
end

---@param ent Entity
---@param dmg CTakeDamageInfo
---@return boolean?
local function OnEntityTakeDamage(ent, dmg)
    if ent:Health() <= 0 then return end
    local w = ss.IsValidInkling(ent)
    local a = dmg:GetAttacker()
    local i = dmg:GetInflictor() --[[@as SplatoonWeaponBase]]
    if not w then return end
    if IsValid(a) and ss.IsInvincible(ent) then
        ss.ApplyKnockback(ent, dmg:GetDamageForce() * dmg:GetDamage())
        if ss.mp and ent:IsPlayer() then ---@cast ent Player
            net.Start("SplatoonSWEPs: Play bubbler hit sound", true)
            net.Send(ent)
        else
            ent:EmitSound "SplatoonSWEPs.BubblerHit"
        end
        return true
    end
    w.HealSchedule:SetDelay(ss.HealDelay)
    if not (IsValid(a) and i.IsSplatoonWeapon) then return end
    if ss.IsAlly(w, i) then return true end
    if ss.IsAlly(ent, i) then return true end
    if not ent:IsPlayer() then return end ---@cast ent Player
    net.Start("SplatoonSWEPs: Play damage sound", true)
    net.Send(ent)
end

---@param ply Player|NPC
---@param attacker Entity
local function OnPlayerDeath(ply, attacker)
    local w = ss.IsValidInkling(ply)
    local inflictor = ss.IsValidInkling(attacker)
    if inflictor and (not ss.GetOption "explodeonlysquids" or w) then
        ss.MakeDeathExplosion(ply:WorldSpaceCenter(), attacker, inflictor:GetNWInt "inkcolor")
    end

    if w and w:GetSuperJumpState() >= 0 then
        w:SetSuperJumpState(-1)
        ss.SetSuperJumpBoneManipulation(ply, angle_zero)
    end

    local markedcolors = ss.MarkedEntities[ply]
    if not markedcolors then return end
    for color in pairs(markedcolors) do
        ss.SetMarkedEntity(ply, color, false)
    end
end

---@param _ Player
---@param dmg CTakeDamageInfo
---@return boolean?
local function OnDamagedByExplosion(_, dmg)
    local inflictor = dmg:GetInflictor() --[[@as SplatoonWeaponBase|ENT.Throwable]]
    return IsValid(inflictor) and (inflictor.IsSplatoonWeapon or inflictor.IsSplatoonBomb) or nil
end

---@param ent Entity
local function OnEntityRemoved(ent)
    if ss.DisruptedEntities[ent] then
        ss.SetDisruptedEntity(ent, false)
    end
    if ss.InvincibleEntities[ent] then
        ss.SetInvincibleDuration(ent, -1)
    end
    if ss.MarkedEntities[ent] then
        for color in pairs(ss.MarkedEntities[ent]) do
            ss.SetMarkedEntity(ent, color, false)
        end
    end
    for color in pairs(ss.EntityFilters) do
        ss.SetEntityFilter(ent, color, false)
    end
    for color in pairs(ss.PlayerFilters) do
        ss.SetPlayerFilter(ent, color, false)
    end
end

hook.Add("PostCleanupMap", "SplatoonSWEPs: Cleanup all ink", ss.ClearAllInk)
hook.Add("InitPostEntity", "SplatoonSWEPs: Serverside Initialization", InitPostEntity)
hook.Add("PlayerInitialSpawn", "SplatoonSWEPs: Add a player", PlayerInitialSpawn)
hook.Add("PlayerAuthed", "SplatoonSWEPs: Store player ID", OnPlayerAuthed)
hook.Add("PlayerDisconnected", "SplatoonSWEPs: Reset player's readiness", SavePlayerData)
hook.Add("ShutDown", "SplatoonSWEPs: Save player data", OnShutdown)
hook.Add("GetFallDamage", "SplatoonSWEPs: Inklings don't take fall damage.", ss.hook "GetFallDamage")
hook.Add("EntityTakeDamage", "SplatoonSWEPs: Ink damage manager", OnEntityTakeDamage)
hook.Add("EntityRemoved", "SplatoonSWEPs: Remove regiestered entity", OnEntityRemoved)
hook.Add("DoPlayerDeath", "SplatoonSWEPs: Death explosion and reset super jump state", OnPlayerDeath)
hook.Add("OnNPCKilled", "SplatoonSWEPs: Death explosion and reset super jump state", OnPlayerDeath)
hook.Add("OnDamagedByExplosion", "SplatoonSWEPs: No sound effect needed", OnDamagedByExplosion)
