
$modelname splatoonsweps/weapon_splatoonsweps_heavysplatling/w_right.mdl
$body base mesh/w_base.smd
$body bottle mesh/w_bottle.smd
$collisionjoints mesh/w_phys.smd {
	$automass
	$rootbone root_1
	$jointmassbias root_1 10
	$jointrotdamping rotate_1 0
	$jointconstrain rotate_1 x limit 0 0 0
	$jointconstrain rotate_1 y limit 0 0 0
	$jointconstrain rotate_1 z limit -180 180 0
}
$sequence idle mesh/w_base activity ACT_VM_IDLE 1 fps 30 loop
$sequence fire mesh/w_base activity ACT_HL2MP_RANGE_ATTACK_CROSSBOW 1 fps 5 { event 5000 0 }
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_R_Hand
$cdmaterials splatoonsweps/weapons/primaries/heavysplatling
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_R_Hand
$mostlyopaque
$root ValveBiped.Bip01_R_Hand
$surfaceprop plastic
$texturegroup skinfamilies
{
	{
		weapon_hider4
		weapon_hider
		weapon_hider2
		weapon_hider3
		heavysplatling
		heavysplatling_2
		heavysplatling_trim_2
		heavysplatling_bottle_2
		heavysplatling_bottle
		heavysplatling_bottle_alt_2
		heavysplatling_bottle_trim_2
	}
	{
		weapon_hider4
		shared_deco
		shared_deco_pink
		weapon_hider3
		heavysplatling
		heavysplatling_2
		heavysplatling_trim_2
		heavysplatling_bottle_2
		heavysplatling_bottle
		heavysplatling_bottle_alt_2
		heavysplatling_bottle_trim_2
	}
	{
		heavysplatling_bottle_remix_decal
		weapon_hider
		weapon_hider2
		heavysplatling_remix
		heavysplatling_remix
		weapon_hider
		weapon_hider
		weapon_hider
		heavysplatling_bottle_remix
		weapon_hider
		weapon_hider
	}
}
