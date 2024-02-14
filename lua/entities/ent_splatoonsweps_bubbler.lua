
local ENT = ENT
---@cast ENT ENT.Bubbler
---@class ENT.Bubbler : ENT
---@field InitTime         number
---@field IsDisappearing   boolean
---@field ModelDiameter    number
---@field OwnerBloodType   integer
---@field Particle         CNewParticleEffect? Effects for initial flash and final flicker
---@field ParticleLeak     CNewParticleEffect? Effects for sparkles spawned on the model
---@field AdjustModel      fun(self)
---@field CreateParticle   fun(self, name: string): CNewParticleEffect?
---@field DrawParticle     fun(self)
---@field GetInkColorProxy fun(self): Vector
---@field RemoveBombs      fun(self)
---@field SetControlPoints fun(self, p: CNewParticleEffect)
---@field Spread           fun(self)

AddCSLuaFile()
ENT.Type = "anim"

---@class ss
local ss = SplatoonSWEPs
if not ss then return end

---@return Vector
function ENT:GetInkColorProxy()
    local Owner = self:GetOwner()
    if not IsValid(Owner) then return ss.vector_one end
    local w = ss.IsValidInkling(Owner)
    if not w then return ss.vector_one end
    return w:GetInkColorProxy()
end

local mdl = Model "models/splatoonsweps/specials/bubbler.mdl"
function ENT:Initialize()
    local Owner = self:GetOwner()
    local w = IsValid(Owner) and ss.IsValidInkling(Owner) or nil
    if not w then
        SafeRemoveEntity(self)
        return
    end

    self:SetModel(mdl)
    self:SetNoDraw(true)
    local mins, maxs = self:GetModelRenderBounds()
    if CLIENT then
        w.BubblerEntity = self
        self.Particle = self:CreateParticle(ss.Particles.BubblerStart)
        self:EmitSound "SplatoonSWEPs.BubblerStart"
    end

    self.InitTime = CurTime()
    self.IsDisappearing = false
    self.ModelDiameter = maxs.z - mins.z
    if SERVER then
        self.OwnerBloodType = Owner:GetBloodColor()
        Owner:SetBloodColor(DONT_BLEED)
        ss.SetInvincibleDuration(Owner, self:GetEndTime() - CurTime())
    end
end

function ENT:SetupDataTables()
    ---@class ENT.Bubbler
    ---@field GetEndTime  fun(self): number
    ---@field SetEndTime  fun(self, value: number)
    self:NetworkVar("Float", 0, "EndTime")
end

function ENT:SetControlPoints(p)
    if not IsValid(p) then return end
    local Owner = self:GetOwner()
    local dz = Owner:EyePos().z - Owner:GetPos().z
    p:SetControlPoint(1, LerpVector(1 / 3, self:GetInkColorProxy(), ss.vector_one))
    p:SetControlPoint(2, ss.vector_one * dz)
end

function ENT:AdjustModel()
    local Owner = self:GetOwner()
    if not IsValid(Owner) then return end
    local pos = Owner:GetPos()
    local dz = Owner:EyePos().z - pos.z
    local scale = dz / self.ModelDiameter
    local org = Owner:WorldSpaceCenter()
    if Owner:IsPlayer() then ---@cast Owner Player
        local stand = Owner:GetViewOffset().z
        local ducked = Owner:GetViewOffsetDucked().z
        local frac = math.Remap(dz, ducked, stand, 0.5, 1)
        org = LerpVector(frac, pos, org)
    end
    self:SetPos(org)
    self:SetAngles(SERVER and Angle() or EyeAngles())
    self:SetModelScale(scale * 1.75)
    self:SetControlPoints(self.Particle)
    self:SetControlPoints(self.ParticleLeak)
end

