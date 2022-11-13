
$modelname splatoonsweps/weapon_splatoonsweps_squiffer_classic/w_left.mdl
$body base mesh/w_base.smd
$collisionmodel mesh/w_phys.smd { $automass }
$sequence idle mesh/w_base loop fps 30
$attachment bottle bottle 0 0 0
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_L_Forearm
$cdmaterials splatoonsweps/weapons/primaries/squiffer
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_L_Forearm
$mostlyopaque
$root ValveBiped.Bip01_L_Forearm
$surfaceprop plastic
$texturegroup skinfamilies {
	{ squiffer_bottle       squiffer       weapon_hider          squiffer_rimlight       squiffer_bottle_rimlight }
	{ squiffer_bottle       squiffer       squiffer_bottle       squiffer_rimlight       squiffer_bottle_rimlight }
	{ squiffer_fresh_bottle squiffer_fresh squiffer_fresh_bottle squiffer_fresh_rimlight squiffer_bottle_rimlight }
}
