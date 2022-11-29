
-- SplatoonSWEPs library inclusions

local SharedDirectory = "splatoonsweps/"
local ServerDirectory = SharedDirectory .. "server/"
local ClientDirectory = SharedDirectory .. "client/"
if SERVER then -- Finds all Lua files used on client and AddCSLuaFile() them.
    local shared = file.Find(SharedDirectory .. "*.lua", "LUA")
    local client = file.Find(ClientDirectory .. "*.lua", "LUA")
    for i, filename in ipairs(shared) do
        shared[i] = SharedDirectory .. filename
    end

    for i, filename in ipairs(client) do
        client[i] = ClientDirectory .. filename
    end

    for _, filepath in ipairs(table.Add(shared, client)) do
        AddCSLuaFile(filepath)
    end

    include(ServerDirectory .. "autorun.lua")
else
    include(ClientDirectory .. "autorun.lua")
end
