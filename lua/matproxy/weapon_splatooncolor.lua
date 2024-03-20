
local OldItemTintBind ---@type function

---@param self table
---@param mat string
---@param values table<string, any>
local function ItemTintInit(self, mat, values)
    self.ResultTo = values.resultvar -- Store the name of the variable we want to set
end

for _, a in ipairs(engine.GetAddons()) do
    if a.wsid == "135491961" and a.mounted then
        include "matproxy/tf2itempaint.lua" -- Hat Painter & Crit Glow Tools conflicts
        local ItemTintColor = matproxy.ProxyList.ItemTintColor --[[@as MatProxyData]]
        ItemTintInit = ItemTintColor.init -- So take some workaround
        OldItemTintBind = ItemTintColor.bind
    end
end

local function ItemTintBind(self, mat, ent)
    if not IsValid(ent) then return end
    if isfunction(ent.GetInkColorProxy) and isvector(ent:GetInkColorProxy()) then
        -- If the target ent has a function called GetInkColorProxy then use that
        -- The function SHOULD return a Vector with the chosen ink color.
        mat:SetVector(self.ResultTo, ent:GetInkColorProxy())
    elseif OldItemTintBind then
        return OldItemTintBind(self, mat, ent)
    else
        mat:SetVector(self.ResultTo, vector_origin)
    end
end

---@param self table
---@param mat string
---@param values table<string, any>
local function BubblerInit(self, mat, values)
    self.ResultVar = values.resultvar
    self.ResultVar2 = values.resultvar2
end

---@class CSEnt.Bubbler : CSEnt
---@field InitTime number
---@field IsDisappearing boolean

---@param self table
---@param mat IMaterial
---@param ent CSEnt.Bubbler
local function BubblerBind(self, mat, ent)
    if not IsValid(ent) then return end
    mat:SetFloat(self.ResultVar, ent.InitTime or 0)
    mat:SetFloat(self.ResultVar2, ent.IsDisappearing and 1 or 0)
end

matproxy.Add {
    name = "ItemTintColor",
    init = ItemTintInit,
    bind = ItemTintBind,
}

matproxy.Add {
    name = "SplatoonSWEPsBubbler",
    init = BubblerInit,
    bind = BubblerBind,
}
