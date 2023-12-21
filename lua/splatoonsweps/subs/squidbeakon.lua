
AddCSLuaFile()
---@class ss
local ss = SplatoonSWEPs
if not ss then return end
---@type ISubWeaponDef
ss.squidbeakon = {
    Merge = {
        IsSubWeaponThrowable = false,
        NumBeakons = 0,
    },
    ---@class SubParameters.SquidBeakon
    Parameters = {
        Burst_Damage_Far = 0.3,
        Burst_Damage_Near = 1.8,
        Burst_PaintR = 40,
        Burst_Radius_Far = 70,
        Burst_Radius_Near = 40,
        Burst_SplashNum = 0,
        Burst_SplashOfstY = 0,
        Burst_SplashPaintR = 0,
        Burst_SplashPitH = 0,
        Burst_SplashPitL = 0,
        Burst_SplashVelH = 0,
        Burst_SplashVelL = 0,
        CrossPaintRadius = 20,
        CrossPaintRayLength = 20,
        Fly_Gravity = 0.16,
        Fly_VelKd = 0.94134,
        InitInkRadius = 10,
        InkConsume = 0.9,
        InkRecoverStop = 0,
        MaxBeakons = 3,
        PlayerColRadius = 30,
        DeploySoundDelay = 12,
        RadioPlayInterval = 300,
        RotationSpeed = 144,
        RotationDelay = 15,
        LightEmitInitialDelay = 3,
        LightEmitInterval = 53,
        LightEmitTime = 8,
        LightEmitRestTime = 12,
    },
    Units = {
        Burst_Damage_Far = "hp",
        Burst_Damage_Near = "hp",
        Burst_PaintR = "du",
        Burst_Radius_Far = "du",
        Burst_Radius_Near = "du",
        Burst_SplashNum = "num",
        Burst_SplashOfstY = "du",
        Burst_SplashPaintR = "du",
        Burst_SplashPitH = "deg",
        Burst_SplashPitL = "deg",
        Burst_SplashVelH = "du/f",
        Burst_SplashVelL = "du/f",
        CrossPaintRadius = "du",
        CrossPaintRayLength = "du",
        Fly_Gravity = "du/f^2",
        Fly_VelKd = "ratio",
        InitInkRadius = "du",
        InkConsume = "ink",
        InkRecoverStop = "f",
        MaxBeakons = "num",
        PlayerColRadius = "du",
        DeploySoundDelay = "f",
        RadioPlayInterval = "f",
        RotationSpeed = "deg",
        RotationDelay = "f",
        LightEmitInitialDelay = "f",
        LightEmitInterval = "f",
        LightEmitTime = "f",
        LightEmitRestTime = "f",
    },
    BurstSound = "SplatoonSWEPs.BombExplosion",
}

ss.ConvertUnits(ss.squidbeakon.Parameters, ss.squidbeakon.Units)

---@type SplatoonWeaponBase
local module = ss.squidbeakon.Merge
local p = ss.squidbeakon.Parameters
function module:CanSecondaryAttack()
    return self:GetInk() >= self:GetSubWeaponInkConsume()
end

function module:GetSubWeaponInkConsume()
    return p.InkConsume
end

if CLIENT then return end
function module:ServerSecondaryAttack(throwable)
    if not self:GetOwner():OnGround() then return end

    self.ExistingBeakons = self.ExistingBeakons or {}
    if self.NumBeakons >= p.MaxBeakons then
        local beakon = NULL
        while not IsValid(beakon) and #self.ExistingBeakons > 0 do
            beakon = ss.tablepop(self.ExistingBeakons)
        end

        SafeRemoveEntity(beakon)
    end

    local start = self:GetOwner():GetPos()
    local tracedz = -vector_up * p.CrossPaintRayLength
    local tr = util.QuickTrace(start, tracedz, self:GetOwner())
    if not tr.Hit then return end

    for _, e in ipairs(ents.FindInSphere(tr.HitPos, 10)) do
        ---@cast e ENT.SquidBeakon
        if e.IsSquidBeakon then return end
    end

    local inkcolor = self:GetNWInt "inkcolor"
    local e = ents.Create "ent_splatoonsweps_squidbeakon" --[[@as ENT.SquidBeakon]]
    local ang = Angle()
    ang.yaw = self:GetOwner():GetAngles().yaw
    e.Weapon = self
    e:SetOwner(self:GetOwner())
    e:SetNWInt("inkcolor", inkcolor)
    e:SetInkColorProxy(self:GetInkColorProxy())
    e:SetPos(tr.HitPos + tr.HitNormal)
    e:SetAngles(ang)
    e:Spawn()

    self.NumBeakons = self.NumBeakons + 1
    table.insert(self.ExistingBeakons, e)

    self:ConsumeInk(self:GetSubWeaponInkConsume())
    self:SetReloadDelay(p.InkRecoverStop)

    ss.Paint(tr.HitPos, tr.HitNormal, p.InitInkRadius,
    inkcolor, ang.yaw, ss.GetDropType(), 1, self:GetOwner(), self:GetClass())

    local ph = e:GetPhysicsObject()
    if not IsValid(ph) then return end
    ph:EnableMotion(not tr.Entity:IsWorld())
    ph:EnableGravity(true)

    e.HitNormal = tr.HitNormal
    e.ContactEntity = tr.Entity
    e.ContactPhysObj = tr.Entity:GetPhysicsObject()
    e.ContactStartTime = CurTime()
    e:Weld()
end
