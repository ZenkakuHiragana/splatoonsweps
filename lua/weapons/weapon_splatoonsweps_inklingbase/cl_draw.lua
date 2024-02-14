
-- The way to draw ink tank comes from SWEP Construction Kit.
local ss = SplatoonSWEPs
if not ss then return end

---@class SplatoonWeaponBase
---@field CustomCalcView               fun(self, ply: Player, pos: Vector, ang: Angle, fov: number): number?
---@field PreDrawWorldModel            fun(self): boolean?
---@field PreDrawWorldModelTranslucent fun(self): boolean?
---@field PreViewModelDrawn            fun(self, vm: Entity, weapon: Weapon, ply: Player)
---@field AmmoDisplay                  { Draw: boolean, PrimaryClip: number, PrimaryAmmo: number, SecondaryAmmo: number? }
---@field BubblerEntity                ENT.Bubbler
---@field Cursor                       { x: number, y: number }
---@field EnoughSubWeapon              boolean
---@field PreviousInk                  boolean
---@field ViewPunch                    Angle
---@field ViewPunchVel                 Angle
---@field WElements                    table<string, SWEP.ModelElement>
---@field SpriteSizeChangeSpeed        number
---@field SpriteCurrentSize            number
local SWEP = SWEP

---@class CSEnt.ModelEnt : CSEnt
---@field GetInkColorProxy fun(self): Vector

---@class SWEP.ModelElement
---@field angle             Angle?
---@field worldang          Angle?
---@field bodygroup         integer[]?
---@field bone              string
---@field color             Color?
---@field createdModel      string?
---@field createdSprite     string?
---@field draw_func         fun(self)?
---@field hide              boolean?
---@field inktank           boolean?
---@field is2d              boolean?
---@field material          string?
---@field model             string?
---@field modelEnt          CSEnt|CSEnt.ModelEnt?
---@field pos               Vector?
---@field rel               string?
---@field size              Vector|{ x: number, y: number }?
---@field skin              integer?
---@field sprite            string?
---@field spriteMaterial    IMaterial?
---@field surpresslightning boolean?
---@field type              string?

---Resets bone manipulations of given view model
---@param vm Entity The view model to reset
function SWEP:ResetBonePositions(vm)
    if not (IsValid(vm) and vm:GetBoneCount()) then return end
    for i = 0, vm:GetBoneCount() do
        vm:ManipulateBoneScale(i, ss.vector_one)
        vm:ManipulateBonePosition(i, vector_origin)
        vm:ManipulateBoneAngles(i, angle_zero)
    end
end

---@param tab SWEP.ModelElement
---@param ent Entity
---@return Vector?
---@return Angle?
function SWEP:GetBoneOrientation(tab, ent)
    local bone, pos, ang ---@type integer, Vector?, Angle?
    bone = ent:LookupBone(tab.bone)
    if not bone then return end
    local m = ent:GetBoneMatrix(bone)
    pos, ang = m and m:GetTranslation(), m and m:GetAngles()

    if ent == self:GetViewModel() and self.ViewModelFlip then
        ang.r = -ang.r -- Fixes mirrored models
    end

    return pos, ang
end

---@param v SWEP.ModelElement
---@param modelname string?
---@return boolean?
function SWEP:RecreateModel(v, modelname)
    modelname = modelname or v.model ~= "" and v.model or nil
    if not (modelname and util.IsModelLoaded(modelname)) then return end
    v.modelEnt = ClientsideModel(modelname, RENDERGROUP_BOTH)
    if IsValid(v.modelEnt) then
        v.createdModel = modelname
        v.modelEnt:SetPos(self:GetPos())
        v.modelEnt:SetAngles(self:GetAngles())
        v.modelEnt:SetParent(self)
        v.modelEnt:SetNoDraw(true)
        v.modelEnt:DrawShadow(true)
        function v.modelEnt.GetInkColorProxy()
            if IsValid(self) then
                return self:GetInkColorProxy()
            else
                return ss.vector_one
            end
        end
    else
        v.modelEnt = nil
    end

    return IsValid(v.modelEnt)
