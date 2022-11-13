
$modelname splatoonsweps/weapon_splatoonsweps_heavysplatling/w_left.mdl
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
$sequence idle mesh/w_base loop fps 30
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_L_Forearm
$cdmaterials splatoonsweps/weapons/primaries/heavysplatling
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_L_Forearm
$mostlyopaque
$root ValveBiped.Bip01_L_Forearm
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
