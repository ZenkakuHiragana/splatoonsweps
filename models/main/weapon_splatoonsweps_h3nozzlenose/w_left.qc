
$modelname splatoonsweps/weapon_splatoonsweps_h3nozzlenose/w_left.mdl
$bodygroup base {
	studio mesh/w_base.smd
	studio mesh/w_brand.smd
	studio mesh/w_cherry.smd
}
$collisionmodel mesh/w_phys.smd { $automass }
$sequence idle mesh/w_base loop fps 30
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_L_Forearm
$cdmaterials splatoonsweps/weapons/primaries/nozzlenose
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_L_Forearm
$mostlyopaque
$root ValveBiped.Bip01_L_Forearm
$surfaceprop metal
