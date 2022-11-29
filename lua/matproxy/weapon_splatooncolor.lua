
-- Team Fortress 2 is required.
if not IsMounted "tf" then return end

local OldItemTintBind
local function ItemTintInit(self, mat, values)
    self.ResultTo = values.resultvar -- Store the name of the variable we want to set
end

for _, a in ipairs(engine.GetAddons()) do
    if a.wsid == "135491961" and a.mounted then
        include "matproxy/tf2itempaint.lua" -- Hat Painter & Crit Glow Tools conflicts
        ItemTintInit = matproxy.ProxyList.ItemTintColor.init -- So take some workaround
        OldItemTintBind = matproxy.ProxyList.ItemTintColor.bind
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

matproxy.Add {
    name = "ItemTintColor",
    init = ItemTintInit,
    bind = ItemTintBind,
}
