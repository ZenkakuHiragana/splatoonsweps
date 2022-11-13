
$modelname splatoonsweps/weapon_splatoonsweps_splattershot/w_left.mdl
$body base mesh/w_base.smd
$collisionmodel mesh/w_phys.smd { $automass }
$sequence idle mesh/w_base loop fps 30
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_L_Forearm
$cdmaterials splatoonsweps/weapons/primaries/splattershot
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_L_Forearm
$mostlyopaque
$root ValveBiped.Bip01_L_Forearm
$surfaceprop plastic
$texturegroup skinfamilies {
	{
		weapon_hider2
		weapon_hider
		splattershot_bottle
		splattershot
		splattershot_rimlight
	}
	{
		splattershot_tentatek
		weapon_hider
		splattershot_bottle
		splattershot
		splattershot_rimlight
	}
	{
		weapon_hider
		splattershot_wasabi_emblem
		splattershot_bottle_wasabi
		splattershot_wasabi
		splattershot_wasabi_rimlight
	}
}
