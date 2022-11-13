
$modelname splatoonsweps/weapon_splatoonsweps_96gal/w_left.mdl
$body base mesh/w_base.smd
$body muzzle mesh/w_muzzle.smd
$collisionmodel mesh/w_phys.smd { $automass }
$sequence idle mesh/w_base loop fps 30
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_L_Forearm
$cdmaterials splatoonsweps/weapons/primaries/52_96_gal
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_L_Forearm
$mostlyopaque
$root ValveBiped.Bip01_L_Forearm
$surfaceprop plastic
$texturegroup skinfamilies {
	{ 52_96_gal     weapon_hider weapon_hider2    52_96_gal_rimlight }
	{ 52_96_gal     shared_deco  shared_deco_pink 52_96_gal_rimlight }
}
