
-- SplatoonSWEPs.DTabPlus
local PANEL = {}
function PANEL:GetTabHeight(Active)
    local fix = self.Image and 4 or 8
    local h = self.Image and self.Image:GetTall() or select(2, self:GetContentSize())
    if Either(Active ~= nil, Active, self:IsActive()) then
        return fix + h + 8
    else
        return fix + h
    end
end

function PANEL:Setup(label, pPropertySheet, pPanel, strMaterial)
    self:SetText(label)
    self:SetPropertySheet(pPropertySheet)
    self:SetPanel(pPanel)
    if strMaterial then
        self.Image = vgui.Create("DImage", self)
        self.Image:SetImage(strMaterial)
        self.Image:SizeToContents()
        self:InvalidateLayout(true)
    end
end

function PANEL:PerformLayout()
    self:ApplySchemeSettings()
    if not self.Image then return end
    local y = 3
    local PropertySheet = self:GetPropertySheet()
    local Max = PropertySheet:GetMaxTabSize()
    local Min = PropertySheet:GetMinTabSize()
    local Width = math.Clamp(self.Image:GetWide(), Min, Max > 0 and Max or 32768)
    local Height = math.Clamp(self.Image:GetTall(), Min, Max > 0 and Max or 32768)
    if PropertySheet:GetTabDock() == BOTTOM then
        y = 1 + (self:IsActive() and PropertySheet:GetPadding() or 0)
    end

    self.Image:SetPos(7, y)
    self.Image:SetSize(Width, Height)

    if self:GetText():len() == 0 then
        self.Image:CenterHorizontal()
    end

    if self:IsActive() then
        self.Image:SetImageColor(color_white)
    else
        self.Image:SetImageColor(ColorAlpha(color_white, 155))
    end
end

function PANEL:ApplySchemeSettings()
    local PropertySheet = self:GetPropertySheet()
    local TabHeight = PropertySheet:GetTabHeight()
    local Padding = PropertySheet:GetPadding()
    local ExtraInset = 10
    local InsetY = -4
    if self.Image then
        ExtraInset = ExtraInset + self.Image:GetWide()
    end

    if PropertySheet:GetTabDock() == TOP and self:IsActive() then
        InsetY = InsetY - Padding
    end

    self:SetTextInset(ExtraInset, InsetY)
    self:SetSize(self:GetContentSize() + 10, self:GetTabHeight())
    self:SetContentAlignment(1)

    if TabHeight then
        local y = TabHeight - self:GetTabHeight(true)
        if PropertySheet:GetTabDock() == BOTTOM then
            y = self:IsActive() and 0 or Padding
        end

        self:SetPos(self:GetPos(), y)
    end

    DLabel.ApplySchemeSettings(self)
end

function PANEL:Paint(w, h)
    local skin = derma.GetDefaultSkin()
    local PropertySheet = self:GetPropertySheet()
    local dock = PropertySheet:GetTabDock()
    local y = 0
    local func = {
        [TOP] = {
            [true] = {skin.tex.TabT_Active, 0, h},
            [false] = {skin.tex.TabT_Inactive, 0, h},
        },
        [BOTTOM] = {
            [true] = {skin.tex.TabB_Active, 0, h},
            [false] = {skin.tex.TabB_Inactive, 0, h},
        },
        [LEFT] = {
            [true] = {skin.tex.TabL_Active, 0, h},
            [false] = {skin.tex.TabL_Inactive, 0, h},
        },
        [RIGHT] = {
            [true] = {skin.tex.TabR_Active, 0, h},
            [false] = {skin.tex.TabR_Inactive, 0, h},
        },
    }

    local paint = (func[dock] or {})[self:IsActive()]
    paint, y, h = unpack(paint or {})
    if not isfunction(paint) then return end
    paint(0, y, w, h)
end

function PANEL:PaintActiveTab(skin, w, h)
    skin.tex.TabT_Active(0, 0, w, h)
end


derma.DefineControl("SplatoonSWEPs.DTabPlus", "", PANEL, "DTab")

