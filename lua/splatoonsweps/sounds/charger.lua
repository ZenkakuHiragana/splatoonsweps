
AddCSLuaFile()
local ss = SplatoonSWEPs
if not ss then return end

--------------------------------------------------------------------------------
-- Charger gunfires
--------------------------------------------------------------------------------

ss.ChargerAim = Sound "splatoonsweps/weapons/charger/aim.wav"
ss.ChargerBeep = Sound "splatoonsweps/weapons/beep.mp3"
sound.Add {
    channel = CHAN_ITEM,
    name = "SplatoonSWEPs.ChargerPreFire",
    level = 75,
    sound = "splatoonsweps/weapons/charger/prefire.wav",
    volume = 1,
    pitch = 100,
}

sound.Add { -- Splat Charger / Kelp / Bento
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.SplatCharger",
    level = ss.WeakShotLevel,
    sound = "splatoonsweps/weapons/charger/splatcharger.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add { -- Splat Charger / Kelp / Bento, Fully charged
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.SplatChargerFull",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/charger/splatchargerfull.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add { -- E-Liter 3K / Custom
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.Eliter3K",
    level = ss.WeakShotLevel,
    sound = "splatoonsweps/weapons/charger/eliter.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add { -- E-Liter 3K / Custom, Fully charged
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.Eliter3KFull",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/charger/eliterfull.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add { -- Classic Squiffer / New / Fresh
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.Squiffer",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/charger/squiffer.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add { -- Bamboozler Mk.I / Mk.II / MK.III
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.Bamboozler",
    level = ss.WeakShotLevel,
    sound = "splatoonsweps/weapons/charger/bamboozler.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add { -- Bamboozler Mk.I / Mk.II / MK.III, Fully charged
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.BamboozlerFull",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/charger/bamboozlerfull.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}
