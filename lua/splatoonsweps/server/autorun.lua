
-- Serverside SplatoonSWEPs structure

SplatoonSWEPs = SplatoonSWEPs or {
    ClassDefinitions = {},
    CrosshairColors = {},
    EntityFilters = {},
    LastHitID = {},
    MinimapAreaBounds = {},
    NoCollide = {},
    NumInkEntities = 0,
    InkColors = {},
    InkQueue = {},
    InkShotMaterials = {},
    PaintSchedule = {},
    PlayerHullChanged = {},
    PlayerID = {},
    PlayerShouldResetCamera = {},
    PlayersReady = {},
    SurfaceArray = {},
    RenderTarget = {},
    WeaponRecord = {},
    WaterSurfaces = {},
}

include "splatoonsweps/const.lua"
include "splatoonsweps/shared.lua"
include "bsploader.lua"
include "bvh.lua"
include "network.lua"
include "surfacebuilder.lua"

local ss = SplatoonSWEPs
if not ss.GetOption "enabled" then
    for h, t in pairs(hook.GetTable()) do
        for name in pairs(t) do
            if ss.ProtectedCall(name.find, name, "SplatoonSWEPs") then
                hook.Remove(h, name)
            end
        end
    end

    table.Empty(SplatoonSWEPs)
    SplatoonSWEPs = nil
    return
end

concommand.Add("sv_splatoonsweps_clear", function(ply, _, _, _)
    if not IsValid(ply) and game.IsDedicated() or IsValid(ply) and ply:IsAdmin() then
        ss.ClearAllInk()
    end
end, nil, ss.Text.CVars.Clear, FCVAR_SERVER_CAN_EXECUTE)

-- Clears all ink in the world.
-- Sends a net message to clear ink on clientside.
function ss.ClearAllInk()
    if player.GetCount() > 0 then
        net.Start "SplatoonSWEPs: Send ink cleanup"
        net.Send(ss.PlayersReady)
    end

    table.Empty(ss.InkQueue)
    table.Empty(ss.PaintSchedule)
    if not ss.SurfaceArray then return end -- Workaround for changelevel
    for _, s in ipairs(ss.SurfaceArray) do
        for _, v in pairs(s.InkColorGrid) do
            table.Empty(v)
        end
    end

    collectgarbage "collect"
end

-- Calls notification.AddLegacy serverside.
-- Arguments:
--   string msg      | The message to display.
--   Player user     | The receiver.
--   number icon     | Notification icon.  Note that NOTIFY_Enums are only in clientside.
--   number duration | The number of seconds to display the notification for.
function ss.SendError(msg, user, icon, duration)
    if IsValid(user) and not user:IsPlayer() then return end
    if not user and player.GetCount() == 0 then return end
    net.Start "SplatoonSWEPs: Send an error message"
    net.WriteUInt(icon or 1, ss.SEND_ERROR_NOTIFY_BITS)
    net.WriteUInt(duration or 8, ss.SEND_ERROR_DURATION_BITS)
    net.WriteString(msg)
    if user then
        net.Send(user)
    else
        net.Broadcast()
    end
end

