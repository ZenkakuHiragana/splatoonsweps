
AddCSLuaFile()
local ss = SplatoonSWEPs
if not ss then return end

---@class SplatoonWeaponBase
local SWEP = SWEP
local ActIndex = {
    pistol   = ACT_HL2MP_IDLE_PISTOL,
    smg      = ACT_HL2MP_IDLE_SMG1,
    grenade  = ACT_HL2MP_IDLE_GRENADE,
    ar2      = ACT_HL2MP_IDLE_AR2,
    shotgun  = ACT_HL2MP_IDLE_SHOTGUN,
    rpg      = ACT_HL2MP_IDLE_RPG,
    physgun  = ACT_HL2MP_IDLE_PHYSGUN,
    crossbow = ACT_HL2MP_IDLE_CROSSBOW,
    melee    = ACT_HL2MP_IDLE_MELEE,
    slam     = ACT_HL2MP_IDLE_SLAM,
    normal   = ACT_HL2MP_IDLE,
    fist     = ACT_HL2MP_IDLE_FIST,
    melee2   = ACT_HL2MP_IDLE_MELEE2,
    passive  = ACT_HL2MP_IDLE_PASSIVE,
    knife    = ACT_HL2MP_IDLE_KNIFE,
    duel     = ACT_HL2MP_IDLE_DUEL,
    camera   = ACT_HL2MP_IDLE_CAMERA,
    magic    = ACT_HL2MP_IDLE_MAGIC,
    revolver = ACT_HL2MP_IDLE_REVOLVER,
}

---Sets the hold type of the weapon.
---@param t string
function SWEP:SetWeaponHoldType(t)
    if not isstring(t) then return end
    t = t:lower()
    local index = assert(ActIndex[t], "SplatoonSWEPs: SWEP:SetWeaponHoldType - ActIndex[] is not set!")

    self.ActivityTranslate = {}
    self.ActivityTranslate[ ACT_MP_STAND_IDLE ]                = index
    self.ActivityTranslate[ ACT_MP_WALK ]                      = index + 1
    self.ActivityTranslate[ ACT_MP_RUN ]                       = index + 2
    self.ActivityTranslate[ ACT_MP_CROUCH_IDLE ]               = index + 3
    self.ActivityTranslate[ ACT_MP_CROUCHWALK ]                = index + 4
    self.ActivityTranslate[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]  = index + 5
    self.ActivityTranslate[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = index + 5
    self.ActivityTranslate[ ACT_MP_RELOAD_STAND ]              = index + 6
    self.ActivityTranslate[ ACT_MP_RELOAD_CROUCH ]             = index + 6
    self.ActivityTranslate[ ACT_MP_JUMP ]                      = index + 7
    self.ActivityTranslate[ ACT_RANGE_ATTACK1 ]                = index + 8
    self.ActivityTranslate[ ACT_MP_SWIM ]                      = index + 9

    if t == "normal" then -- "normal" jump animation doesn't exist
        self.ActivityTranslate[ACT_MP_JUMP] = ACT_HL2MP_JUMP_SLAM
    end

    self:SetupWeaponHoldTypeForAI(t)
end

---base class name -> hold type
local NPCHoldType = {
    weapon_splatoonsweps_blaster_base = "smg",
    weapon_splatoonsweps_charger      = "smg",
    weapon_splatoonsweps_shooter      = "smg",
    weapon_splatoonsweps_slosher_base = "smg",
    weapon_splatoonsweps_splatling    = "smg",
    weapon_splatoonsweps_roller       = "melee",
    weapon_splatoonsweps_special      = "smg",
}
---Translates generic ACT to specific one for NPCs
---@param act integer ACT enum
---@return integer translated Translated ACT enum
function SWEP:TranslateActivity(act)
    if self:GetOwner():IsNPC() then
        local h = NPCHoldType[self.Base] ---@type string
        local a = self.ActivityTranslateAI
        local invalid = self:GetOwner():SelectWeightedSequence(a[h][act] or 0) < 0
        return not invalid and a[h][act] or a.smg[act] or -1
    end

    local holdtype = ss.ProtectedCall(self.CustomActivity, self) or "passive"
    if CurTime() > self:GetCooldown() and self:Crouching() then holdtype = "melee2" end
    if self:GetThrowing() then holdtype = "grenade" end
    self.HoldType = holdtype
    self:SetHoldType(holdtype)

    local translate = self.Translate[holdtype]
    return translate and translate[act] or -1
end

---Called before firing animation events, such as muzzle flashes or shell ejections.
---@param pos Vector
---@param ang Angle
---@param event integer
---@param options string
---@return boolean disabled True to disable the effect.
function SWEP:FireAnimationEvent(pos, ang, event, options)
    return ss.FireAnimationEvent(self, pos, ang, event, options)
end

---Creates squid entity
function SWEP:MakeSquidModel()
    if CLIENT then return end
    local Owner = self:GetOwner()
    local squid = self:GetNWEntity "Squid"
    if IsValid(squid) then squid:Remove() end
    if not IsValid(Owner) then return end
    if not Owner:IsPlayer() then return end
    self:SetNWEntity("Squid", ents.Create "ent_splatoonsweps_squid")
    if not IsValid(self:GetNWEntity "Squid") then return end
    squid = self:GetNWEntity "Squid"
    squid:SetPos(self:GetOwner():GetPos())
    squid:SetAngles(self:GetOwner():GetAngles())
    squid:SetNWEntity("Owner", self:GetOwner())
    squid:SetNWEntity("Weapon", self)
    squid:SetParent(self)
    squid:Spawn()
end
