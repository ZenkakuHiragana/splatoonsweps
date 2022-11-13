
$modelname splatoonsweps/weapon_splatoonsweps_52gal/w_right.mdl
$body base mesh/w_base.smd
$body muzzle mesh/w_muzzle.smd
$collisionmodel mesh/w_phys.smd { $automass }
$sequence idle mesh/w_base activity ACT_VM_IDLE 1 fps 30 frame 0 1 loop
$sequence fire mesh/w_base activity ACT_HL2MP_RANGE_ATTACK_CROSSBOW 1 fps 5 { event 5000 0 } { event 5001 0 }
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_R_Hand
$cdmaterials splatoonsweps/weapons/primaries/52_96_gal
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_R_Hand
$mostlyopaque
$root ValveBiped.Bip01_R_Hand
$surfaceprop plastic
$texturegroup skinfamilies {
	{ 52_96_gal     weapon_hider weapon_hider2    52_96_gal_rimlight }
	{ 52_96_gal     shared_deco  shared_deco_pink 52_96_gal_rimlight }
}
