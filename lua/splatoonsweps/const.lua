
-- Constant values

---@class ss
local ss = SplatoonSWEPs
if not ss then return end

local InkGirl  = Model "models/drlilrobot/splatoon/ply/inkling_girl.mdl"
local InkBoy   = Model "models/drlilrobot/splatoon/ply/inkling_boy.mdl"
local Octo     = Model "models/drlilrobot/splatoon/ply/octoling.mdl"
local Marie    = Model "models/drlilrobot/splatoon/ply/marie.mdl"
local Callie   = Model "models/drlilrobot/splatoon/ply/callie.mdl"
local OctoGirl = Model "models/player/octoling.mdl"
local OctoBoy  = Model "models/player/octoling_male.mdl"
local Pearl    = Model "models/egghead/splatoon_2/pearl_hime_pm.mdl"
local Marina   = Model "models/egghead/splatoon_2/marina_ida_pm.mdl"

ss.sp = game.SinglePlayer()
ss.mp = not ss.sp
ss.Options           = include "splatoonsweps/constants/options.lua" ---@type {[string]: cvartree.CVarOption}
ss.WeaponClassNames  = include "splatoonsweps/constants/weaponclasses.lua" ---@type string[]
ss.WeaponClassNames2 = include "splatoonsweps/constants/weaponclasses2.lua" ---@type string[]
ss.TEXTUREFLAGS      = include "splatoonsweps/constants/textureflags.lua" ---@type table<string, integer>
ss.RenderTarget      = include "splatoonsweps/constants/rendertarget.lua" ---@type ss.RenderTarget
ss.InkTankModel      = Model "models/props_splatoon/gear/inktank_backpack/inktank_backpack.mdl"
ss.Units             = include "splatoonsweps/constants/parameterunits.lua" ---@type table<string, string>

---@enum PlayerType
ss.PLAYER = {
    NOCHANGE = 1,
    GIRL     = 2,
    BOY      = 3,
    MARIE    = 4,
    CALLIE   = 5,
    OCTO     = 6,
    OCTOGIRL = 7,
    OCTOBOY  = 8,
    PEARL    = 9,
    MARINA   = 10,
}
---@enum SquidType
ss.SQUID = {
    INKLING = 1,
    KRAKEN  = 2,
    OCTO    = 3,
    OCTO2   = 4,
}
---@type { [PlayerType]: string? }
ss.Playermodel = {
    [ss.PLAYER.NOCHANGE] = nil,
    [ss.PLAYER.GIRL]     = InkGirl,
    [ss.PLAYER.BOY]      = InkBoy,
    [ss.PLAYER.MARIE]    = Marie,
    [ss.PLAYER.CALLIE]   = Callie,
    [ss.PLAYER.OCTO]     = Octo,
    [ss.PLAYER.OCTOGIRL] = OctoGirl,
    [ss.PLAYER.OCTOBOY]  = OctoBoy,
    [ss.PLAYER.PEARL]    = Pearl,
    [ss.PLAYER.MARINA]   = Marina,
}
---@type { [string]: PlayerType }
ss.PlayermodelInv = {
    [InkGirl]  = ss.PLAYER.GIRL,
    [InkBoy]   = ss.PLAYER.BOY,
    [Marie]    = ss.PLAYER.MARIE,
    [Callie]   = ss.PLAYER.CALLIE,
    [Octo]     = ss.PLAYER.OCTO,
    [OctoGirl] = ss.PLAYER.OCTOGIRL,
    [OctoBoy]  = ss.PLAYER.OCTOBOY,
    [Pearl]    = ss.PLAYER.PEARL,
    [Marina]   = ss.PLAYER.MARINA,
}
---@type { [SquidType]: string }
ss.Squidmodel = {
    [ss.SQUID.INKLING] = Model "models/splatoonsweps/squids/squid.mdl",
    [ss.SQUID.KRAKEN]  = Model "models/props_splatoon/squids/kraken_beta.mdl",
    [ss.SQUID.OCTO]    = Model "models/splatoonsweps/squids/octopus.mdl",
    [ss.SQUID.OCTO2]   = Model "models/splatoonsweps/squids/octopus2.mdl",
}
---@type { [PlayerType]: SquidType? }
ss.SquidmodelIndex = {
    [ss.PLAYER.NOCHANGE] = nil,
    [ss.PLAYER.GIRL]     = ss.SQUID.INKLING,
    [ss.PLAYER.BOY]      = ss.SQUID.INKLING,
    [ss.PLAYER.MARIE]    = ss.SQUID.INKLING,
    [ss.PLAYER.CALLIE]   = ss.SQUID.INKLING,
    [ss.PLAYER.OCTO]     = ss.SQUID.OCTO,
    [ss.PLAYER.OCTOGIRL] = ss.SQUID.OCTO2,
    [ss.PLAYER.OCTOBOY]  = ss.SQUID.OCTO2,
    [ss.PLAYER.PEARL]    = ss.SQUID.INKLING,
    [ss.PLAYER.MARINA]   = ss.SQUID.OCTO2,
}

