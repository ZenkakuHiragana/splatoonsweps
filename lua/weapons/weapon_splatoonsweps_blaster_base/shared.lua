
local ss = SplatoonSWEPs
if not ss then return end
SWEP.Base = "weapon_splatoonsweps_shooter"
SWEP.IsBlaster = true

function SWEP:GetPreFireDelay()
    if self:Crouching() then
        return self.Parameters.mPreDelayFrm_SquidMain
    else
        return self.Parameters.mPreDelayFrm_HumanMain
    end
end

function SWEP:SharedInit()
    local p = self.Parameters
    self:GetBase().SharedInit(self)
    table.Merge(self.Projectile, {
        ColRadiusEntity = p.mColRadius,
        ColRadiusWorld = p.mColRadius,
        IsCritical = true,
        PaintNearRatio = 1,
        PaintFarRatio = 1,
    })
end

function SWEP:SharedDeploy()
    self:GetBase().SharedDeploy(self)
    self:SetFireDelay(math.huge)
end

function SWEP:SharedPrimaryAttack(able)
    local p = self.Parameters
    local ts = ss.GetTimeScale(self:GetOwner())
    local time = CurTime() + self:GetPreFireDelay() / ts
    self:SetNextPrimaryFire(CurTime() + p.mRepeatFrame / ts)
    self:SetAimTimer(time)
    self:SetCooldown(math.max(self:GetCooldown(), time))
    self:SetFireDelay(time)
end

function SWEP:Move(ply)
    self:GetBase().Move(self, ply)
    if CurTime() < self:GetFireDelay() then return end
    if not self:CheckCanStandup() then return end

    local p = self.Parameters
    local ts = ss.GetTimeScale(ply)
    local d = p.mPostDelayFrm_Main / ts
    self:SetFireDelay(math.huge)
    self:SetReloadDelay(p.mInkRecoverStop)
    if self:GetInk() < p.mInkConsume then
        d = self:GetPreFireDelay() / ts
        self:PlayEmptySound()
        self:SetCooldown(math.max(self:GetCooldown(), CurTime() + d))
        self:SetAimTimer(math.max(self:GetAimTimer(true), CurTime() + d))
    else
        self:CreateInk()
        self:ConsumeInk(p.mInkConsume)
        self:SetCooldown(math.max(self:GetCooldown(), CurTime() + d))
        self:SetAimTimer(CurTime() + d)
    end
end

function SWEP:UpdateAnimation(ply, min, max) end
function SWEP:CustomDataTables()
    self:GetBase().CustomDataTables(self)
    self:AddNetworkVar("Float", "FireDelay")
    self:SetFireDelay(math.huge)
    local getaimtimer = self.GetAimTimer
    function self:GetAimTimer(org) -- This is needed when it's firing continuously.
        local a = getaimtimer(self)
        if org then return a end
        if CurTime() > self:GetFireDelay() then return a end
        if CurTime() > self:GetNextPrimaryFire() then return a end
        if self:GetKey() ~= IN_ATTACK then return a end
        return math.huge
    end
end