-- Gets an ink color for the given NPC, considering its faction.
-- Argument:
--   Entity n     | The NPC
-- Returnings:
--   number color | The ink color for the given NPC.
local NPCFactions = {
    [CLASS_NONE] = "others",
    [CLASS_PLAYER] = "player",
    [CLASS_PLAYER_ALLY] = "citizen",
    [CLASS_PLAYER_ALLY_VITAL] = "citizen",
    [CLASS_ANTLION] = "antlion",
    [CLASS_BARNACLE] = "barnacle",
    [CLASS_BULLSEYE] = "others",
    [CLASS_CITIZEN_PASSIVE] = "citizen",
    [CLASS_CITIZEN_REBEL] = "citizen",
    [CLASS_COMBINE] = "combine",
    [CLASS_COMBINE_GUNSHIP] = "combine",
    [CLASS_CONSCRIPT] = "others",
    [CLASS_HEADCRAB] = "zombie",
    [CLASS_MANHACK] = "combine",
    [CLASS_METROPOLICE] = "combine",
    [CLASS_MILITARY] = "military",
    [CLASS_SCANNER] = "combine",
    [CLASS_STALKER] = "combine",
    [CLASS_VORTIGAUNT] = "citizen",
    [CLASS_ZOMBIE] = "zombie",
    [CLASS_PROTOSNIPER] = "combine",
    [CLASS_MISSILE] = "others",
    [CLASS_FLARE] = "others",
    [CLASS_EARTH_FAUNA] = "others",
    [CLASS_HACKED_ROLLERMINE] = "citizen",
    [CLASS_COMBINE_HUNTER] = "combine",
    [CLASS_MACHINE] = "military",
    [CLASS_HUMAN_PASSIVE] = "citizen",
    [CLASS_HUMAN_MILITARY] = "military",
    [CLASS_ALIEN_MILITARY] = "alien",
    [CLASS_ALIEN_MONSTER] = "alien",
    [CLASS_ALIEN_PREY] = "zombie",
    [CLASS_ALIEN_PREDATOR] = "alien",
    [CLASS_INSECT] = "others",
    [CLASS_PLAYER_BIOWEAPON] = "player",
    [CLASS_ALIEN_BIOWEAPON] = "alien",
}
function ss.GetNPCInkColor(n)
    if not IsValid(n) then return 1 end
    if not isfunction(n.Classify) then
        return n.SplatoonSWEPsInkColor or 1
    end

    local class = n:Classify()
    local cvar = ss.GetOption "npcinkcolor"
    local colors = {
        citizen = cvar "citizen",
        combine = cvar "combine",
        military = cvar "military",
        zombie = cvar "zombie",
        antlion = cvar "antlion",
        alien = cvar "alien",
        barnacle = cvar "barnacle",
        player = ss.GetOption "inkcolor",
        others = cvar "others",
    }
    return colors[NPCFactions[class]] or colors.others or 1
end

function ss.GetBotInkColor(weapon)
    local color = math.random(1, ss.MAX_COLORS)
    weapon.BotInkColor = weapon.BotInkColor or color
    return weapon.BotInkColor
end

function ss.GetFallDamage(self, _, _)
    if ss.GetOption "takefalldamage" then return end
    return 0
end

