
$modelname splatoonsweps/weapon_splatoonsweps_splattershot/w_right.mdl
$body base mesh/w_base.smd
$collisionmodel mesh/w_phys.smd { $automass }
$sequence idle mesh/w_base activity ACT_VM_IDLE 1 fps 30 loop
$sequence fire mesh/w_base activity ACT_HL2MP_RANGE_ATTACK_CROSSBOW 1 fps 5 { event 5000 0 }
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_R_Hand
$cdmaterials splatoonsweps/weapons/primaries/splattershot
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_R_Hand
$mostlyopaque
$root ValveBiped.Bip01_R_Hand
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
