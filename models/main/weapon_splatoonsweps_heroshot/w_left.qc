
$modelname splatoonsweps/weapon_splatoonsweps_heroshot/w_left.mdl
$body base mesh/w_base.smd
$collisionmodel mesh/w_phys.smd { $automass }
$sequence idle mesh/w_base loop fps 30
$attachment muzzle muzzle 0 0 0
$attachment trail trail 0 0 0
$bonemerge ValveBiped.Bip01_L_Forearm
$cdmaterials splatoonsweps/weapons/primaries/hero_shot
$contents solid
$hierarchy root_1 ValveBiped.Bip01_L_Forearm
$mostlyopaque
$root ValveBiped.Bip01_L_Forearm
$surfaceprop plastic
$texturegroup skinfamilies {
	{ hero_shot_level0 }
	{ hero_shot_level1 }
	{ hero_shot_level2 }
	{ hero_shot_level3 }
}
