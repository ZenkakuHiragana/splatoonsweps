
AddCSLuaFile()
ENT.Base = "ent_splatoonsweps_splatbomb"

local ss = SplatoonSWEPs
if not ss then return end
ENT.ExplosionOffset = 10
ENT.HitSound = "SplatoonSWEPs.SuctionBomb"
ENT.IsSplatoonBomb = true
ENT.Model = Model "models/splatoonsweps/subs/suctionbomb/suctionbomb.mdl"
ENT.SubWeaponName = "suctionbomb"

if CLIENT then
    local Sprite = Material "sprites/light_ignorez"
    function ENT:Draw()
        if self:GetNWBool "hit" then
            local t = CurTime() - self:GetNWFloat "t0"
            local y = 60 * math.exp(-4 * t) * math.sin(2 * math.pi * 5 * t)
            self:ManipulateBoneAngles(1, Angle(0, y, 0))
        end

        self:DrawModel()
        if self:GetSkin() == 0 then return end
        if util.TraceLine {
            start = self:GetPos(),
            endpos = EyePos(),
            filter = {self, GetViewEntity()},
            mask = MASK_VISIBLE_AND_NPCS,
        }.Hit then return end
        local color = ss.GetColor(self:GetNWInt "inkcolor")
        if not color then return end
        color = Color((color.r + 255) / 2, (color.g + 255) / 2, (color.b + 255) / 2)
        render.SetMaterial(Sprite)
        render.DrawSprite(self:GetPos(), 128, 128, ColorAlpha(color, 64))
        render.DrawSprite(self:GetPos(), 64, 64, color)
    end

    return
end

function ENT:PhysicsUpdate(p)
    if self:IsStuck() then return end
    self.BaseClass.PhysicsUpdate(self, p)
    local desired = p:GetVelocity()
    if desired:LengthSqr() < 100 then return end
    local current = p:GetAngles():Forward()
    local angvel = desired:Cross(current)
    local avlocal = WorldToLocal(angvel, angle_zero, vector_origin, p:GetAngles())
    p:SetAngleVelocityInstantaneous(avlocal)
end

function ENT:PhysicsCollide(data, collider)
    if self:IsStuck() then return end
    self.BaseClass.PhysicsCollide(self, data, collider)
    local n = -data.HitNormal
    local ang = n:Angle()
    local v = collider:GetVelocity()
    local v2d = v - n * n:Dot(v)
    local vn = v2d:GetNormalized()
    local dot = vn:Dot(ang:Right())
    local sign = vn:Dot(ang:Up()) > 0 and -1 or 1
    local deg = math.deg(math.acos(dot)) * sign
    ang:RotateAroundAxis(ang:Forward(), deg)
    collider:EnableMotion(not data.HitEntity:IsWorld())
    collider:EnableGravity(true)
    collider:SetPos(data.HitPos)
    collider:SetAngles(ang)
    self.HitNormal = -data.HitNormal
    self.ContactEntity = data.HitEntity
    self.ContactPhysObj = data.HitObject
    self.ContactStartTime = self.ContactStartTime or CurTime()
    self:Weld()
    self:SetNWFloat("t0", CurTime())
    self:SetNWBool("hit", true)
end
