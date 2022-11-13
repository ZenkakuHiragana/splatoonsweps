
$modelname splatoonsweps/weapon_splatoonsweps_eliter3k/w_left.mdl
$body base mesh/w_base.smd
$bodygroup brand {
	blank
	studio mesh/w_brand.smd
}
$bodygroup scope {
	blank
	studio mesh/w_scope.smd
}
$collisionmodel mesh/w_phys.smd { $automass }
$sequence idle mesh/w_base loop fps 30
$attachment bottle bottle 0 0 0
$attachment muzzle muzzle 0 0 0
$attachment scope_end scope_end 0 0 0
$attachment scope_start scope_start 0 0 0
$bonemerge ValveBiped.Bip01_L_Forearm
$cdmaterials splatoonsweps/weapons/primaries/eliter3k
$contents solid
$hierarchy root_1 ValveBiped.Bip01_L_Forearm
$mostlyopaque
$root ValveBiped.Bip01_L_Forearm
$surfaceprop metal
