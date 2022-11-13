
$modelname splatoonsweps/weapon_splatoonsweps_nzap85/w_left.mdl
$body base mesh/w_base.smd
$collisionmodel mesh/w_phys.smd { $automass }
$sequence idle mesh/w_base loop fps 30
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_L_Forearm
$cdmaterials splatoonsweps/weapons/primaries/n_zap
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_L_Forearm
$mostlyopaque
$root ValveBiped.Bip01_L_Forearm
$surfaceprop plastic
$texturegroup skinfamilies {
	{ n_zap_85 n_zap_85_rimlight weapon_hider weapon_hider2 }
	{ n_zap_89 n_zap_89_rimlight weapon_hider weapon_hider2 }
	{ n_zap_83 n_zap_83_rimlight n_zap_83_G   n_zap_83_B    }
}