ss.SuperJumpVoice = {
    [InkGirl]  = "SplatoonSWEPs_Voice.SuperJump_SquidFemale",
    [InkBoy]   = "SplatoonSWEPs_Voice.SuperJump_SquidMale",
    [Marie]    = "SplatoonSWEPs_Voice.SuperJump_SquidFemale",
    [Callie]   = "SplatoonSWEPs_Voice.SuperJump_SquidFemale",
    [Octo]     = "SplatoonSWEPs_Voice.SuperJump_OctoFemale",
    [OctoGirl] = "SplatoonSWEPs_Voice.SuperJump_OctoFemale",
    [OctoBoy]  = "SplatoonSWEPs_Voice.SuperJump_OctoMale",
    [Pearl]    = "SplatoonSWEPs_Voice.SuperJump_SquidFemale",
    [Marina]   = "SplatoonSWEPs_Voice.SuperJump_OctoFemale",
}

ss.ChargingEyeSkin = {
    [Marie]   = 0,
    [Callie]  = 5,
    [InkBoy]  = 4,
    [InkGirl] = 4,
    [Octo]    = 4,
    [Pearl]   = 5,
    [Marina]  = 4,
}
ss.DrLilRobotPlayermodels = {
    [InkGirl] = true,
    [InkBoy]  = true,
    [Marie]   = true,
    [Callie]  = true,
    [Octo]    = true,
}
ss.TwilightPlayermodels = {
    [OctoGirl] = true,
    [OctoBoy]  = true, -- Can't apply flex manipulation with Octoling boy.
}

ss.Materials = {
    Crosshair = {
        Flash     = Material "splatoonsweps/crosshair/charged.vmt",
        Line      = Material "splatoonsweps/crosshair/line.vmt",
        LineColor = Material "splatoonsweps/crosshair/linecolor.vmt",
    },
    Effects = {
        Hit         = Material "splatoonsweps/effects/splatling_muzzleflash",
        HitCritical = Material "particle/particle_glow_04_additive",
        Ink         = Material "splatoonsweps/effects/ink",
        Invisible   = Material "splatoonsweps/weapons/primaries/shared/weapon_hider",
    },
}

ss.Particles = {
    BlasterTrail         = "splatoonsweps_blaster_trail",
    BlasterExplosion     = "splatoonsweps_explosion",
    BombExplosion        = "splatoonsweps_bomb_explosion",
    BrushRunning         = "splatoonsweps_roller_rolling_brush",
    BrushSplash          = "splatoonsweps_roller_splash_brush",
    ChargerFlash         = "splatoonsweps_charger_flash",
    ChargerMuzzleFlash   = "splatoonsweps_explosion_impact",
    Disruptor            = "splatoonsweps_disruptor",
    MuzzleMist           = "splatoonsweps_muzzlemist",
    RollerRolling        = "splatoonsweps_roller_rolling",
    RollerSplash         = "splatoonsweps_roller_splash",
    SplashWall           = "splatoonsweps_splash_wall",
    SplatlingMuzzleFlash = "splatoonsweps_splatling_muzzleflash",
}

