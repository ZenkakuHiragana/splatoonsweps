
-- Weapon information in default SWEP structure.
local ss = SplatoonSWEPs
if not ss then return end

if CLIENT then
    SWEP.Author = ss.Text.Author
    SWEP.BobScale = 1
    SWEP.BounceWeaponIcon = true
    SWEP.DrawAmmo = true
    SWEP.DrawCrosshair = true
    SWEP.DrawWeaponInfoBox = true
    SWEP.Instructions = ss.Text.Instructions
    SWEP.Purpose = ss.Text.Purpose
    SWEP.RenderGroup = RENDERGROUP_BOTH
    SWEP.SpeechBubbleLid = surface.GetTextureID "gui/speech_lid"
    SWEP.SwayScale = 1
    SWEP.UseHands = true
    SWEP.ViewModelFOV = 62
else
    SWEP.AutoSwitchFrom = false
    SWEP.AutoSwitchTo = false
    SWEP.Weight = 1
end

SWEP.PrintName = "Inkling base"
SWEP.Spawnable = false
SWEP.HoldType = "crossbow"
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.IsSplatoonWeapon = true
SWEP.m_WeaponDeploySpeed = 2

SWEP.Secondary = SWEP.Secondary or {}
SWEP.Secondary.Automatic = true
SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Ammo = "Ink"
