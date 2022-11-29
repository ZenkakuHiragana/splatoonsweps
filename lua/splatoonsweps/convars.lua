
local ss = SplatoonSWEPs
if not ss then return end

require "greatzenkakuman/cvartree"
local gc = greatzenkakuman.cvartree
local HelpTextPrefix = "Splatoon SWEPs: "

gc.OverrideHelpText = ss.Text.OverrideHelpText
gc.SetCVarPrefix("splatoonsweps", {printname = ss.Text.Category})

local function SendValue(cvarname, value)
    if ss.sp or cvarname:StartWith "sv_" then
        net.Start "greatzenkakuman.cvartree.adminchange"
        net.WriteString(cvarname)
        net.WriteString(tostring(value))
        net.SendToServer()
    elseif not GetGlobalBool "SplatoonSWEPs: IsDedicated" and LocalPlayer():IsAdmin() then
        net.Start "greatzenkakuman.cvartree.sendchange"
        net.WriteString(cvarname)
        net.WriteString(tostring(value))
        net.SendToServer()
    else
        local cvar = GetConVar(cvarname)
        if not cvar then return end
        cvar:SetInt(value)
    end
end

local InkColors = ss.InkColors -- These are needed when the SWEPs
local ColorNames = ss.Text.ColorNames -- are disabled.
local function MakeColorGUI(parent_panel, paneltable, cvar, admin)
    local cvarname = cvar:GetName()
    local element = vgui.Create("DPanel", parent_panel)
    local label = Label(paneltable.printname, element)
    local colorpicker = vgui.Create("DIconLayout", element)
    element:DockPadding(4, 0, 4, 4)
    label:Dock(TOP)
    label:SetTextColor(label:GetSkin().Colours.Label.Dark)
    colorpicker:Dock(FILL)
    colorpicker:SetSpaceX(5)
    colorpicker:SetSpaceY(5)
    colorpicker:SetStretchHeight(true)
    for i, c in ipairs(InkColors) do
        local item = colorpicker:Add "DColorButton"
        item:SetSize(32, 32)
        item:SetColor(c)
        item:SetTooltip(ColorNames[i])
        item:SetContentAlignment(5)
        function item:Think() item:SetText(i == cvar:GetInt() and "X" or "") end
        function item:DoClick()
            SendValue(cvarname, i)
        end
    end

    colorpicker:Layout()
    function element:PerformLayout()
        colorpicker:InvalidateLayout(true)
        self:SizeToChildren(false, true)
        if not self.CheckBox then return end
        self.CheckBox:DockMargin(0, 4, 0, self:GetTall() - 15 - 4)
    end

    return element
end

local function MakeOnChangeDerma(paneltable)
    return function(self, value)
        SendValue(self.CVarName, value)
    end
end

local function MakeOnChangeCVar(paneltable)
    return function(convar, old, new)
    end
end

local function RegisterConVars(opt, helptext, guitext)
    for cvarname, cvartable in pairs(opt) do
        if not cvarname:StartWith "__" then
            if not istable(cvartable) then cvartable = {cvartable} end
            if cvartable[1] ~= nil then
                local options = table.Copy(cvartable)
                options.printname, options[1] = guitext[cvarname]
                options.helptext = guitext[cvarname .. "_help"]
                if options.type == "color" then
                    options.cvaronchange = MakeOnChangeCVar
                    options.dermaonchange = MakeOnChangeDerma
                    options.enablepanel = nil
                    options.makepanel = MakeColorGUI
                    options.typeconversion = tonumber
                end

                gc.AddCVar(cvarname, cvartable[1], HelpTextPrefix .. helptext[cvarname], options)
            else
                gc.AddCVarPrefix(cvarname, {
                    subcategory = cvartable.__subcategory,
                    closed = cvartable.__closed,
                    printname =
                    ss.Text.CategoryNames[cvarname] -- Weapon category name (Shooters, Rollers, etc.)
                    or ss.Text.PrintNames[cvarname] -- Weapon name (.52 Gallon, etc.)
                    or guitext[cvarname].__printname, -- Other categories (Gain, NPC ink color, etc.)
                })

                RegisterConVars(cvartable, helptext[cvarname], guitext[cvarname])
                gc.RemoveCVarPrefix()
            end
        end
    end
end

RegisterConVars(ss.Options, ss.Text.CVars, ss.Text.Options)
if CLIENT then gc.AddGUI "splatoonsweps" end

local RealmPrefix = {[true] = "sv", [false] = "cl"}
function ss.GetConVarName(name, serverside)
    local cvar = (RealmPrefix[serverside] or "") .. "_splatoonsweps"
    if isstring(name) then
        return cvar .. "_" .. name
    elseif istable(name) then
        for _, n in ipairs(name) do cvar = cvar .. "_" .. n end
        return cvar
    end
end

function ss.GetConVar(name, serverside)
    local prefix = serverside == nil and "cl" or ""
    return GetConVar(prefix .. ss.GetConVarName(name, serverside))
end

-- Fetch a given option.
-- Arguments:
--   string name    | The option name.
--   Player ply     | Whose option the function will return.
-- Returning:
--   function (if the option is a subcategory)
--   number/bool (depends on default value)
function ss.GetOption(name, ply)
    local nametable = {"splatoonsweps"}
    if isstring(name) then name = {name} end
    for _, n in ipairs(name) do nametable[#nametable + 1] = n:lower() end
    return gc.GetPreference(nametable, ply)
end
