
AddCSLuaFile()
local ss = SplatoonSWEPs
if not ss then return end

--------------------------------------------------------------------------------
-- Sub weapons
--------------------------------------------------------------------------------

ss.BombAvailable = Sound "splaoonsweps/weapons/sub/available.wav"

-- TODO: make it loop these files
ss.BombAlert = Sound "splatoonsweps/weapons/sub/bombalert.mp3"
ss.SeekerAlert = Sound "splatoonsweps/weapons/sub/seeker/alert.wav"
ss.SeekerRunning = Sound 'splatoonsweps/weapons/sub/seeker/running.wav'
ss.SplashShieldRunning = Sound "splatoonsweps/weapons/sub/splashshield/running.wav"
ss.SplrinkerRunning = Sound "splatoonsweps/weapons/sub/sprinkler/running.wav"

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
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.BeakonDeploy",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/beakon/deploy.mp3",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.BeakonIdle",
    level = ss.WeaponSoundLevel,
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
    name = "SplatoonSWEPs.InkMineAlert",
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
    name = "SplatoonSWEPs.SeekerFar",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/seeker/seekfar.wav",
    volume = ss.WeaponSoundVolume,
    pitch = 100,
}

sound.Add {
    channel = CHAN_WEAPON,
    name = "SplatoonSWEPs.SeekerNear",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/seeker/seeknear.wav",
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
    name = "SplatoonSWEPs.SplashShieldDeproy",
    level = ss.WeaponSoundLevel,
    sound = "splatoonsweps/weapons/sub/splashshield/deploy.wav",
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
        level = ss.WeakShotLevel,
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