if CLIENT then
    function ENT:CreateParticle(name)
        local p = CreateParticleSystem(self, name, PATTACH_ABSORIGIN_FOLLOW)
        self:SetControlPoints(p)
        p:SetShouldDraw(false)
        return p
    end

    function ENT:DrawParticle()
        if IsValid(self.Particle) then self.Particle:Render() end
        if IsValid(self.ParticleLeak) then self.ParticleLeak:Render() end
    end

    function ENT:Think()
        local timeleft = self:GetEndTime() - CurTime()
        if not IsValid(self.ParticleLeak) and timeleft < 2 then
            self.ParticleLeak = self:CreateParticle(ss.Particles.BubblerLeak)
        end
        if not IsValid(self.Particle) and timeleft < 1 then
            self.InitTime = CurTime()
            self.Particle = self:CreateParticle(ss.Particles.BubblerFlicker)
        end
        self.IsDisappearing = timeleft < 1
        self:AdjustModel()
        self:SetNextClientThink(CurTime())
        self:SetColor4Part(255, 255, 255, self.IsDisappearing and 0 or 255)
        return true
    end

    function ENT:OnRemove()
        local Owner = self:GetOwner()
        if IsValid(self.Particle) then
            self.Particle:StopEmissionAndDestroyImmediately()
        end
        if IsValid(self.ParticleLeak) then
            self.ParticleLeak:StopEmissionAndDestroyImmediately()
        end
        if IsValid(Owner) then
            ss.SetInvincibleDuration(Owner, -1)
            local w = ss.IsValidInkling(Owner)
            if w and Owner:Health() > 0 then
                local p = CreateParticleSystemNoEntity(ss.Particles.BubblerEnd, self:GetPos(), self:GetAngles())
                self:SetControlPoints(p)
                self:EmitSound "SplatoonSWEPs.BubblerEnd"
            end
        end
    end
else
    function ENT:RemoveBombs()
        local Owner = self:GetOwner()
        if not IsValid(Owner) then return end
        local w = ss.IsValidInkling(Owner)
        if not w then return end
        for _, ent in ipairs(ents.FindInBox(Owner:WorldSpaceAABB())) do
            if ent == Owner then continue end ---@cast ent ENT.SplatBomb
            if ent:GetOwner() == Owner then return end
            if not ent.IsSplatoonBomb then continue end
            if ss.IsAlly(ent, w) then continue end
            ss.ProtectedCall(ent.Disappear, ent)
        end
    end

    function ENT:Spread()
        local Owner = self:GetOwner()
        local w = ss.IsValidInkling(Owner)
        local p = ss.bubbler.Parameters
        local delay = p.SpreadDelay
        local endtime = ss.InvincibleEntities[Owner]
        local remaining = endtime and (endtime - CurTime()) or 0
        local color = w and w:GetNWInt "inkcolor" or -1
        if color < 0 then return end
        if remaining < delay then return end
        for ply in pairs(ss.PlayerFilters[color] or {}) do
            if ply == Owner or ss.IsInvincible(ply) then continue end
            w = ss.IsValidInkling(ply)
            if not w then continue end
            if ply:GetPos():DistToSqr(Owner:GetPos()) > p.SpreadRadius * p.SpreadRadius then continue end
            local name = "SplatoonSWEPs: Bubbler Spread " .. ply:EntIndex()
            if timer.Exists(name) then continue end
            self:EmitSound "SplatoonSWEPs.BubblerSpread"
            timer.Create(name, delay, 1, function()
                timer.Remove(name)
                if not IsValid(self) then return end
                if not IsValid(Owner) then return end
                if not IsValid(ply) then return end
                if not IsValid(w) then return end
                if not ss.InvincibleEntities[Owner] then return end
                local ent = ents.Create "ent_splatoonsweps_bubbler" --[[@as ENT.Bubbler]]
                ent:SetOwner(ply)
                ent:SetEndTime(self:GetEndTime())
                ent:Spawn()
            end)
        end
    end

    function ENT:Think()
        local Owner = self:GetOwner()
        local timeleft = self:GetEndTime() - CurTime()
        if not IsValid(Owner) or timeleft < 0 or not ss.IsInvincible(Owner) or Owner:Health() <= 0 then
            self:Remove()
        else
            self.IsDisappearing = timeleft < 1
            self:Spread()
            self:RemoveBombs()
            self:AdjustModel()
            self:NextThink(CurTime())
            self:SetColor4Part(255, 255, 255, self.IsDisappearing and 0 or 255)
        end
        return true
    end

    function ENT:OnRemove()
        local Owner = self:GetOwner()
        if not IsValid(Owner) then return end
        Owner:SetBloodColor(self.OwnerBloodType)
        ss.SetInvincibleDuration(Owner, -1)
    end
end
