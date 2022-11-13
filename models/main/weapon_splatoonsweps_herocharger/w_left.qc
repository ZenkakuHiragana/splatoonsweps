
$modelname splatoonsweps/weapon_splatoonsweps_herocharger/w_left.mdl
$body base mesh/w_base.smd
$collisionmodel mesh/w_phys.smd { $automass }
$sequence idle mesh/w_base loop fps 30
$attachment bottle bottle 0 0 0
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_L_Forearm
$cdmaterials splatoonsweps/weapons/primaries/hero_charger
$contents solid
$hierarchy root_1 ValveBiped.Bip01_L_Forearm
$mostlyopaque
$root ValveBiped.Bip01_L_Forearm
$surfaceprop metal
$texturegroup skinfamilies {
	{ hero_charger_level0 }
	{ hero_charger_level1 }
	{ hero_charger_level2 }
	{ hero_charger_level3 }
}