end

---@param t table<string, SWEP.ModelElement>
function SWEP:CreateModels(t)
    if not t then return end

    -- Create the clientside models here because Garry says we can't do it in the render hook
    local errormodelshown, errormaterialshown = false, false
    for k, v in pairs(t) do
        local modelname = k == "weapon" and nil or v.model ~= "" and v.model
        if v.type == "Model" and modelname and (not IsValid(v.modelEnt) or v.createdModel ~= modelname) then
            if file.Exists(modelname, "GAME") then
                self:RecreateModel(v, modelname)
            elseif not errormodelshown then
                self:PopupError "WeaponModelNotFound"
                errormodelshown = true
            end
        elseif v.type == "Sprite" and v.sprite and v.sprite ~= "" and
            (not v.spriteMaterial or v.createdSprite ~= v.sprite) then

            if file.Exists("materials/" .. v.sprite .. ".vmt", "GAME") then
                local name = v.sprite .. "-"
                local params = {["$basetexture"] = v.sprite}
                -- make sure we create a unique name based on the selected options
                local tocheck = {"nocull", "additive", "vertexalpha", "vertexcolor", "ignorez"}
                for _, j in ipairs(tocheck) do
                    if v[j] then
                        params["$" .. j] = "1"
                        name = name .. "1"
                    else
                        name = name .. "0"
                    end
                end

                v.createdSprite = v.sprite
                v.spriteMaterial = CreateMaterial(name, "UnlitGeneric", params)
                if v.spriteMaterial:IsError() then
                    v.createdSprite = nil
                    v.spriteMaterial = nil
                end
            elseif not errormaterialshown then
                self:PopupError "WeaponSpriteMatNotFound"
                errormaterialshown = true
            end
        end
    end
end

---@param name string
function SWEP:DrawWorldElement(name)
    local v = self.WElements[name]
    if not v then return end
    if v.hide then return end

    local cameradistance = 1
    local bone_ent = self:GetOwner()
    if not IsValid(bone_ent) then bone_ent = self end -- When the weapon is dropped
    if self:IsCarriedByLocalPlayer() then
        cameradistance = self:GetCameraFade()
    end

    local pos, ang = self:GetBoneOrientation(v, bone_ent)
    if not (pos and ang) then return end

    if v.type == "Model" then
        if not (IsValid(v.modelEnt) or self:RecreateModel(v)) then return end
        local model = v.modelEnt ---@cast model -?
        if v.pos or v.angle then
            local worldpos, worldang = LocalToWorld(v.pos or Vector(), v.angle or Angle(), pos, ang)
            if v.pos then model:SetPos(worldpos) end
            if v.angle then model:SetAngles(worldang) end
        end

        local matrix = Matrix()
        matrix:Scale(v.size or ss.vector_one)
        model:SetupBones()
        model:EnableMatrix("RenderMultiply", matrix)
        render.SetBlend(cameradistance)
        model:DrawModel()
        model:CreateShadow()
        render.SetBlend(1)
    elseif v.type == "Sprite" and v.spriteMaterial then
        local worldpos = LocalToWorld(v.pos, Angle(), pos, ang)
        render.SetMaterial(v.spriteMaterial)
        render.DrawSprite(worldpos, v.size.x, v.size.y, v.color)
    end
end

---@param vm Entity
---@param weapon SplatoonWeaponBase
---@param ply Player
function SWEP:PreDrawViewModel(vm, weapon, ply)
    ss.ProtectedCall(self.PreViewModelDrawn, self, vm, weapon, ply)
    vm:SetupBones()
end

---@param vm Entity
function SWEP:ViewModelDrawn(vm)
    if self:GetHolstering() or not (IsValid(self) and IsValid(self:GetOwner())) then return end
    if self:GetThrowing() and CurTime() > self:GetNextSecondaryFire() then
        ss.ProtectedCall(self.DrawOnSubTriggerDown, self)
    end
end

