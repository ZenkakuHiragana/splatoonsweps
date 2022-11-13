
$modelname splatoonsweps/weapon_splatoonsweps_trislosher/w_right.mdl
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
	$rootbone Wmn_BigBall_Diffusion_1
	$jointconstrain handle_moveable x limit 0 0 0
	$jointconstrain handle_moveable y limit 0 0 0
	$jointconstrain handle_moveable z limit -55 180 0
}
$illumposition 0 -1.052 0
$sequence idle mesh/w_base activity ACT_VM_IDLE 1 fps 30 loop
$sequence fire mesh/w_base fps 5
$sequence fire2 mesh/w_base fps 6 { event 5007 0 }
$attachment spout handle_moveable 0 0 0
$bonemerge ValveBiped.Bip01_R_Hand
$cdmaterials splatoonsweps/weapons/primaries/tri_slosher
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy Wmn_BigBall_Diffusion_1 ValveBiped.Bip01_R_Hand
$mostlyopaque
$root ValveBiped.Bip01_R_Hand
$surfaceprop plastic
