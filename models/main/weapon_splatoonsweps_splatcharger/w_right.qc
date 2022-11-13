
$modelname splatoonsweps/weapon_splatoonsweps_splatcharger/w_right.mdl
$body base mesh/w_base.smd
$bodygroup body {
	studio mesh/w_bottle.smd
	studio mesh/w_brand.smd
	studio mesh/w_bento.smd
	studio mesh/w_scope.smd
	studio mesh/w_brandscope.smd
	studio mesh/w_bentoscope.smd
}
$collisionmodel mesh/w_phys.smd { $automass }
$sequence idle mesh/w_base activity ACT_VM_IDLE 1 fps 30 loop
$sequence fire mesh/w_base activity ACT_HL2MP_RANGE_ATTACK_CROSSBOW 1 fps 5 { event 5000 0 "CHARGER" } { event 5100 0 "CHARGER" } { event 5501 0 "CHARGER" } { event 5503 0 }
$attachment bottle bottle 0 0 0
$attachment bottle_bento bottle_bento 0 0 0
$attachment muzzle muzzle 0 0 0
$attachment scope_end scope_end 0 0 0
$attachment scope_start scope_start 0 0 0
$bonemerge ValveBiped.Bip01_R_Hand
$cdmaterials splatoonsweps/weapons/primaries/splatcharger
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_R_Hand
$mostlyopaque
$root ValveBiped.Bip01_R_Hand
$surfaceprop plastic
$texturegroup skinfamilies {
	{ splat_charger       splat_charger_rimlight       }
	{ splat_charger_bento splat_charger_bento_rimlight }
}
