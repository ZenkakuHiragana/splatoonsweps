
$modelname splatoonsweps/weapon_splatoonsweps_sloshingmachine/w_left.mdl
$body base mesh/w_base.smd
$bodygroup brand {
	blank
	studio mesh/w_brand.smd
}
$collisionmodel mesh/w_phys.smd {
	$automass
	$concave
	$maxconvexpieces 14
}
$illumposition 0 -2.01 4.399
$sequence idle mesh/w_base loop fps 30
$attachment spout spout 0 0 0
$bonemerge ValveBiped.Bip01_L_Hand
$cdmaterials splatoonsweps/weapons/primaries/sloshing_machine
$contents solid
$hierarchy Wmn_BigBall_Launcher_1 ValveBiped.Bip01_L_Hand
$mostlyopaque
$root ValveBiped.Bip01_L_Hand
$surfaceprop metal
