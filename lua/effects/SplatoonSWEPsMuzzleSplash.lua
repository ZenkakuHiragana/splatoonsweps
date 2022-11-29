
local ss = SplatoonSWEPs
if not ss then return end

local drawviewmodel = GetConVar "r_drawviewmodel"
local deep = "SplatoonSWEPs_Player.InkDiveDeep"
local shallow = "SplatoonSWEPs_Player.InkDiveShallow"
local mdl = Model "models/splatoonsweps/effects/muzzlesplash.mdl"
local mat = Material "splatoonsweps/effects/muzzlesplash"
local tex = mat:GetTexture "$basetexture"
local NumTextureFrames = tex:GetNumAnimationFrames()

function EFFECT:GetMuzzlePosition()
    if not IsValid(self.Weapon) then return self.Pos, self.Angle end
    local ent = self.Weapon
    if self.Weapon.IsSplatoonWeapon and not self.Weapon:IsTPS() then
        ent = self.Weapon:GetViewModel()
    end

    local a = ent:GetAttachment(self.AttachmentIndex)
    local pos, ang = Vector(a.Pos), Angle(a.Ang)
    ang:RotateAroundAxis(ang:Forward(), self.Angle.z)
    ang:RotateAroundAxis(ang:Right(), self.Angle.p)
    ang:RotateAroundAxis(ang:Up(), self.Angle.y)
    return pos, ang
end

function EFFECT:GetPosition()
    return self.Pos, self.Angle
end

-- Flags:
-- +128 Lag compensation for local player
-- +64 play deep dive sound instead of shallow dive sound
-- +32 play dive sounds
-- +16 don't stick to attachment
-- 0--15 attachment index - 1
function EFFECT:Init(e)
    local f = e:GetFlags()
    local ping = ss.mp and LocalPlayer():Ping() / 1000 or 0
    self.Weapon   = e:GetEntity()
    self.Color    = ss.GetColor(e:GetColor())
    self.Radius   = e:GetRadius()
    self.InitTime = CurTime() - ping * bit.band(f, 128) / 128
    self.LifeTime = e:GetAttachment() * ss.FrameToSec
    self.IsTPS    = IsValid(self.Weapon) and self.Weapon.IsSplatoonWeapon and self.Weapon:IsTPS()
    self.Angle    = e:GetAngles()
    self.Pos      = e:GetOrigin()
    self.Length   = e:GetScale()
    if not IsValid(self.Weapon) then self.Weapon = nil end
    if bit.band(f, 16) == 0 then
        self.GetPosition = self.GetMuzzlePosition
        self.AttachmentIndex = bit.band(f, 15) + 1
    end

    self:SetModel(mdl)
    self:SetColor(self.Color)
    local mins, maxs = self:GetRenderBounds()
    self:SetRenderBounds(mins, maxs, ss.vector_one * 200)

    if bit.band(f, 32) == 0 then return end
    local track = bit.band(f, 64) > 0 and deep or shallow
    if self.Weapon and self.Weapon:IsCarriedByLocalPlayer() then
        self:EmitSound(track)
    else
        sound.Play(track, self.Pos)
    end
end

function EFFECT:Render()
    if self.Weapon and not (self.IsTPS or drawviewmodel:GetBool()) then return end
    local t = CurTime() - self.InitTime
    local fraction = math.Clamp(t / self.LifeTime, 0, 1)
    local frame = math.floor(fraction * NumTextureFrames)
    local scale = Lerp(fraction * 2, 1, self.Radius) / 20
    local length = Lerp(fraction * 2 - 1, 1, self.Length)
    local pos, ang = self:GetPosition()
    local m = Matrix()
    frame = math.Clamp(frame, 0, NumTextureFrames - 1)
    m:Scale(Vector(length, scale, scale))
    mat:SetInt("$frame", frame)
    self:SetPos(pos)
    self:SetAngles(ang)
    self:EnableMatrix("RenderMultiply", m)
    self:SetupBones()
    self:DrawModel()
end

-- Called when the effect should think, return false to kill the effect.
function EFFECT:Think()
    local valid = CurTime() < self.InitTime + self.LifeTime
    if IsValid(self.Weapon) and self.Weapon.IsSplatoonWeapon then
        return valid and IsValid(self.Weapon:GetOwner())
        and self.Weapon:GetOwner():GetActiveWeapon() == self.Weapon
    else
        return valid and (self.IsTPS or drawviewmodel:GetBool())
    end
end
