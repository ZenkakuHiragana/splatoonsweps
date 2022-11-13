
$modelname splatoonsweps/weapon_splatoonsweps_eliter3k/w_right.mdl
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
$sequence idle mesh/w_base activity ACT_VM_IDLE 1 fps 30 loop
$sequence fire mesh/w_base activity ACT_HL2MP_RANGE_ATTACK_CROSSBOW 1 fps 5 { event 5000 0 "CHARGER" } { event 5100 0 "CHARGER" } { event 5501 0 "CHARGER" } { event 5503 0 }
$attachment bottle bottle 0 0 0
$attachment muzzle muzzle 0 0 0
$attachment scope_end scope_end 0 0 0
$attachment scope_start scope_start 0 0 0
$bonemerge ValveBiped.Bip01_R_Hand
$cdmaterials splatoonsweps/weapons/primaries/eliter3k
$contents solid
$hierarchy root_1 ValveBiped.Bip01_R_Hand
$mostlyopaque
$root ValveBiped.Bip01_R_Hand
$surfaceprop metal