function SWEP:DrawWorldModel()
    if not IsValid(self:GetOwner()) then return self:DrawModel() end
    if self:GetHolstering() then return end
    if self:ShouldDrawSquid() then return end
    if self:GetInInk() then return end
    if ss.ProtectedCall(self.PreDrawWorldModel, self) then return end
    if not self:IsCarriedByLocalPlayer() then self:Think() end
    if self:GetThrowing() and CurTime() > self:GetNextSecondaryFire() then
        ss.ProtectedCall(self.DrawOnSubTriggerDown, self)
    end

    self:SetupBones()
    self:DrawModel()
end

function SWEP:DrawWorldModelTranslucent()
    if IsValid(self:GetOwner()) and self:GetHolstering() then return end
    if ss.ProtectedCall(self.PreDrawWorldModelTranslucent, self) then return end

    local usingbombrush = self:GetNWBool "IsUsingSpecial" and self.Special == "bombrush"
    local refsize = usingbombrush and 80 or self.EnoughSubWeapon and 32 or 0
    local diff = refsize - self.SpriteCurrentSize
    self.SpriteSizeChangeSpeed = self.SpriteSizeChangeSpeed * 0.92 + diff * 2 * FrameTime()
    self.SpriteCurrentSize = self.SpriteCurrentSize + self.SpriteSizeChangeSpeed

    if self:GetThrowing() and CurTime() > self:GetNextSecondaryFire() then
        ss.ProtectedCall(self.DrawOnSubTriggerDown, self)
    end

    if not (self:ShouldDrawSquid() or self:GetInInk()) then
        local inkconsume = ss.ProtectedCall(self.GetSubWeaponInkConsume, self) or 0
        local size = self.SpriteCurrentSize
        self.WElements.subweaponusable.size = { x = size, y = size }
        self.WElements.subweaponusable.hide = not IsValid(self.WElements.inktank.modelEnt) or self:GetInk() < inkconsume

        -- Manipulate sub weapon usable meter
        local model = self.WElements.inktank.modelEnt
        if not IsValid(model) then
            self:RecreateModel(self.WElements.inktank)
            model = self.WElements.inktank.modelEnt
        end
        if IsValid(model) then ---@cast model -?
            local BombPos = Vector(math.min(-11.9 + inkconsume * 17 / ss.GetMaxInkAmount(), 5.1))
            model:ManipulateBonePosition(model:LookupBone "bip_inktank_bombmeter", BombPos)

            -- Ink remaining
            local ink = -17 + .17 * self:GetInk() * ss.MaxInkAmount / ss.GetMaxInkAmount()
            model:ManipulateBonePosition(model:LookupBone "bip_inktank_ink_core", Vector(ink, 0, 0))

            -- Ink visiblity
            model:SetBodygroup(model:FindBodygroupByName "Ink", ink < -16.5 and 1 or 0)

            -- Ink wave
            for i = 1, 19 do
                if i == 10 or i == 11 then continue end
                local number = tostring(i)
                if i < 10 then number = "0" .. tostring(i) end
                local bone = model:LookupBone("bip_inktank_ink_" .. number)
                local delta = model:GetManipulateBonePosition(bone).y
                local write = math.Clamp(delta + math.sin(CurTime() + math.pi / 17 * i) / 100, -0.25, 0.25)
                model:ManipulateBonePosition(bone, Vector(0, write, 0))
            end

            model:SetupBones()
        end

        self:DrawWorldElement "inktank"
        self:DrawWorldElement "subweaponusable"
    end

    -- Draw Bubbler when enabled here to avoid translucent rendering order issues
    if ss.IsInvincible(self:GetOwner()) and IsValid(self.BubblerEntity) then
        self.BubblerEntity:DrawParticle()
        render.UpdateRefractTexture()
        self.BubblerEntity:DrawModel()
    end
end

