
$modelname splatoonsweps/weapon_splatoonsweps_splatroller_corocoro/w_right.mdl
$body base mesh/w_corocoro.smd
$bodygroup ink {
	studio mesh/w_ink_corocoro.smd
	blank
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
$sequence idle mesh/w_corocoro activity ACT_VM_IDLE 1 fps 30 loop
$sequence fire mesh/w_corocoro fps 5
$sequence fire2 mesh/w_corocoro fps 6 { event 5004 0 }
$attachment roll roll_root_1 0 0 0
$bonemerge ValveBiped.Bip01_R_Hand
$cdmaterials splatoonsweps/weapons/primaries/splat_roller
$contents solid
$hierarchy root_1 ValveBiped.Bip01_R_Hand
$mostlyopaque
$root ValveBiped.Bip01_R_Hand
$surfaceprop plastic
