
$modelname splatoonsweps/weapon_splatoonsweps_hydrasplatling/w_left.mdl
$body base mesh/w_base.smd
$bodygroup brand {
	blank
	studio mesh/w_brand.smd
}
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
$cdmaterials splatoonsweps/weapons/primaries/hydrasplatling
$contents solid
$hierarchy root_1 ValveBiped.Bip01_L_Forearm
$mostlyopaque
$root ValveBiped.Bip01_L_Forearm
$surfaceprop metal