-- Show remaining amount of ink tank
function SWEP:CustomAmmoDisplay()
    local specialProgress = math.Clamp(math.Round(self:GetSpecialPointProgress() * 100), 0, 100)
    if self:GetNWBool "IsUsingSpecial" then
        local dt = CurTime() - self:GetSpecialStartTime()
        local duration = self:GetSpecialDuration()
        specialProgress = math.Clamp(100 - math.Round(dt / duration * 100), 0, 100)
    end
    return {
        Draw = true,
        PrimaryClip = math.Round(self:GetInk()),
        PrimaryAmmo = specialProgress,
        SecondaryAmmo = self:DisplayAmmo(),
    }
end

---This hook draws the selection icon in the weapon selection menu.
---@param x number
---@param y number
---@param wide number
---@param tall number
---@param alpha number
function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)
    -- Set us up the texture
    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetTexture(self.WepSelectIcon)

    -- Lets get a sin wave to make it bounce
    local fsin = math.sin(CurTime() * 10) * (self.BounceWeaponIcon and 5 or 0)

    -- Borders
    x, y, wide = x + 10, y + 10, wide - 20

    -- Draw that mother
    surface.DrawTexturedRect(x + fsin, y - fsin, wide - fsin * 2, tall + fsin * 2)

    -- Draw weapon info box
    self:PrintWeaponInfo(x + wide + 20, y + tall, alpha)
end

---Called when the crosshair is about to get drawn, and allows you to override it.
---@param x number
---@param y number
---@return boolean?
function SWEP:DoDrawCrosshair(x, y)
    local Owner = self:GetOwner()
    if not (IsValid(Owner) and Owner:IsPlayer()) then return false end ---@cast Owner Player
    self.Cursor = Owner:GetEyeTrace().HitPos:ToScreen()
    if not ss.GetOption "drawcrosshair" then return false end
    if self:GetThrowing() then return false end
    x, y = self.Cursor.x, self.Cursor.y

    return ss.ProtectedCall(self.CustomDrawCrosshair, self, x, y)
end

local PUNCH_DAMPING = 9.0
local PUNCH_SPRING_CONSTANT = 65.0
---Allows you to adjust player view while this weapon in use.
---@param ply Player
---@param pos Vector
---@param ang Angle
---@param fov number
---@return Vector
---@return Angle
---@return number
function SWEP:CalcView(ply, pos, ang, fov)
    local f = ss.ProtectedCall(self.CustomCalcView, self, ply, pos, ang, fov) ---@type number?
    if ply:ShouldDrawLocalPlayer() then return pos, ang, f or fov end
    if not isangle(self.ViewPunch) then return pos, ang, f or fov end
    if math.abs(self.ViewPunch.p + self.ViewPunch.y + self.ViewPunch.r) > 0.001
    or math.abs(self.ViewPunchVel.p + self.ViewPunchVel.y + self.ViewPunchVel.r) > 0.001 then
        self.ViewPunch:Add(self.ViewPunchVel * FrameTime())
        self.ViewPunchVel:Mul(math.max(0, 1 - PUNCH_DAMPING * FrameTime()))
        self.ViewPunchVel:Sub(self.ViewPunch * math.Clamp(
            PUNCH_SPRING_CONSTANT * FrameTime(), 0, 2))
        self.ViewPunch:Set(Angle(
            math.Clamp(self.ViewPunch.p, -89, 89),
            math.Clamp(self.ViewPunch.y, -179, 179),
            math.Clamp(self.ViewPunch.r, -89, 89)))
    else
        self.ViewPunch:Zero()
    end

    return pos, ang + self.ViewPunch, f or fov
end

---Returns transparency of the player in case the camera is too close
---@return number The transparency from 0 to 1
function SWEP:GetCameraFade()
    if not ss.GetOption "translucentnearbylocalplayer" then return 1 end
    return math.Clamp(self:GetPos():DistToSqr(EyePos()) / ss.CameraFadeDistance, 0, 1)
end

---Returns if the squid model should be drawn
---@return boolean True # if the squid model should be drawn
function SWEP:ShouldDrawSquid()
    if not IsValid(self:GetOwner()) then return false end
    if not self:Crouching() then return false end
    if not self:GetNWBool "becomesquid" then return false end
    if not IsValid(self:GetNWEntity "Squid") then return false end
    return not self:GetInInk()
end
