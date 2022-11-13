
$modelname splatoonsweps/weapon_splatoonsweps_splatroller/w_left.mdl
$body base mesh/w_base.smd
$bodygroup ink {
	studio mesh/w_ink.smd
	blank
}
$bodygroup brand {
	blank
	studio mesh/w_brand.smd
}
$collisionjoints mesh/w_phys.smd {
	$automass
	$rootbone root_1
	$jointmassbias root_1 10
	$jointrotdamping rotate_1 10
	$jointconstrain neck_1 x limit -90 0 0
	$jointconstrain neck_1 y limit 0 0 0
	$jointconstrain neck_1 z limit 0 0 0
	$jointconstrain roll_1 x limit 0 0 0
	$jointconstrain roll_1 y limit -180 180 0
	$jointconstrain roll_1 z limit 0 0 0
}
$illumposition 4.251 -4.844 21.632
$sequence idle mesh/w_base loop fps 30
$attachment roll roll_root_1 0 0 0
$bonemerge ValveBiped.Bip01_L_Hand
$cdmaterials splatoonsweps/weapons/primaries/splat_roller
$contents solid
$hierarchy root_1 ValveBiped.Bip01_L_Hand
$mostlyopaque
$root ValveBiped.Bip01_L_Hand
$surfaceprop plastic
