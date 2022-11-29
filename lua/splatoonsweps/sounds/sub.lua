
AddCSLuaFile()
local ss = SplatoonSWEPs
if not ss then return end

--------------------------------------------------------------------------------
-- Sub weapons
--------------------------------------------------------------------------------

ss.BombAvailable = Sound "splatoonsweps/weapons/sub/available.wav"
ss.BombAlert = Sound "splatoonsweps/weapons/sub/bombalert.mp3"
ss.SeekerAlert = Sound "splatoonsweps/weapons/sub/seeker/alert.wav"
ss.SeekerRunning = Sound "splatoonsweps/weapons/sub/seeker/running.wav"
ss.SeekerFar = Sound "splatoonsweps/weapons/sub/seeker/seekfar.wav"
ss.SeekerNear = Sound "splatoonsweps/weapons/sub/seeker/seeknear.wav"
ss.SeekerTargetChanged = Sound "splatoonsweps/weapons/beep.mp3" -- TODO: Get a correct sound
ss.SplashWallRunning = Sound "splatoonsweps/weapons/sub/splashwall/running.wav"
ss.SprinklerRunning = Sound "splatoonsweps/weapons/sub/sprinkler/running.wav"

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.BombExplosion",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/explosion/bomb.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.BurstBombExplosion",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/explosion/burstbomb.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.SubWeaponThrown",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/bombthrown.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.SubWeaponPut",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/put.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.SubWeaponDestroy",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/destroy.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.SubWeaponSinkInWater",
    level = ss.WeakShotLevel,
    sound = "splatoonsweps/weapons/sub/sinkinwater.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_BODY,
    name = "SplatoonSWEPs.BeakonDeploy",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/beakon/deploy.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.BeakonIdle",
    level = 65,
    sound = "splatoonsweps/weapons/sub/beakon/ready.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.Disruptor",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/disruptor.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.DisruptorTaken",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/player/disruptortaken.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.DisruptorWornOff",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/player/disruptorwornoff.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.InkmineAlert",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/inkminealert.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.PointSensor",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/pointsensor.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.PointSensorHit",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/player/pointsensorhit.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.PointSensorTaken",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/player/pointsensortaken.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.PointSensorLeft",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/player/pointsensorleft.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.SeekerThrown",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/seeker/start.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.SeekerSelect",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/beep.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 80,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.SeekerAlert",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/seeker/alert.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_BODY,
    name = "SplatoonSWEPs.SeekerRunning",
    level = ss.WeakShotLevel,
    sound = "splatoonsweps/weapons/sub/seeker/running.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_VOICE,
    name = "SplatoonSWEPs.SeekerFar",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/seeker/seekerfar.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_VOICE,
    name = "SplatoonSWEPs.SeekerNear",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/seeker/seekernear.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.SplashWallDeploy",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/splashwall/deploy.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.SprinklerDestroy",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/sprinkler/destroy.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.SuctionBomb",
    level = ss.WeakShotLevel,
    sound = "splatoonsweps/weapons/sub/suctionbomb.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

ss.PrecacheSoundList {
    {
        channel = CHAN_AUTO,
        name = "SplatoonSWEPs.BeakonRadio",
        level = 65,
        sound = "splatoonsweps/weapons/sub/beakon/radio%d.mp3",
        volume = ss.WeaponSoundVolume,
        pitch = 100,
    },
    {
        channel = CHAN_BODY,
        name = "SplatoonSWEPs.SplatBombHitWorld",
        level = ss.WeakShotLevel,
        sound = "splatoonsweps/weapons/sub/splatbomb/plastichit%d.wav",
        volume = ss.WeaponSoundVolume,
        pitch = 100,
    }
}
