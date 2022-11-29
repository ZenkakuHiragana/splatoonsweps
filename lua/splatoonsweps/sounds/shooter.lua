
AddCSLuaFile()
local ss = SplatoonSWEPs
if not ss then return end

--------------------------------------------------------------------------------
-- Shooter gunfires
--------------------------------------------------------------------------------

sound.Add {
    channel = CHAN_AUTO,
    name = "SplatoonSWEPs.BlasterExplosion",
    level = 85,
    sound = "splatoonsweps/explosion/blaster.wav",
    volume = 1,
    pitch = ss.WeaponSoundPitch,
}

sound.Add {
    channel = CHAN_AUTO,
    name = "SplatoonSWEPs.BlasterHitWall",
    level = 85,
    sound = "splatoonsweps/explosion/blasterwall.mp3",
    volume = 1,
    pitch = ss.WeaponSoundPitch,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.EmptyShot",
    level = ss.WeakShotLevel,
    sound = "splatoonsweps/weapons/shooter/emptyshot.wav",
    volume = ss.WeaponSoundVolume,
    pitch = {85, 95},
}

sound.Add { -- .52 Gallon / Deco
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.52",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/shooter/52.wav",
    volume = ss.WeaponSoundVolume,
    pitch = ss.WeaponSoundPitch,
}

sound.Add { -- .96 Gallon / Deco
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.96",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/shooter/96.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = ss.WeaponSoundPitch,
}

sound.Add { -- Aerospray MG / RG / PG
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.Aerospray",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/shooter/aerospray.wav",
    volume = ss.WeaponSoundVolume,
    pitch = ss.WeaponSoundPitch,
}

sound.Add { -- Blasters except Rapid Blaster series
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.Blaster",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/shooter/blaster.wav",
    volume = ss.WeaponSoundVolume,
    pitch = ss.WeaponSoundPitch,
}

sound.Add { -- Dual Squelcher / Custom
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.Dual",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/shooter/dual.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = ss.WeaponSoundPitch,
}

sound.Add { -- H-3 Nozzlenose / D / Cherry
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.H-3",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/shooter/h-3.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = ss.WeaponSoundPitch,
}

sound.Add { -- Jet Squelcher / Custom
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.Jet",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/shooter/jet.wav",
    volume = ss.WeaponSoundVolume,
    pitch = ss.WeaponSoundPitch,
}

sound.Add { -- L-3 Nozzlenose / D
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.L-3",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/shooter/l-3.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = ss.WeaponSoundPitch,
}

sound.Add { -- Octoshot Replica
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.Octoshot",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/shooter/octoshot.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = ss.WeaponSoundPitch,
}

sound.Add { -- Rapid Blaster / Deco / Pro / Pro Deco
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.RapidBlaster",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/shooter/rapidblaster.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = ss.WeaponSoundPitch,
}

sound.Add { -- Splash-o-matic / Neo
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.Splash-o-matic",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/shooter/splash-o-matic.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = {95, 115}, -- +5 Pitch
}

sound.Add { -- Splattershot / Tentatek / Wasabi
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.Splattershot",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/shooter/splattershot.wav",
    volume = ss.WeaponSoundVolume,
    pitch = ss.WeaponSoundPitch,
}

sound.Add { -- Splattershot Jr. / Custom
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.SplattershotJr",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/shooter/splattershotjr.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = ss.WeaponSoundPitch,
}

sound.Add { -- Splattershot Pro / Forge / Berry
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.SplattershotPro",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/shooter/splattershotpro.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = ss.WeaponSoundPitch,
}

sound.Add { -- Sploosh-o-matic / Neo / 7
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.Sploosh-o-matic",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/shooter/sploosh-o-matic.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = ss.WeaponSoundPitch,
}

sound.Add { -- N-Zap 85 / 89 / 83
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.Zap",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/shooter/zap.wav",
    volume = ss.WeaponSoundVolume,
    pitch = ss.WeaponSoundPitch,
}
