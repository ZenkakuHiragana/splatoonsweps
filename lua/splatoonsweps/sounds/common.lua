
-- Sound script registrations

AddCSLuaFile()

---@class ss
local ss = SplatoonSWEPs
if not ss then return end

ss.WeakShotLevel = 75
ss.WeaponSoundLevel = 80
ss.WeaponSoundVolume = 1
ss.WeaponSoundPitch = {90, 110}
ss.EnemyInkSound = Sound "splatoonsweps/player/onenemyink.wav"
ss.SwimSound = Sound "splatoonsweps/player/swimloop.wav"
ss.TankEmpty = Sound "splatoonsweps/player/tankempty.wav"
---@param soundList SoundData[]
function ss.PrecacheSoundList(soundList)
    for _, soundData in ipairs(soundList) do
        local i = 0
        local template = soundData.sound
        local str = template:format(i)
        soundData.sound = {}

        while file.Exists("sound/" .. str, "GAME") do
            i = i + 1
            soundData.sound[#soundData.sound + 1] = Sound(str)
            str = template:format(i)
        end

        sound.Add(soundData)
    end
end

include "charger.lua"
include "roller.lua"
include "shooter.lua"
include "slosher.lua"
include "special.lua"
include "splatling.lua"
include "sub.lua"
include "voice.lua"

sound.Add {
    channel = CHAN_AUTO,
    name = "SplatoonSWEPs.TakeDamage",
    level = 0,
    sound = "splatoonsweps/player/takedamage.wav",
    volume = 1,
    pitch = 100,
}

sound.Add {
    channel = CHAN_STATIC,
    name = "SplatoonSWEPs.DealDamage",
    level = 90,
    sound = "splatoonsweps/player/dealdamagenormal.wav",
    volume = 1,
    pitch = 100,
}

sound.Add {
    channel = CHAN_STATIC,
    name = "SplatoonSWEPs.DealDamageCritical",
    level = 100,
    sound = "splatoonsweps/player/dealdamagecritical.wav",
    volume = 1,
    pitch = 100,
}

sound.Add {
    channel = CHAN_STATIC,
    name = "SplatoonSWEPs.DealDamageInvincible",
    level = 90,
    sound = "splatoonsweps/player/dealdamageinvincible.wav",
    volume = 1,
    pitch = 100,
}

sound.Add {
    channel = CHAN_AUTO,
    name = "SplatoonSWEPs_Player.InkDiveShallow",
    level = 75,
    sound = "splatoonsweps/player/inkdiveshallow.wav",
    volume = 1,
    pitch = {90, 110},
}

sound.Add {
    channel = CHAN_AUTO,
    name = "SplatoonSWEPs_Player.InkDiveDeep",
    level = 75,
    sound = "splatoonsweps/player/inkdivedeep.wav",
    volume = 1,
    pitch = 100,
}


sound.Add {
    channel = CHAN_ITEM,
    name = "SplatoonSWEPs_Player.SuperJump",
    level = 75,
    sound = "splatoonsweps/player/superjump.wav",
    volume = 1,
    pitch = 100,
}
sound.Add {
    channel = CHAN_ITEM,
    name = "SplatoonSWEPs_Player.SuperJumpAttention",
    level = 60,
    sound = "splatoonsweps/player/attentionjump.wav",
    volume = 1,
    pitch = 100,
}
sound.Add {
    channel = CHAN_ITEM,
    name = "SplatoonSWEPs_Player.SuperJumpLand",
    level = 100,
    sound = "splatoonsweps/player/superjumpland.wav",
    volume = 1,
    pitch = 100,
}

sound.Add {
    channel = CHAN_ITEM,
    name = "SplatoonSWEPs_Player.ToHuman",
    level = 75,
    sound = "splatoonsweps/player/tohuman.wav",
    volume = 1,
    pitch = 100,
}

sound.Add {
    channel = CHAN_ITEM,
    name = "SplatoonSWEPs_Player.ToSquid",
    level = 75,
    sound = "splatoonsweps/player/tosquid.wav",
    volume = 1,
    pitch = 100,
}

sound.Add {
    channel = CHAN_AUTO,
    name = "SplatoonSWEPs_Player.DeathExplosion",
    level = 85,
    sound = "splatoonsweps/explosion/playerdeath.wav",
    volume = 1,
    pitch = ss.WeaponSoundPitch,
}

sound.Add {
    channel = CHAN_STREAM,
    name = "SplatoonSWEPs_Player.SpecialReady",
    level = 85,
    sound = "splatoonsweps/player/specialready.wav",
    volume = 1,
    pitch = 100,
}

ss.PrecacheSoundList {
    {
        channel = CHAN_BODY,
        name = "SplatoonSWEPs_Ink.HitWorld",
        level = 75,
        sound = "splatoonsweps/ink/hit%d.wav",
        volume = 1,
        pitch = 100,
    },
    {
        channel = CHAN_BODY,
        name = "SplatoonSWEPs_Player.InkFootstep",
        level = 75,
        sound = "splatoonsweps/player/footsteps/slime%d.wav",
        volume = 1,
        pitch = 80,
    },
}
