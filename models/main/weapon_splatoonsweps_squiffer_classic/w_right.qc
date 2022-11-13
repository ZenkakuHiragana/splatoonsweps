
$modelname splatoonsweps/weapon_splatoonsweps_squiffer_classic/w_right.mdl
$body base mesh/w_base.smd
$collisionmodel mesh/w_phys.smd { $automass }
$sequence idle mesh/w_base activity ACT_VM_IDLE 1 fps 30 loop
$sequence fire mesh/w_base activity ACT_HL2MP_RANGE_ATTACK_CROSSBOW 1 fps 5 { event 5000 0 "CHARGER" } { event 5100 0 "CHARGER" } { event 5501 0 "CHARGER" } { event 5503 0 }
$attachment bottle bottle 0 0 0
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_R_Hand
$cdmaterials splatoonsweps/weapons/primaries/squiffer
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_R_Hand
$mostlyopaque
$root ValveBiped.Bip01_R_Hand
$surfaceprop plastic
$texturegroup skinfamilies {
	{ squiffer_bottle       squiffer       weapon_hider          squiffer_rimlight       squiffer_bottle_rimlight }
	{ squiffer_bottle       squiffer       squiffer_bottle       squiffer_rimlight       squiffer_bottle_rimlight }
	{ squiffer_fresh_bottle squiffer_fresh squiffer_fresh_bottle squiffer_fresh_rimlight squiffer_bottle_rimlight }
}