ss.KeyMask                     = {IN_ATTACK, IN_DUCK, IN_ATTACK2}
ss.KeyMaskFind                 = {[IN_ATTACK] = true, [IN_DUCK] = true, [IN_ATTACK2] = true}
ss.CleanupTypeInk              = "SplatoonSWEPs Ink"
ss.GrayScaleFactor             = Vector(.298912, .586611, .114478)
ss.ShooterGravityMul           = 1
ss.RollerGravityMul            = 0.15
ss.PLAYER_BITS                 = 3   -- unsigned enum
ss.SEND_ERROR_DURATION_BITS    = 4   -- unsgined
ss.SEND_ERROR_NOTIFY_BITS      = 3   -- unsigned NOTIFY_ enum 0 to 4
ss.SQUID_BITS                  = 2   -- unsigned enum
-- ss.SURFACE_ID_BITS          = nil -- For surface ID, determined in InitPostEntity
ss.WEAPON_CLASSNAMES_BITS      = 8   -- unsigned, number of weapon classname array
ss.MAPCACHE_REVISION           = 6   -- Map cache file version (force to redownload on addon update)
ss.MAX_DEGREES_DIFFERENCE      = 60  -- Maximum angle difference between two surfaces to paint
ss.MAX_COS_DIFF                = math.cos(math.rad(ss.MAX_DEGREES_DIFFERENCE)) -- Used by filtering process
ss.MAX_WALLCLIMB_STEP          = 10  -- Wall climb: step size for getting over obstacles
ss.WALLCLIMB_STEP_CHECK_LENGTH = 3   -- Wall climb: look ahead distance for getting over obstacles
ss.ViewModel = { -- Viewmodel animations
    Standing = ACT_VM_IDLE,         -- Humanoid form
    Squid    = ACT_VM_IDLE_LOWERED, -- Squid form
    Throwing = ACT_VM_PULLPIN,      -- About to throw sub weapon
    Throw    = ACT_VM_THROW,        -- Actual throw animation
}

-- HACKHACK
-- This is a list of Splatoon maps available in Garry's Mod.
-- They seem unusual and hide our ink.
ss.SplatoonMapPorts = {
    gm_arena_octostomp                  = true,
    gm_blackbelly_skatepark             = true,
    gm_blackbelly_skatepark_night       = true,
    gm_bluefin_depot                    = true,
    gm_bluefin_depot_night              = true,
    gm_bluefin_depot_oct                = true,
    gm_bluefin_depot_rvl                = true,
    gm_camp_triggerfish_day_closegate   = true,
    gm_camp_triggerfish_day_opengate    = true,
    gm_camp_triggerfish_night_closegate = true,
    gm_camp_triggerfish_night_opengate  = true,
    gm_flounder_heights_day             = true,
    gm_flounder_heights_night           = true,
    gm_hammerhead_bridge                = true,
    gm_hammerhead_bridge_night          = true,
    gm_inkopolis_b1                     = true,
    gm_inkopolis_plaza_day              = true,
    gm_inkopolis_plaza_fes_day          = true,
    gm_inkopolis_plaza_fes_night        = true,
    gm_inkopolis_plaza_night            = true,
    gm_inkopolis_square                 = true,
    gm_kelp_dome                        = true,
    gm_kelp_dome_fes                    = true,
    gm_mako_mart                        = true,
    gm_mako_mart_night                  = true,
    gm_mc_princess_diaries              = true,
    gm_moray_towers                     = true,
    gm_new_albacore_hotel_day           = true,
    gm_new_albacore_hotel_night         = true,
    gm_octo_showdown                    = true,
    gm_octo_valley_hubworld             = true,
    gm_octo_valley_hubworld_night       = true,
    gm_port_mackerel_day                = true,
    gm_port_mackerel_night              = true,
    gm_skipper_pavilion_day             = true,
    gm_skipper_pavilion_night           = true,
    gm_shootingrange_splat1             = true,
    gm_shootingrange_splat1_night       = true,
    gm_snapper_canal                    = true,
    gm_snapper_canal_night              = true,
    gm_spawning_grounds_fog_high        = true,
    gm_spawning_grounds_fog_low         = true,
    gm_spawning_grounds_fog_normal      = true,
    gm_spawning_grounds_high            = true,
    gm_spawning_grounds_low             = true,
    gm_spawning_grounds_night_high      = true,
    gm_spawning_grounds_night_low       = true,
    gm_spawning_grounds_night_normal    = true,
    gm_spawning_grounds_normal          = true,
    gm_the_reef_day                     = true,
    gm_the_reef_night                   = true,
    gm_tutorial                         = true,
    gm_tutorial_night                   = true,
    humpback_pump_track_day             = true,
    humpback_pump_track_night           = true,
}