-- Parse the map and store the result to txt, then send it to the client.
hook.Add("PostCleanupMap", "SplatoonSWEPs: Cleanup all ink", ss.ClearAllInk)
hook.Add("InitPostEntity", "SplatoonSWEPs: Serverside Initialization", function()
    -- If the local server has crashed before, RT shrinks.
    if ss.sp and file.Exists("splatoonsweps/crashdump.txt", "DATA") then
        local res = ss.GetConVar "rtresolution"
        if res then res:SetInt(0) end
        ss.SendError(ss.Text.Error.CrashDetected, nil, nil, 15)
    end

    local path = string.format("splatoonsweps/%s.txt", game.GetMap())
    local pathbsp = string.format("maps/%s.bsp", game.GetMap())
    local data = util.JSONToTable(util.Decompress(file.Read(path) or "") or "") or {}
    local mapCRC = tonumber(util.CRC(file.Read(pathbsp, true)))
    if not file.Exists("splatoonsweps", "DATA") then file.CreateDir "splatoonsweps" end
    if data.MapCRC ~= mapCRC then
        ss.LoadBSP()
        ss.GenerateSurfaces()
        ss.GenerateAABBTree()
        data.MapCRC = mapCRC
        data.AABBTree = ss.SanitizeJSONLimit(ss.AABBTree)
        data.MinimapAreaBounds = ss.SanitizeJSONLimit(ss.MinimapAreaBounds)
        data.SurfaceArray = ss.SanitizeJSONLimit(ss.SurfaceArray)
        data.WaterSurfaces = ss.SanitizeJSONLimit(ss.WaterSurfaces)

        file.Write(path, util.Compress(util.TableToJSON(data)))
    else
        ss.AABBTree = ss.DesanitizeJSONLimit(data.AABBTree)
        ss.MinimapAreaBounds = ss.DesanitizeJSONLimit(data.MinimapAreaBounds)
        ss.SurfaceArray = ss.DesanitizeJSONLimit(data.SurfaceArray)
        ss.WaterSurfaces = ss.DesanitizeJSONLimit(data.WaterSurfaces)
    end

    -- This is needed due to a really annoying bug (GitHub/garrysmod-issues #1495)
    SetGlobalBool("SplatoonSWEPs: IsDedicated", game.IsDedicated())
    SetGlobalString("SplatoonSWEPs: Ink map CRC", util.CRC(file.Read(path))) -- CRC check clientside
    resource.AddSingleFile("data/" .. path)
    ss.SURFACE_ID_BITS = select(2, math.frexp(#ss.SurfaceArray))

    ss.ClearAllInk()
end)

-- NOTE: PlayerInitialSpawn is called before InitPostEntity on changelevel
hook.Add("PlayerInitialSpawn", "SplatoonSWEPs: Add a player", function(ply)
    ss.InitializeMoveEmulation(ply)
    if not ply:IsBot() then ss.ClearAllInk() end
end)

hook.Add("PlayerAuthed", "SplatoonSWEPs: Store player ID", function(ply, id)
    if ss.IsGameInProgress then
        ply:Kick "Splatoon SWEPs: The game is in progress"
        return
    end

    ss.PlayerID[ply] = id
end)

local function SavePlayerData(ply)
    ss.tableremovefunc(ss.PlayersReady, function(v) return v == ply end)
    if not ss.WeaponRecord[ply] then return end
    local id = ss.PlayerID[ply]
    if not id then return end
    local record = "splatoonsweps/record/" .. id .. ".txt"
    if not file.Exists("data/splatoonsweps/record", "GAME") then
        file.CreateDir "splatoonsweps/record"
    end
    file.Write(record, util.TableToJSON(ss.WeaponRecord[ply], true))

    ss.PlayerID[ply] = nil
    ss.WeaponRecord[ply] = nil
end

hook.Add("PlayerDisconnected", "SplatoonSWEPs: Reset player's readiness", SavePlayerData)
hook.Add("ShutDown", "SplatoonSWEPs: Save player data", function()
    for _, v in ipairs(player.GetAll()) do
        SavePlayerData(v)
    end
end)

hook.Add("GetFallDamage", "SplatoonSWEPs: Inklings don't take fall damage.", ss.hook "GetFallDamage")
hook.Add("EntityTakeDamage", "SplatoonSWEPs: Ink damage manager", function(ent, dmg)
    if ent:Health() <= 0 then return end
    local w = ss.IsValidInkling(ent)
    local a = dmg:GetAttacker()
    local i = dmg:GetInflictor()
    if w then w.HealSchedule:SetDelay(ss.HealDelay) end
    if not w then return end
    if not (IsValid(a) and i.IsSplatoonWeapon) then return end
    if ss.IsAlly(w, i) then return true end
    if ss.IsAlly(ent, i) then return true end
    if not ent:IsPlayer() then return end
    net.Start "SplatoonSWEPs: Play damage sound"
    net.Send(ent)
end)

local function DeathExplosion(ply, attacker)
    local w = ss.IsValidInkling(attacker)
    if not w then return end
    if ss.GetOption "explodeonlysquids" and not ss.IsValidInkling(ply) then return end
    ss.MakeDeathExplosion(ply:WorldSpaceCenter(), attacker, w:GetNWInt "inkcolor")
    for _, e in ipairs(ents.FindByClass "env_entity_dissolver") do print(e) end
end

hook.Add("DoPlayerDeath", "SplatoonSWEPs: Make a death explosion", DeathExplosion)
hook.Add("OnNPCKilled", "SplatoonSWEPs: Make a death explosion", DeathExplosion)
hook.Add("OnDamagedByExplosion", "SplatoonSWEPs: No sound effect needed", function(_, dmg)
    local inflictor = dmg:GetInflictor()
    return IsValid(inflictor) and (inflictor.IsSplatoonWeapon or inflictor.IsSplatoonBomb) or nil
end)
