
local ENT = ENT
---@cast ENT ENT.Squid
---@class ENT.Squid : ENT
---@field GetInkColorProxy fun(self): Vector
---@field OldAngles        Angle
---@field ShouldDraw       fun(self): boolean
---@field Update           fun(self)
---@field WasOnGround      boolean
---@field Trail            Entity? Return of util.SpriteTrail

AddCSLuaFile()
ENT.Type = "anim"

---@class ss
local ss = SplatoonSWEPs
if not ss then return end
ENT.AutomaticFrameAdvance = true

function ENT:GetInkColorProxy()
    local weapon = self:GetNWEntity "Weapon"
    if IsValid(weapon) then ---@cast weapon Entity.Colorable
        return weapon:GetInkColorProxy()
    else
        return ss.vector_one
    end
end

local MoveKeys = bit.bor(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT)
function ENT:Update()
    local Owner = self:GetNWEntity "Owner"
    local weapon = self:GetNWEntity "Weapon" --[[@as SplatoonWeaponBase]]
    if not IsValid(Owner) then return end
    if not IsValid(weapon) then return end
    if not Owner:IsPlayer() then return end ---@cast Owner Player
    local pm = weapon:GetNWInt "playermodel"
    if pm == ss.PLAYER.NOCHANGE then pm = ss.PlayermodelInv[Owner:GetModel()] end
    if pm then
        local id = ss.SquidmodelIndex[pm] or ss.SQUID.INKLING
        local mdl = ss.Squidmodel[id]
        if self:GetModel() ~= mdl then self:SetModel(mdl) end
    end

    if weapon:GetSuperJumpState() >= 0 then return end
    local seq = self:GetSequence()
    local WasOnGround = self.WasOnGround
    local SquidLoopSequences = {
        [self:LookupSequence "idle"] = "idle",
        [self:LookupSequence "walk"] = "walk",
        [self:LookupSequence "jump"] = "jump",
    }

    self.WasOnGround = Owner:OnGround()
    if SquidLoopSequences[seq] or self:IsSequenceFinished() then
        if Owner:OnGround() then
            if Owner:KeyDown(MoveKeys) then
                self:SetSequence "walk"
            elseif not WasOnGround then
                self:SetSequence "jump_end"
            else
                self:SetSequence "idle"
            end
        else
            self:SetSequence "jump"
        end
    end
end

function ENT:CalcAbsolutePosition(_pos, _ang)
    -- Move the squid to player's position.
    local Owner = self:GetNWEntity "Owner"
    local weapon = self:GetNWEntity "Weapon" --[[@as SplatoonWeaponBase]]
    if not IsValid(Owner) then return _pos, _ang end
    if not IsValid(weapon) then return _pos, _ang end

    local pos = Owner:GetPos()
    local f = Owner:GetForward() * 100
    local v = Owner:GetVelocity() + Vector(f.x, f.y)
    local a = v:Angle()
    local sjs = weapon:GetSuperJumpState()
    local start = weapon:GetSuperJumpFrom()
    local targetentity = weapon:GetSuperJumpEntity()
    local endpos = weapon:GetSuperJumpTo()
    if IsValid(targetentity) then
        endpos = targetentity:GetNetworkOrigin()
    end

    if sjs < 0 then
        if v:LengthSqr() < 16 then -- Speed limit
            a.p = 0
        elseif a.p > 45 and a.p <= 90 then -- Angle limit: up and down
            a.p = 45
        elseif a.p >= 270 and a.p < 300 then
            a.p = 300
        end

        a.y, a.r = weapon:GetAimVector():Angle().yaw, 180
    elseif sjs == 0 then
        if weapon:GetInWallInk() then
            local dir = ss.GetSuperJumpApex(Owner, start, endpos) - start
            local normal = weapon:GetWallNormal()
            dir = (dir - normal * normal:Dot(dir)):GetNormalized()
            local x, y = dir.z, vector_up:Cross(dir):Dot(normal)
            local roll = math.deg(math.atan2(y, x))
            a = Angle(90, normal:Angle().yaw, roll)
            pos:Sub(normal * 11)
        else
            local dir = endpos - self:GetPos()
            a.p, a.y, a.r = 0, dir:Angle().yaw, 180
        end
    else
        local t = CurTime() - weapon:GetSuperJumpStartTime()
        v = ss.GetSuperJumpVelocity(Owner, start, endpos, t)
        a = v:Angle()
        a.r = 180
    end

    a.p = a.p - 90
    if Owner:OnGround() then
        local t = util.QuickTrace(
            Owner:WorldSpaceCenter(),
            -vector_up * Owner:OBBMaxs().z,
            {self, weapon, Owner}
        )
        if t.HitWorld then
            local ta = t.HitNormal:Angle()
            ta:RotateAroundAxis(ta:Right(), -90)
            ta:RotateAroundAxis(ta:Up(), -ta.yaw)
            a = select(2, LocalToWorld(vector_origin, a, vector_origin, ta))
            pos = t.HitPos
        end
    end

    return pos + vector_up * 3, a
end

function ENT:ShouldDraw()
    local weapon = self:GetNWEntity "Weapon" --[[@as SplatoonWeaponBase]]
    if not IsValid(weapon) then return false end
    if not weapon:IsTPS() then return false end
    local Owner = weapon:GetOwner()
    if not IsValid(Owner) then return false end
    if (Owner:IsPlayer() or Owner:IsNPC()) ---@cast Owner Player|NPC
    and Owner:GetActiveWeapon() ~= weapon then return false end
    return weapon:ShouldDrawSquid()
end

if CLIENT then
    function ENT:Draw()
        local shoulddraw = self:ShouldDraw()
        if shoulddraw then
            local pos, ang = self:CalcAbsolutePosition(self:GetPos(), self:GetAngles())
            ang = LerpAngle(0.0625, self.OldAngles or self:GetAngles(), ang)
            self.OldAngles = ang
            self:SetPos(pos)
            self:SetAngles(ang)
            self:SetupBones()
            self:DrawModel()
        end

        self:DrawShadow(shoulddraw)
    end

    return
end

function ENT:Initialize()
    local weapon = self:GetNWEntity "Weapon"
    if not IsValid(weapon) then
        SafeRemoveEntity(self)
        return
    end

    local Owner = weapon:GetOwner()
    local index = ss.SquidmodelIndex[weapon:GetNWInt "playermodel"] or ss.SQUID.INKLING
    local modelpath = ss.Squidmodel[index]

    self:SetModel(modelpath)
    if self:LookupSequence "idle" >= 0 then self:ResetSequence "idle" end
    if not file.Exists(modelpath, "GAME") and IsValid(Owner) and Owner:IsPlayer() then ---@cast Owner Player
        Owner:SendLua "self:PopupError 'WeaponSquidModelNotFound'"
    end
end

function ENT:Think()
    self:NextThink(CurTime())
    if not IsValid(self:GetNWEntity "Weapon") then
        SafeRemoveEntity(self)
        return true
    end

    self:Update()
    return true
end
