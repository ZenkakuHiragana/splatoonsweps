
-- Weapon names, descriptions, and other texts.
require "greatzenkakuman/localization"

local ss = SplatoonSWEPs
local gl = greatzenkakuman.localization
local function TableToString(t)
    local str = ""
    for i, v in ipairs(t) do
        if i > 1 then str = str .. "\n" end
        str = str .. tostring(i) .. ":\t" .. tostring(v)
    end

    return str
end

if not ss then return end
ss.Text = gl.IncludeTexts "splatoonsweps/constants/texts"
ss.Text.CVars.InkColor = ss.Text.CVars.InkColor .. TableToString(ss.Text.ColorNames)
ss.Text.CVars.Playermodel = ss.Text.CVars.Playermodel .. TableToString(ss.Text.PlayermodelNames)

if SERVER then return end
language.Add("Cleanup_" .. ss.CleanupTypeInk, ss.Text.CleanupInk)
language.Add("Cleaned_" .. ss.CleanupTypeInk, ss.Text.CleanupInkMessage)
steamworks.RequestPlayerInfo("76561198013738310", function(name) ss.Text.Author = name end)
