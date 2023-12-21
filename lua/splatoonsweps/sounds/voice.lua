
AddCSLuaFile()

---@class ss
local ss = SplatoonSWEPs
if not ss then return end

---@param soundname string
local function PrecacheVoice(soundname)
    local foldername = soundname:lower()
    ss.PrecacheSoundList {
        {
            channel = CHAN_VOICE,
            name = "SplatoonSWEPs_Voice." .. soundname .. "_SquidFemale",
            level = 75,
            sound = "splatoonsweps/vo/" .. foldername .. "/squid_female%d.wav",
            volume = 1,
            pitch = 100,
        },
        {
            channel = CHAN_VOICE,
            name = "SplatoonSWEPs_Voice." .. soundname .. "_SquidMale",
            level = 75,
            sound = "splatoonsweps/vo/" .. foldername .. "/squid_male%d.wav",
            volume = 1,
            pitch = 100,
        },
        {
            channel = CHAN_VOICE,
            name = "SplatoonSWEPs_Voice." .. soundname .. "_OctoMale",
            level = 75,
            sound = "splatoonsweps/vo/" .. foldername .. "/octo_male%d.wav",
            volume = 1,
            pitch = 100,
        },
        {
            channel = CHAN_VOICE,
            name = "SplatoonSWEPs_Voice." .. soundname .. "_OctoFemale",
            level = 75,
            sound = "splatoonsweps/vo/" .. foldername .. "/octo_female%d.wav",
            volume = 1,
            pitch = 100,
        },
    }
end

PrecacheVoice "SuperJump"
PrecacheVoice "SpecialStart"
