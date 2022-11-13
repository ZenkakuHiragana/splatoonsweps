
$modelname splatoonsweps/weapon_splatoonsweps_aerospray_mg/w_right.mdl
$body base mesh/w_base.smd
$collisionmodel mesh/w_phys.smd { $automass }
$sequence idle mesh/w_base activity ACT_VM_IDLE 1 fps 30 loop
$sequence fire mesh/w_base activity ACT_HL2MP_RANGE_ATTACK_CROSSBOW 1 fps 5 { event 5000 0 }
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_R_Hand
$cdmaterials splatoonsweps/weapons/primaries/aerospray
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_R_Hand
$mostlyopaque
$root ValveBiped.Bip01_R_Hand
$surfaceprop metal
$texturegroup skinfamilies {
	{ weapon_hider   weapon_hider2  aerospray_mg   }
	{ weapon_hider   weapon_hider2  aerospray_rg   }
	{ aerospray_pg_1 aerospray_pg_2 aerospray_pg_3 }
}
$jigglebone cable {
	is_flexible {
		length 100
		tip_mass 10
		pitch_stiffness 20
		pitch_damping 100
		pitch_constraint -60 60
		yaw_constraint -20 20
	}
}
