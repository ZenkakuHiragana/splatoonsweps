AddCSLuaFile()
module("greatzenkakuman.localization", package.seeall)

Texts = {}
local cvarlang = GetConVar "gmod_language"
local FileList, Workspace = {}, ""
local function LoadText(folder)
    local language = cvarlang:GetString()
    local path = folder .. "en.lua"
    if file.Exists(path, "LUA") then table.Merge(Texts, include(path)) end
    path = folder .. language .. ".lua"
    if file.Exists(path, "LUA") then table.Merge(Texts, include(path)) end
end

local function RefreshTexts(convar, old, new)
    table.Empty(Texts)
    for _, f in ipairs(FileList) do LoadText(f) end
end

cvars.AddChangeCallback("gmod_language", RefreshTexts, "GreatZenkakuMan's Module: OnLanguageChanged")

function ClearTexts()
    table.Empty(FileList)
    table.Empty(Texts)
end

function IncludeTexts(folder)
    Workspace = folder .. "/"
    local directories = select(2, file.Find(Workspace .. "*", "LUA"))
    for _, d in ipairs(directories) do
        if SERVER then -- We need to run AddCSLuaFile() for all languages.
            local path = Workspace .. d .. "/"
            local files = file.Find(path .. "*.lua", "LUA")
            for _, f in ipairs(files) do
                AddCSLuaFile(path .. f)
            end
        end

        local path = Workspace .. d .. "/"
        FileList[#FileList + 1] = path
        LoadText(path)
    end

    return Texts
end

if SERVER then
    util.AddNetworkString "greatzenkakuman.localization.chatprint"
else
    local function DoChatPrint(texttable)
        local text = Texts
        for _, t in ipairs(texttable) do
            if not istable(text) then break end
            text = text[t]
        end

        LocalPlayer():ChatPrint(text)
    end

    net.Receive("greatzenkakuman.localization.chatprint", function()
        DoChatPrint(net.ReadTable())
    end)
end

function ChatPrint(texttable, ply)
    if not istable(texttable) then texttable = {texttable} end
    if CLIENT then return DoChatPrint(texttable) end
    if not (IsValid(ply) and ply:IsPlayer()) then return end
    net.Start "greatzenkakuman.localization.chatprint"
    net.WriteTable(t)
    net.Send(ply)
end
