
AddCSLuaFile()
local ss = SplatoonSWEPs
if not ss then return end

--------------------------------------------------------------------------------
-- Slosher
--------------------------------------------------------------------------------

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.Slosher",
    level = ss.WeaponSoundLevel,
    sound = {
        "splatoonsweps/weapons/slosher/slosher1.wav",
        "splatoonsweps/weapons/slosher/slosher2.wav",
    },
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.TriSlosher",
    level = ss.WeaponSoundLevel,
    sound = {
        "splatoonsweps/weapons/slosher/trislosher.wav",
        "splatoonsweps/weapons/slosher/slosher2.wav",
    },
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.SloshingMachine",
    level = ss.WeaponSoundLevel,
    sound = {
        "splatoonsweps/weapons/slosher/machine1.wav",
        "splatoonsweps/weapons/slosher/machine2.wav",
    },
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}
