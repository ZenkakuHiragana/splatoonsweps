
$modelname splatoonsweps/weapon_splatoonsweps_heroroller/w_right.mdl
$body base mesh/w_base.smd
$bodygroup ink {
	studio mesh/w_ink.smd
	studio mesh/w_empty.smd
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
$illumposition 0 8.432 0
$sequence idle mesh/w_base activity ACT_VM_IDLE 1 fps 30 loop
$sequence fire mesh/w_base fps 5
$sequence fire2 mesh/w_base fps 6 { event 5004 0 }
$attachment roll roll_1 0 0 0
$bonemerge ValveBiped.Bip01_R_Hand
$cdmaterials splatoonsweps/weapons/primaries/hero_roller
$contents solid
$hierarchy root_1 ValveBiped.Bip01_R_Hand
$mostlyopaque
$root ValveBiped.Bip01_R_Hand
$surfaceprop plastic
$texturegroup skinfamilies
{
	{ hero_roller_level0 }
	{ hero_roller_level1 }
	{ hero_roller_level2 }
	{ hero_roller_level3 }
}
