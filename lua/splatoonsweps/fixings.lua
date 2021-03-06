
local ss = SplatoonSWEPs
if not ss then return end

------------------------------------------
--			!!!WORKAROUND!!!			--
--	This should be removed after		--
--	Adv. Colour Tool fixed the bug!!	--
------------------------------------------
local AdvancedColourToolLoaded
= file.Exists("weapons/gmod_tool/stools/adv_colour.lua", "LUA")
local AdvancedColourToolReplacedSetSubMaterial
= AdvancedColourToolLoaded and FindMetaTable "Entity"._OldSetSubMaterial
if AdvancedColourToolReplacedSetSubMaterial then
	function ss.SetSubMaterial_Workaround(ent, ...)
		ent:_OldSetSubMaterial(...)
	end
else
	function ss.SetSubMaterial_Workaround(ent, ...)
		ent:SetSubMaterial(...)
	end
end
------------------------------------------
--			!!!WORKAROUND!!!			--
------------------------------------------


-- Inkling playermodels hull change fix
if isfunction(FindMetaTable "Player".SplatoonOffsets) then
    local cvarflags = {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}
    CreateConVar("splt_Colors", 1, cvarflags, "Toggles skin/eye colors on Splatoon playermodels.")
    if SERVER then
        hook.Remove("KeyPress", "splt_KeyPress")
        hook.Remove("PlayerSpawn", "splt_Spawn")
        hook.Remove("PlayerDeath", "splt_OnDeath")
        hook.Add("PlayerSpawn", "SplatoonSWEPs: Fix PM change", function(ply)
            ss.SetSubMaterial_Workaround(ply)
        end)
    else
        hook.Remove("Tick", "splt_Offsets_cl")
    end

    local width = 16
    local splt_EditScale = GetConVar "splt_EditScale"
    hook.Add("Tick", "SplatoonSWEPs: Fix playermodel hull change", function()
        for _, p in ipairs(player.GetAll()) do
            local is = ss.DrLilRobotPlayermodels[p:GetModel()]
            if not p:Alive() then
                ss.PlayerHullChanged[p] = nil
            elseif is and splt_EditScale:GetInt() ~= 0 and ss.PlayerHullChanged[p] ~= true then
                p:SetViewOffset(Vector(0, 0, 42))
                p:SetViewOffsetDucked(Vector(0, 0, 28))
                p:SetHull(Vector(-width, -width, 0), Vector(width, width, 53))
                p:SetHullDuck(Vector(-width, -width, 0), Vector(width, width, 33))
                ss.PlayerHullChanged[p] = true
            elseif not is and ss.PlayerHullChanged[p] ~= false then
                p:DefaultOffsets()
                ss.PlayerHullChanged[p] = false
            end
        end
    end)
end
