
$modelname splatoonsweps/weapon_splatoonsweps_nzap85/w_right.mdl
$body base mesh/w_base.smd
$collisionmodel mesh/w_phys.smd { $automass }
$sequence idle mesh/w_base activity ACT_VM_IDLE 1 fps 30 loop
$sequence fire mesh/w_base activity ACT_HL2MP_RANGE_ATTACK_CROSSBOW 1 fps 5 { event 5000 0 } { event 5002 0 }
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_R_Hand
$cdmaterials splatoonsweps/weapons/primaries/n_zap
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_R_Hand
$mostlyopaque
$root ValveBiped.Bip01_R_Hand
$surfaceprop plastic
$texturegroup skinfamilies {
	{ n_zap_85 n_zap_85_rimlight weapon_hider weapon_hider2 }
	{ n_zap_89 n_zap_89_rimlight weapon_hider weapon_hider2 }
	{ n_zap_83 n_zap_83_rimlight n_zap_83_G   n_zap_83_B    }
}