-- SplatoonSWEPs.DPropertySheetPlus
PANEL = {}
AccessorFunc(PANEL, "m_iTabDock", "TabDock", FORCE_NUMBER)
AccessorFunc(PANEL, "m_iTabHeight", "TabHeight", FORCE_NUMBER)
AccessorFunc(PANEL, "m_iMaxTabSize", "MaxTabSize", FORCE_NUMBER)
AccessorFunc(PANEL, "m_iMinTabSize", "MinTabSize", FORCE_NUMBER)

function PANEL:Init()
    self:SetMaxTabSize(-1)
    self:SetMinTabSize(0)
    self:SetTabHeight(self:GetPadding())
    self:SetTabDock(BOTTOM)
    self.tabScroller:Dock(self:GetTabDock())
end

function PANEL:AddSheet(label, panel, material, NoStretchX, NoStretchY, Tooltip)
    if not IsValid(panel) then
        ErrorNoHalt("SplatoonSWEPs.DPropertySheetPlus: AddSheet tried to add invalid panel!")
        debug.Trace()
        return
    end

    local Sheet = {}
    Sheet.Name = label

    Sheet.Tab = vgui.Create("SplatoonSWEPs.DTabPlus", self)
    Sheet.Tab:SetTooltip(Tooltip)
    Sheet.Tab:Setup(label, self, panel, material)

    Sheet.Panel = panel
    Sheet.Panel.NoStretchX = NoStretchX
    Sheet.Panel.NoStretchY = NoStretchY
    Sheet.Panel:SetPos(self:GetPadding(), self:GetPadding())
    Sheet.Panel:SetVisible(false)

    panel:SetParent(self)

    self.Items[#self.Items + 1] = Sheet
    self.tabScroller:AddPanel(Sheet.Tab)
    self:SetTabHeight(math.max(self:GetTabHeight(), Sheet.Tab:GetTabHeight(true)))

    if not self:GetActiveTab() then
        self:SetActiveTab(Sheet.Tab)
        Sheet.Panel:SetVisible(true)
    end

    return Sheet
end

function PANEL:PerformLayout()
    local ActiveTab = self:GetActiveTab()
    local Padding = self:GetPadding()
    if not IsValid(ActiveTab) then return end

    local ActivePanel = ActiveTab:GetPanel()
    local TabHeight = self:GetTabHeight()
    self.tabScroller:SetTall(TabHeight)

    for _, v in pairs(self.Items) do
        local y = TabHeight - v.Tab:GetTabHeight(true)
        if v.Tab:GetPanel() == ActivePanel then
            if IsValid(v.Tab:GetPanel()) then v.Tab:GetPanel():SetVisible(true) end
            v.Tab:SetZPos(2)
        else
            if self:GetTabDock() == BOTTOM then y = 0 end
            if IsValid(v.Tab:GetPanel()) then v.Tab:GetPanel():SetVisible(false) end
            v.Tab:SetZPos(1)
        end

        v.Tab:SetPos(v.Tab:GetPos(), y)
        v.Tab:ApplySchemeSettings()
    end

    if IsValid(ActivePanel) then
        if ActivePanel.NoStretchX then
            ActivePanel:CenterHorizontal()
        else
            ActivePanel:SetWide(self:GetWide() - Padding * 2)
        end

        if ActivePanel.NoStretchY then
            ActivePanel:CenterVertical()
        else
            local y = TabHeight
            if self:GetTabDock() == BOTTOM then y = Padding end
            ActivePanel:SetPos(ActivePanel:GetPos(), y)
            ActivePanel:SetTall(self:GetTall() - TabHeight - Padding)
        end

        ActivePanel:InvalidateLayout()
    end

    -- Give the animation a chance
    self.animFade:Run()
end

function PANEL:Paint(w, h)
    local skin = derma.GetDefaultSkin()
    local Offset = self:GetTabHeight() - self:GetPadding()
    local Pos = {
        [TOP] = {0, Offset, 0, Offset},
        [BOTTOM] = {0, 0, 0, Offset},
        [LEFT] = {Offset, 0, Offset, 0},
        [RIGHT] = {0, 0, Offset, 0},
    }

    local dx, dy, dw, dh = unpack(Pos[self:GetTabDock()] or {})
    skin.tex.Tab_Control(assert(dx), dy, w - dw, h - dh)
end

derma.DefineControl("SplatoonSWEPs.DPropertySheetPlus", "", PANEL, "DPropertySheet")
