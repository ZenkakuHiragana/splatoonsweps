
AddCSLuaFile()
local ss = SplatoonSWEPs
if not ss then return end

--------------------------------------------------------------------------------
-- Splatling spins
--------------------------------------------------------------------------------

sound.Add { -- Heavy Splatling / Deco / Remix, 1st spin-up
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.HeavySplatling",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/splatling/heavysplatling0.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add { -- Heavy Splatling / Deco / Remix, 2nd spin-up
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.HeavySplatling2",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/splatling/heavysplatling1.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add { -- Heavy Splatling / Deco / Remix, Fully charged
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.HeavySplatlingFull",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/splatling/heavysplatling2.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add { -- Hydra Splatling / Custom, 1st spin-up
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.HydraSplatling",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/splatling/hydrasplatling0.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add { -- Hydra Splatling / Custom, 2nd spin-up
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.HydraSplatling2",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/splatling/hydrasplatling1.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add { -- Hydra Splatling / Custom, Fully charged
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.HydraSplatlingFull",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/splatling/hydrasplatling2.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add { -- Mini Splatling / Zink / Refurbished, 1st spin-up
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.MiniSplatling",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/splatling/minisplatling0.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add { -- Mini Splatling / Zink / Refurbished, 2nd spin-up
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.MiniSplatling2",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/splatling/minisplatling1.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add { -- Mini Splatling / Zink / Refurbished, Fully charged
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.MiniSplatlingFull",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/splatling/minisplatling2.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}
