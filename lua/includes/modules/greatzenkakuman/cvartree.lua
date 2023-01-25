AddCSLuaFile()
local serverflags = {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}
local clientflags = {FCVAR_ARCHIVE, FCVAR_USERINFO}
local cvarlist = {}
local cvarprefix = {}
local cvarseparator = "_"
module("greatzenkakuman.cvartree", package.seeall)

OverrideHelpText = "Override this setting with serverside value"

local function CreateCategory(nametable)
    local n, placeholder = "", cvarlist
    for _, s in ipairs(nametable) do
        n = string.format("%s%s%s", n, cvarseparator, s)
        placeholder[s] = placeholder[s] or {iscvarlayer = true, options = {}}
        placeholder = placeholder[s]
    end

    return n, placeholder
end

function GetCVarList() return cvarlist end
function GetCVarPrefix() return cvarprefix end
function SetCVarPrefix(p, options)
    table.Empty(cvarprefix)
    return AddCVarPrefix(p, options)
end

function AddCVarPrefix(p, options)
    if isstring(p) then
        cvarprefix[#cvarprefix + 1] = p:lower()
        local placeholder = select(2, CreateCategory(cvarprefix))
        if istable(options) then table.Merge(placeholder.options, options) end
    elseif istable(p) then
        for _, s in ipairs(p) do AddCVarPrefix(s) end
    end

    return AddCVarPrefix
end

function RemoveCVarPrefix(n)
    for _ = 1, n or 1 do cvarprefix[#cvarprefix] = nil end
    return RemoveCVarPrefix
end

function AddCVar(name, default, helptext, options)
    local nametable = istable(name) and name or table.Copy(cvarprefix)
    if isstring(name) then nametable[#nametable + 1] = name:lower() end

    options = options or {}
    name, nametable[#nametable] = nametable[#nametable]
    local n, placeholder = CreateCategory(nametable)

    if #n == 0 then return end
    local cvartable = placeholder[name] or {}
    if not (options and options.clientside) then
        local svdefault = not (options and options.serverside) and -1 or default
        local svname = string.format("sv%s%s%s", n, cvarseparator, name)
        if isbool(svdefault) then svdefault = svdefault and 1 or 0 end
        cvartable.sv = CreateConVar(svname, tostring(svdefault), serverflags, helptext)
    end

    if not (options and options.serverside) then
        local clname = string.format("cl%s%s%s", n, cvarseparator, name)
        local cldefault = isbool(default) and (default and 1 or 0) or default
        cvartable.cl = CreateConVar(clname, tostring(cldefault), clientflags, helptext)
    end

    options.type = options.type == nil and type(default) or options.type
    cvartable.options = options
    cvartable.location = nametable
    placeholder[name] = cvartable
end

function GetCVarTable(cvar, root)
    local t = root or cvarlist
    if isstring(cvar) then cvar = {cvar} end
    for _, n in ipairs(cvar or {}) do
        t = assert(t[n:lower()], "GreatZenkakuMan's Module: preference is not found.")
    end

    return t
end

local TranslateType = {
    boolean = tobool,
    number = tonumber,
}
function GetValue(t, ply)
    local servervalue = t.sv and t.sv:GetString()
    local override = tonumber(servervalue)
    local translate = TranslateType[t.options.type] or t.options.typeconversion
    if override and override ~= -1 or SERVER and not (IsValid(ply) and ply:IsPlayer()) then
        return not translate and servervalue or translate(servervalue)
    elseif not t.options.serverside then
        local value = SERVER and ply:GetInfo(t.cl:GetName()) or t.cl:GetString()
        if value == "" then value = t.cl:GetDefault() end -- For bots
        return not translate and value or translate(value)
    end
end

function GetPreference(cvar, ply, root)
    local t = GetCVarTable(cvar, root)
    if not (t.cl or t.sv) then
        return function(c, p) return GetPreference(c, p, t) end
    end

    return GetValue(t, ply)
end

function SetPreference(cvar, value, root)
    local t = GetCVarTable(cvar, root)
    if not (t.cl or t.sv) then
        return function(c, v) return SetPreference(c, v, t) end
    end
    if not t.options.clientside then
        t.sv:SetString(tostring(value))
    end
    if not t.options.serverside then
        local str = tostring(value)
        if value == nil then str = "" end
        if isbool(value) then str = value and "1" or "0" end
        if CLIENT and game.SinglePlayer() then
            net.Start "greatzenkakuman.cvartree.sendchange"
            net.WriteString("cl" .. cvarseparator .. table.concat(cvar, cvarseparator))
            net.WriteString(str)
            net.SendToServer()
        else
            t.cl:SetString(str)
        end
    end
end

function SetPrintName(cvar, name)
    local t = GetCVarTable(cvar)
    if t.panel then t.panel:SetText(name) end
    if t.paneladmin then t.paneladmin:SetText(name) end
    t.printname = name
end

function IteratePreferences(root)
    local t = root and GetCVarTable(root) or cvarlist
    local function f(r)
        for prefname, preftable in pairs(r or t) do
            if istable(preftable) then
                if preftable.iscvarlayer then
                    f(preftable)
                elseif preftable.cl or preftable.sv then
                    coroutine.yield(prefname, preftable)
                end
            end
        end
    end

    return coroutine.wrap(f)
end

if SERVER then
    util.AddNetworkString "greatzenkakuman.cvartree.adminchange"
    util.AddNetworkString "greatzenkakuman.cvartree.sendchange"
    util.AddNetworkString "greatzenkakuman.cvartree.synchronizeconvars"
    net.Receive("greatzenkakuman.cvartree.adminchange", function(_, ply)
        if not ply:IsAdmin() then return end
        local cvar = GetConVar(net.ReadString())
        if not cvar then return end
        cvar:SetString(net.ReadString())
    end)

    net.Receive("greatzenkakuman.cvartree.sendchange", function(_, ply)
        local name = net.ReadString()
        if not name:StartWith "cl_" then return end
        local cvar = GetConVar(name)
        if not cvar then return end
        cvar:SetString(net.ReadString())
    end)

    net.Receive("greatzenkakuman.cvartree.synchronizeconvars", function(_, ply)
        for _, cvartable in IteratePreferences() do
            if cvartable.options and cvartable.options.serverside then
                local str = cvartable.sv:GetString() -- It's really hacky way
                cvartable.sv:SetString(str .. "*") -- to synchronize CVars,
                cvartable.sv:SetString(str) -- but whatever.
            end
        end
    end)

    return
end

hook.Add("PlayerConnect", "greatzenkakuman.cvartree.synchronizeconvars", function(name, ply)
    net.Start "greatzenkakuman.cvartree.synchronizeconvars"
    net.SendToServer()
end)

-- PreferenceTable -> pt, IsEnabledPanel -> e
local idprefix = "GreatZenkakuMan's Module: CVarTree"
local function EnablePanel(panel, panelType, enabled, func)
    panel:SetEnabled(enabled)
    for _, c in ipairs(panel:GetChildren()) do c:SetEnabled(enabled) end

    if panelType == "number" then
        local s = enabled and "Dark" or "Default"
        local l, t = panel.Label, panel:GetTextArea()
        l:SetTextColor(l:GetSkin().Colours.Label[s])
        t:SetTextColor(t:GetSkin().Colours.Label[s])
        for _, c in ipairs(panel:GetChildren()) do
            c:SetMouseInputEnabled(enabled)
            c:SetKeyboardInputEnabled(enabled)
        end
    elseif isfunction(func) then
        func(panel, enabled)
    end
end

local function GetCVarOnChange(pt)
    if pt.options.type == "boolean" then
        return function(convar, old, new)
            if not (IsValid(LocalPlayer()) and LocalPlayer():IsAdmin()) then return end
            if pt.panel then pt.panel:SetChecked(tobool(new)) end
            if pt.paneladmin then pt.paneladmin:SetChecked(tobool(new)) end
        end
    elseif pt.options.type == "number" then
        return function(convar, old, new)
            if not (IsValid(LocalPlayer()) and LocalPlayer():IsAdmin()) then return end
            if pt.panel and not pt.panel:IsEditing() then pt.panel:SetValue(tonumber(new)) end
            if pt.paneladmin and not pt.paneladmin:IsEditing() then pt.paneladmin:SetValue(tonumber(new)) end
        end
    elseif isfunction(pt.options.cvaronchange) then
        return pt.options.cvaronchange(pt)
    end
end

local function GetDermaPanelOnChange(pt)
    if not pt.paneladmin then return end
    if pt.options.type == "boolean" then
        function pt.paneladmin:OnChange(value)
            net.Start "greatzenkakuman.cvartree.adminchange"
            net.WriteString(self.CVarName)
            net.WriteString(value and "1" or "0")
            net.SendToServer()
        end

        return pt.paneladmin.OnChange
    elseif pt.options.type == "number" then
        function pt.paneladmin:OnValueChanged(value)
            value = math.Round(value, self:GetDecimals())
            net.Start "greatzenkakuman.cvartree.adminchange"
            net.WriteString(self.CVarName)
            net.WriteString(tostring(value))
            net.SendToServer()
        end

        return pt.paneladmin.OnValueChanged
    elseif isfunction(pt.options.dermaonchange) then
        return pt.options.dermaonchange(pt)
    end
end

local function MakeElement(p, admin, pt)
    local cvar = Either(admin, pt.sv, pt.cl)
    local panel = admin and "paneladmin" or "panel"
    if not cvar or Either(admin, pt.options.clientside, pt.options.serverside) then return end
    if game.SinglePlayer() and admin and not pt.options.serverside then return end
    if pt.options.type == "boolean" then
        pt[panel] = vgui.Create("DCheckBoxLabel", p)
        pt[panel]:SetTextColor(pt[panel]:GetSkin().Colours.Label.Dark)
        pt[panel]:SetValue(cvar:GetBool())
    elseif pt.options.type == "number" then
        pt[panel] = vgui.Create("DNumSlider", p)
        pt[panel]:SetMinMax(pt.options.min, pt.options.max)
        pt[panel]:SetDecimals(pt.options.decimals or 0)
        pt[panel]:SetValue(cvar:GetInt())
        pt[panel].Label:SetTextColor(pt[panel].Label:GetSkin().Colours.Label.Dark)
    elseif isfunction(pt.options.makepanel) then
        pt[panel] = pt.options.makepanel(p, pt, cvar, admin)
    end

    pt[panel].CVarName = cvar:GetName()
    pt[panel]:SetText(pt.printname)

    local override
    if admin then
        local dermaonchange = GetDermaPanelOnChange(pt)
        cvars.AddChangeCallback(pt[panel].CVarName, GetCVarOnChange(pt))

        if not pt.options.serverside then
            local checked = cvar:GetInt() ~= -1
            EnablePanel(pt.paneladmin, pt.options.type, checked)
            override = vgui.Create("DCheckBox", p)
            override:SetTooltip(OverrideHelpText)
            override:SetValue(checked)
            cvars.AddChangeCallback(pt[panel].CVarName, function(convar, old, new)
                if not (IsValid(LocalPlayer()) and LocalPlayer():IsAdmin()) then return end
                local chk = tonumber(new) ~= -1
                override:SetChecked(chk)
                EnablePanel(pt.paneladmin, pt.options.type, chk)
            end)

            function override:OnChange(chk)
                EnablePanel(pt.paneladmin, pt.options.type, chk)
                dermaonchange(pt.paneladmin, pt.cl:GetDefault())
                net.Start "greatzenkakuman.cvartree.adminchange"
                net.WriteString(pt[panel].CVarName)
                net.WriteString(chk and pt.cl:GetDefault() or "-1")
                net.SendToServer()
            end
        end
    elseif isfunction(pt[panel].SetConVar) then
        pt[panel]:SetConVar(cvar:GetName())
    end

    if not admin and pt.sv then
        pt[panel].Think = function()
            EnablePanel(pt[panel], pt.options.type, pt.sv:GetInt() == -1, pt.options.enablepanel)
        end
    end

    p:AddItem(override or pt[panel], override and pt[panel])
    if override then
        local t = (pt[panel]:GetTall() - 15) / 2
        local b = t + (t > math.floor(t) and 1 or 0)
        override:DockMargin(0, math.floor(t), 0, b)
        override:SetWidth(15)
        pt[panel].CheckBox = override
        pt[panel]:Dock(TOP)
        pt[panel]:DockMargin(10, 0, 0, 0)
    end

    if not pt.options.helptext then return end
    pt[panel]:SetTooltip(pt.options.helptext)
end

local function MakeGUI(p, nametable, admin)
    local categories, sorted, sortedlast, preferences = {}, {}, {}, {}
    for name, pt in pairs(GetCVarTable(nametable)) do
        if not name:StartWith "__" and istable(pt) then
            pt.printname = pt.printname or pt.options and pt.options.printname or name
            if pt.iscvarlayer then
                categories[name] = pt
            elseif pt.options and not pt.options.hidden then
                if pt.options.order then
                    pt.order = pt.options.order
                    sorted[name] = pt
                elseif pt.options.bottomorder then
                    pt.bottomorder = pt.options.bottomorder
                    sortedlast[name] = pt
                else
                    preferences[name] = pt
                end
            end
        end
    end

    for _, pt in SortedPairsByMemberValue(sorted, "order") do MakeElement(p, admin, pt) end
    for _, pt in SortedPairsByMemberValue(preferences, "printname") do MakeElement(p, admin, pt) end
    for _, pt in SortedPairsByMemberValue(sortedlast, "bottomorder", true) do MakeElement(p, admin, pt) end
    for name, pt in SortedPairs(categories) do
        if pt.options.subcategory then
            pt.panel = p
            local l = p:Help(pt.printname)
            l:DockMargin(0, 0, 8, 8)
            l:SetTextColor(l:GetSkin().Colours.Tree.Hover)
        else
            pt.panel = vgui.Create("ControlPanel", p)
            pt.panel:SetLabel(pt.printname)
            if pt.options.closed then
                pt.panel:SetExpanded(false)
            end

            p:AddPanel(pt.panel)
        end

        local nt = table.Copy(nametable)
        nt[#nt + 1] = name
        MakeGUI(pt.panel, nt, admin)
    end

    for _, i in ipairs(p.Items) do
        local c = i:GetChild(0)
        if c and c:GetName() ~= "DLabel" then return end
    end

    p:Remove()
end

function AddGUI(name)
    if isstring(name) then name = {name} end
    local t = GetCVarTable(name)
    local printname = t.printname or t.options and t.options.printname or name[#name]
    hook.Add("PopulateToolMenu", idprefix .. printname, function()
        spawnmenu.AddToolMenuOption("Utilities", "User",
        idprefix .. printname, printname, "", "", function(p)
            p:ClearControls()
            MakeGUI(p, name)
        end)

        spawnmenu.AddToolMenuOption("Utilities", "Admin",
        "CVarTreeAdmin" .. printname, printname, "", "", function(p)
            p:ClearControls()
            MakeGUI(p, name, true)
            local think = p.Think
            function p:Think()
                if not IsValid(LocalPlayer()) then return end
                p.Think = think
                if LocalPlayer():IsAdmin() then return end
                p:Remove()
            end
        end)
    end)
end

-- require "greatzenkakuman/cvartree"
-- print("Test>", greatzenkakuman)
-- if not greatzenkakuman then return end
-- print("Test>", greatzenkakuman.cvartree)

-- local ct = greatzenkakuman.cvartree
-- ct.AddCVar({"greatzenkakuman", "tree", "preference1"}, 0, "Text Help")
-- ct.AddCVarPrefix "greatzenkakuman" "tree"
-- ct.AddCVar("preference2", 25, "Overridable/GZM/Tree/preference2", {type = "number", min = 0, max = 50})
-- ct.SetCVarPrefix "greatzenkakuman" "tree2"
-- ct.AddCVar("serveronly1", 1, "Serveronly/GZM/Tree2/Serveronly1", {serverside = true})
-- ct.AddCVar("clientonly1", 1, "Clientonly/GZM/Tree2/Clientonly1", {clientside = true})
-- ct.SetCVarPrefix()
-- ct.AddCVar({"greatzenkakuman", "tree3", "subtree1", "four_layers"}, 2, "Four layers test", {type = "number", min = 1, max = 3, decimals = 1})

-- ct.SetPrintName("greatzenkakuman", "GreatZenkakuMan's Preference")
-- ct.SetPrintName({"greatzenkakuman", "tree"}, "Tree1")
-- ct.SetPrintName({"greatzenkakuman", "tree2"}, "Tree2")
-- ct.SetPrintName({"greatzenkakuman", "tree", "preference1"}, "Preference 1")
-- ct.SetPrintName({"greatzenkakuman", "tree", "preference2"}, "Preference 2")
-- ct.SetPrintName({"greatzenkakuman", "tree2", "serveronly1"}, "Server")
-- ct.SetPrintName({"greatzenkakuman", "tree2", "clientonly1"}, "Client")
-- ct.SetPrintName({"greatzenkakuman", "tree3"}, "Tree3")
-- ct.SetPrintName({"greatzenkakuman", "tree3", "subtree1"}, "Sub-tree1")
-- ct.SetPrintName({"greatzenkakuman", "tree3", "subtree1", "four_layers"}, "Four layer test")
-- if CLIENT then ct.AddGUI "greatzenkakuman" end
-- PrintTable(ct.GetCVarList())