do -- Color tables
    ---@type table<integer, {[1]: integer, [2]: number, [3]: number, [4]: integer}>
    local inkcolors = include "splatoonsweps/constants/inkcolors.lua"
    for i, t in ipairs(inkcolors) do
        local c = HSVToColor(t[1], t[2], t[3])
        ss.InkColors[i]       = ColorAlpha(c, c.a)
        ss.CrosshairColors[i] = t[4]
        ss.MAX_COLORS         = #ss.InkColors
    end

    ss.COLOR_BITS = select(2, math.frexp(ss.MAX_COLORS)) ---@type integer
end

game.AddParticles "particles/splatoonsweps.pcf"
for _, p in pairs(ss.Particles) do PrecacheParticleSystem(p) end

---Gets actual color from color ID
---@param colorid integer|string
---@return Color
function ss.GetColor(colorid)
    return ss.InkColors[tonumber(colorid)]
end

if game.GetMap() == "gm_inkopolis_b1" then
    ss.SquidSolidMask          = bit.band(MASK_PLAYERSOLID, bit.bnot(CONTENTS_PLAYERCLIP))
    ss.SquidSolidMaskBrushOnly = bit.band(MASK_PLAYERSOLID_BRUSHONLY, bit.bnot(CONTENTS_PLAYERCLIP))
    ss.MASK_GRATE              = CONTENTS_PLAYERCLIP
else
    ss.SquidSolidMask          = MASK_SHOT
    ss.SquidSolidMaskBrushOnly = MASK_SHOT_PORTAL
    ss.MASK_GRATE              = bit.bor(CONTENTS_GRATE, CONTENTS_MONSTER)
end

local fps = 60
local inklingspeed = .96 * fps -- Distance units per second

---1 meter = 39.3701 inches
local meterToInch = 39.3701

---1 for entity scale, 16 / 12 for map scale
---I don't know why but using reciprocal of this fits the shooting range map
---(gm_shootingrange_splat1)
local inchToHammerUnits = 1 and 1 / (16 / 12)

---Height of Inkling girl from Splatoon Inkling Playermodel in Hammer units
local inklingPlayermodelHeight = 53
local inklingPlayermodelHeightInMeters = inklingPlayermodelHeight / meterToInch

---The real height of inkling model ripped from the original game in distance units
local inklingRealHeight = 13.5641
local inklingRealHeightInMeters = inklingRealHeight * 0.1
local unitConversionFix = inklingPlayermodelHeightInMeters / inklingRealHeightInMeters

---DU to HU, Distance units in Splatoon to Hammer units
---Distance between two lines in the shooting range = 50 DU = 5 meters
--- -> 1 DU = 0.1 meters = 0.1 * 39.3701 [inches = Hammer units (entity scale)]
local dutohu = 0.1 * meterToInch * inchToHammerUnits * unitConversionFix

