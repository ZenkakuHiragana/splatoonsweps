
local ss = SplatoonSWEPs
if not ss then return end
local mdl = Model "models/hunter/misc/sphere2x2.mdl"
local BeamMaterial = Material "cable/cable_lit"
local T = 0.7 -- Total animation time
local r1 = 20 * ss.ToHammerUnits -- Minimum radius
local r2 = 70 * ss.ToHammerUnits -- Maximum radius
local tr = 0.2 -- Time to maximize the radius
local n = 15 -- Number of beams
local ns = 6 -- Number of segments for a beam
function EFFECT:Init(e)
    self:SetModel(mdl)
    self:SetPos(e:GetOrigin())
    self.InitTime = CurTime()
    self.Color = ss.GetColor(e:GetColor())
    self.Color = Color(self.Color.r / 2, self.Color.g / 2, self.Color.b / 2)
    self.ColorVector = self.Color:ToVector()
    self.AngleOffsets = {}
    for i = 1, n do
        self.AngleOffsets[i] = AngleRand()
    end
end

function EFFECT:Think() return CurTime() - self.InitTime < T end
function EFFECT:Render()
    local t = CurTime() - self.InitTime         -- Elapsed time
    local fw = math.max(0, (t - tr) / (T - tr)) -- Fraction for segment width
    local fd = t / T                            -- Fraction for rotation degrees
    local fr = math.min(1, t / tr)              -- Fraction for radius
    local w = Lerp(fw, 15, 0)                   -- Segment width
    local d = Lerp(fd, 0, 540)                  -- Rotation degrees
    local r = Lerp(math.EaseInOut(fr, 0.2, 0.8), r1, r2) -- Radius

    render.SetMaterial(BeamMaterial)
    for i = 1, n do
        local pos = {}
        for k = 1, ns do
            local di = (k - 1) / ns * 45
            local a = Angle(self.AngleOffsets[i])
            a:RotateAroundAxis(a:Up(), d + di)
            pos[k] = Vector(r)
            pos[k]:Rotate(a)
            pos[k]:Add(self:GetPos())
        end

        render.StartBeam(ns)
        for k = 1, ns do
            render.AddBeam(pos[k], w, k / ns * 5, self.Color)
        end
        render.EndBeam()
    end
end
