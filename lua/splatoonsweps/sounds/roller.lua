
AddCSLuaFile()
local ss = SplatoonSWEPs
if not ss then return end

--------------------------------------------------------------------------------
-- Roller
--------------------------------------------------------------------------------

ss.EmptyRoll = Sound "splatoonsweps/weapons/roller/emptyroll.wav"
ss.EmptyRun = Sound "splatoonsweps/weapons/roller/emptyrun.wav"
ss.CarbonRollerRoll = Sound "splatoonsweps/weapons/roller/carbonroller_roll.wav"
ss.DynamoRollerRoll = Sound "splatoonsweps/weapons/roller/dynamoroller_roll.wav"
ss.InkBrushRun = Sound "splatoonsweps/weapons/roller/inkbrush_run.wav"
ss.OctoBrushRun = Sound "splatoonsweps/weapons/roller/octobrush_run.wav"
ss.SplatRollerRoll = Sound "splatoonsweps/weapons/roller/splatroller_roll.wav"
sound.Add { -- Roller holster sound
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.RollerHolster",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/roller/holster.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add { -- Roller empty swing
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.EmptySwing",
    level = 45,
    sound = "splatoonsweps/weapons/roller/emptyswing.wav",
    volume = 0.5,
    pitch = 35,
}

sound.Add { -- Splat Roller / Krak-On / CoroCoro, Dynamo Roller / Gold / Tempered, Pre-swing
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.RollerPreSwing",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/roller/preswing.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add { -- Carbon Roller / Deco, Pre-swing
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.CarbonRollerPreSwing",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/roller/carbonroller_preswing.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

ss.PrecacheSoundList {
    { -- Inkbrush / Nouveau, Swing
        channel = CHAN_WEAPON,
        name = "SplatoonSWEPs.RollerSplashLight",
        level = 75,
        sound = "splatoonsweps/weapons/roller/inkbrush%d.wav",
        volume = 1,
        pitch = 100,
    },
    { -- Octobrush / Nouveau, Swing
        channel = CHAN_WEAPON,
        name = "SplatoonSWEPs.RollerSplashMedium",
        level = 75,
        sound = "splatoonsweps/weapons/roller/octobrush%d.wav",
        volume = 1,
        pitch = 100,
    },
    { -- Splat Roller / Krak-On / CoroCoro, Dynamo Roller / Gold / Tempered, Swing
        channel = CHAN_AUTO,
        name = "SplatoonSWEPs.RollerSwing",
        level = ss.WeaponSoundLevel,
        sound = "splatoonsweps/weapons/roller/swing%d.wav",
        volume = ss.WeaponSoundVolume,
        pitch = 100,
    },
    { -- Carbon Roller / Deco, Swing
        channel = CHAN_AUTO,
        name = "SplatoonSWEPs.CarbonRollerSwing",
        level = ss.WeaponSoundLevel,
        sound = "splatoonsweps/weapons/roller/swing%d.wav",
        volume = ss.WeaponSoundVolume,
        pitch = 120,
    },
}