ss.eps                      = 1e-9 -- Epsilon, representing "close-to-zero"
ss.vector_one               = Vector(1, 1, 1)
ss.MaxInkAmount             = 100
ss.SquidBoundHeight         = 32
ss.SquidViewOffset          = vector_up * 24
ss.InkGridSize              = 12                          -- in Hammer Units
ss.DisruptedSpeed           = .45                         -- Disruptor's debuff factor
ss.DisruptorDuration        = 5                           -- Disruptor lasts this seconds
ss.PointSensorDuration      = 8                           -- It was 10 sec. until version 2.1.0.
ss.InklingJumpPower         = 250                         -- Base jump power
ss.InklingSpeedMulSubWeapon = .75                         -- Speed multiplier when holding MOUSE2
ss.JumpPowerMulOnEnemyInk   = .75                         -- Jump power multiplier when on enemy ink
ss.JumpPowerMulDisrupted    = .6                          -- Jump power multiplier when disrupted
ss.SuperJumpWaitTime        = 1.5                         -- Time to wait for super jump
ss.SuperJumpTravelTime      = 2.8                         -- Time from start to end of the super jump
ss.SuperJumpVoiceDelay      = 0.8                         -- Delay to play super jump voice
ss.ToHammerUnits            = dutohu                      -- = 3.53, Splatoon distance units -> Hammer distance units
ss.ToHammerUnitsPerSec      = dutohu * fps                -- = 212, Splatoon du/s -> Hammer du/s
ss.ToHammerUnitsPerSec2     = dutohu * fps * fps          -- = 12720, Splatoon du/s^2 -> Hammer du/s^2
ss.ToHammerHealth           = 100                         -- Health is normalized in Splatoon (0--1)
ss.FrameToSec               = 1 / fps                     -- = 0.016667, Constants for time conversion
ss.SecToFrame               = fps                         -- = 60, Constants for time conversion
ss.mDegRandomY              = .5                          -- Shooter spread angle, yaw (need to be validated)
ss.SquidSpeedOutofInk       = .45                         -- Squid speed coefficient when it goes out of ink.
ss.CameraFadeDistance       = 100^2                       -- Thirdperson model fade distance[Hammer units^2]
ss.InkDropGravity           = 1 * ss.ToHammerUnitsPerSec2 -- The gravity acceleration of ink drops[Hammer units/s^2]
ss.ShooterAirResist         = 0.25                        -- Air resistance of Shooter's ink.  The velocity will be multiplied by (1 - AirResist).
ss.RollerAirResist          = 0.1                         -- Air resistance of Roller's splash.
ss.CrosshairBaseAlpha       = 64
ss.CrosshairBaseColor       = ColorAlpha(color_white, ss.CrosshairBaseAlpha)
ss.CrosshairDarkColor       = ColorAlpha(color_black, ss.CrosshairBaseAlpha)
ss.SquidTrace = {
    start          = vector_origin,
    endpos         = vector_origin,
    filter         = {},
    mask           = ss.SquidSolidMask,
    collisiongroup = COLLISION_GROUP_PLAYER_MOVEMENT,
    mins           = -ss.vector_one,
    maxs           = ss.vector_one,
}

ss.InklingBaseSpeed        = ss.ToHammerUnits * inklingspeed     -- Walking speed [Splatoon units/60frame]
ss.SquidBaseSpeed          = ss.ToHammerUnits * 1.923 * fps      -- Swimming speed [Splatoon units/60frame]
ss.OnEnemyInkSpeed         = ss.ToHammerUnits * inklingspeed / 4 -- On enemy ink speed[Splatoon units/60frame]
ss.mColRadius              = ss.ToHammerUnits * 2                -- Shooter's ink collision radius[Splatoon units]
ss.mPaintNearDistance      = ss.ToHammerUnits * 11               -- Start decreasing distance[Splatoon units]
ss.mPaintFarDistance       = ss.ToHammerUnits * 200              -- Minimum radius distance[Splatoon units]
ss.mSplashDrawRadius       = ss.ToHammerUnits * 3                -- Ink drop position random spread value[Splatoon units]
ss.mSplashColRadius        = ss.ToHammerUnits * 1.5              -- Ink drop collision radius[Splatoon units]
ss.AimDuration             = ss.FrameToSec    * 20               -- Change hold type
ss.CrouchDelay             = ss.FrameToSec    * 6                -- Cannot crouch for some frames after firing.
ss.EnemyInkCrouchEndurance = ss.FrameToSec    * 20               -- Time to force inklings to stand up when they're on enemy ink.
ss.HealDelay               = ss.FrameToSec    * 60               -- Time to heal again after taking damage.
ss.RollerRunoverStopFrame  = ss.FrameToSec    * 30               -- Stopping time when inkling tries to run over.
ss.ShooterTrailDelay       = ss.FrameToSec    * 2                -- Time to start to move the latter half of shooter's ink.
ss.SubWeaponThrowTime      = ss.FrameToSec    * 25               -- Duration of TPS sub weapon throwing animation.

ss.UnitsConverter = {
    ["du"]     = ss.ToHammerUnits,
    ["du/f"]   = ss.ToHammerUnitsPerSec,
    ["du/f^2"] = ss.ToHammerUnitsPerSec2,
    ["f"]      = ss.FrameToSec,
    ["ink"]    = ss.MaxInkAmount,
}
