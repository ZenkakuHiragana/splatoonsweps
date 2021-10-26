
local ss = SplatoonSWEPs
if not ss then return end
AddCSLuaFile()

ENT.AutomaticFrameAdvance = true
ENT.Type = "anim"

function ENT:GetInkColorProxy()
    if IsValid(self:GetNWEntity "Weapon") then
        return self:GetNWEntity "Weapon":GetInkColorProxy()
    else
        return ss.vector_one
    end
end

local MoveKeys = bit.bor(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT)
function ENT:Update()
    local owner = self:GetNWEntity "Owner"
    local weapon = self:GetNWEntity "Weapon"
    if not IsValid(owner) then return end
    if not IsValid(weapon) then return end

    local seq = self:GetSequence()
    local SequenceName = self:GetSequenceName(seq)
    local WasOnGround = self.WasOnGround
    local SquidLoopSequences = {
        [self:LookupSequence "idle"] = "idle",
        [self:LookupSequence "walk"] = "walk",
        [self:LookupSequence "jump"] = "jump",
    }

    self.WasOnGround = owner:OnGround()
    if SquidLoopSequences[seq] or self:IsSequenceFinished() then
        if owner:OnGround() then
            if owner:KeyDown(MoveKeys) then
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

    for k, v in pairs(ss.SQUID) do
        if k ~= "KRAKEN" then
            if ss.SquidmodelIndex[weapon:GetNWInt "playermodel"] == v then
                if self:GetModel() ~= ss.Squidmodel[v] then
                    self:SetModel(ss.Squidmodel[v])
                end
            end
        end
    end
end

function ENT:CalcAbsolutePosition(_pos, _ang)
    -- Move the squid to player's position.
    local owner = self:GetNWEntity "Owner"
    local weapon = self:GetNWEntity "Weapon"
    if not IsValid(owner) then return _pos, _ang end
    if not IsValid(weapon) then return _pos, _ang end

    local f = owner:GetForward() * 100
    local v = owner:GetVelocity() + Vector(f.x, f.y)
    local a = v:Angle()
    local yaw = weapon:GetAimVector():Angle().yaw
    local pos = owner:GetPos()
    if v:LengthSqr() < 16 then -- Speed limit
        a.p = 0
    elseif a.p > 45 and a.p <= 90 then -- Angle limit: up and down
        a.p = 45
    elseif a.p >= 270 and a.p < 300 then
        a.p = 300
    end
    
    a.p = a.p - 90
    a.y = yaw
    a.r = 180
    
    if owner:OnGround() then
        local t = util.QuickTrace(
            owner:WorldSpaceCenter(),
            -vector_up * owner:OBBMaxs().z,
            {self, weapon, owner}
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
    local weapon = self:GetNWEntity "Weapon"
    if not IsValid(weapon) then return false end
    if not weapon:IsTPS() then return false end
    if weapon:GetOwner():GetActiveWeapon() ~= weapon then return false end
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

	local index = ss.SquidmodelIndex[weapon:GetNWInt "playermodel"] or ss.SQUID.INKLING
    local modelpath = ss.Squidmodel[index]

    self:SetModel(modelpath)
    if self:LookupSequence "idle" >= 0 then self:ResetSequence "idle" end
    if not file.Exists(modelpath, "GAME") and IsValid(weapon:GetOwner()) then
        weapon:GetOwner():SendLua "self:PopupError 'WeaponSquidModelNotFound'"
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
