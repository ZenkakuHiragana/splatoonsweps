
AddCSLuaFile()
local ss = SplatoonSWEPs
if not (ss and SWEP) then return end
SWEP.ADSAngOffset = Angle(0, 0, 0)
SWEP.ADSAngOffset2 = Angle(2, 0, 0)
SWEP.ADSOffset = Vector(-6, 0, 4.6)
SWEP.ADSOffset2 = Vector(-8, .04, 2.93)
SWEP.ShootSound = "SplatoonSWEPs.Zap"
SWEP.Special = "echolocator"
SWEP.Sub = "splatbomb"
SWEP.Variations = {
    {
        ClassName = "nzap89",
        Customized = true,
        Skin = 1,
        Special = "inkstrike",
        Sub = "sprinkler",
    },
    {
        ClassName = "nzap83",
        SheldonsPicks = true,
        Skin = 2,
        Special = "kraken",
        Sub = "pointsensor",
    },
}

ss.SetPrimary(SWEP, {
    mRepeatFrame = 5,
    mTripleShotSpan = 0,
    mInitVel = 22,
    mDegRandom = 6,
    mDegJumpRandom = 15,
    mSplashSplitNum = 11,
    mKnockBack = 0,
    mInkConsume = 0.008,
    mInkRecoverStop = 20,
    mMoveSpeed = 0.72,
    mDamageMax = 0.28,
    mDamageMin = 0.14,
    mDamageMinFrame = 15,
    mStraightFrame = 4,
    mGuideCheckCollisionFrame = 8,
    mCreateSplashNum = 1.5,
    mCreateSplashLength = 110,
    mDrawRadius = 2.5,
    mColRadius = 2,
    mPaintNearDistance = 11,
    mPaintFarDistance = 200,
    mPaintNearRadius = 19.2,
    mPaintFarRadius = 18,
    mSplashDrawRadius = 3,
    mSplashColRadius = 1.5,
    mSplashPaintRadius = 12,
    mDegBias = 0.25,
    mDegBiasKf = 0.02,
    mDegJumpBias = 0.4,
    mDegJumpBiasFrame = 60,
})

local function RefreshViewModel(self)
    if not (IsValid(self:GetOwner()) and self:GetOwner():IsPlayer()) then return end
    local ispistol = self:GetNWBool "nzap_pistolstyle"
    local mdl = ispistol and self.ViewModel1 or self.ViewModel0
    local vm = self:GetViewModel()
    if not IsValid(vm) then return end
    if vm:GetModel() == mdl then return end
    if not self:IsFirstTimePredicted() then return end
    local cycle = vm:GetCycle()
    local rate = vm:GetPlaybackRate()
    local seq = vm:GetSequence()
    vm:SetWeaponModel(mdl, self)
    vm:SendViewModelMatchingSequence(seq)
    vm:SetPlaybackRate(rate)
    vm:SetCycle(cycle)
    self.ViewModel = mdl
end

function SWEP:SharedDeploy()
    ss.ProtectedCall(self.BaseClass.SharedDeploy, self)
    RefreshViewModel(self)
end

function SWEP:Think()
    ss.ProtectedCall(self.BaseClass.Think, self)
    RefreshViewModel(self)
end

function SWEP:CustomActivity()
    local armpos = ss.ProtectedCall(self.BaseClass.CustomActivity, self)
    if not armpos then return end
    if self:GetNWBool "nzap_pistolstyle" then return "revolver" end
    return armpos
end

if SERVER then return end
function SWEP:GetArmPos()
    local armpos = ss.ProtectedCall(self.BaseClass.GetArmPos, self)
    if not armpos then return end
    local pistol = self:GetNWBool "nzap_pistolstyle"
    local offset = pistol and self.ADSOffset2 or self.ADSOffset
    local ang = pistol and self.ADSAngOffset2 or self.ADSAngOffset
    self.IronSightsPos[6] = self.IronSightsPos[5] + offset
    self.IronSightsAng[6] = self.IronSightsAng[5] + ang
    return 6
end
