
$modelname splatoonsweps/weapon_splatoonsweps_bamboozler14_mk1/w_right.mdl
$body base mesh/w_base.smd
$bodygroup brand {
	blank
	studio mesh/w_brand.smd
}
$collisionmodel mesh/w_phys.smd { $automass }
$sequence idle mesh/w_base activity ACT_VM_IDLE 1 fps 30 loop
$sequence fire mesh/w_base activity ACT_HL2MP_RANGE_ATTACK_CROSSBOW 1 fps 5 { event 5000 0 "CHARGER" } { event 5100 0 "CHARGER" } { event 5501 0 "CHARGER" } { event 5503 0 }
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_R_Hand
$cdmaterials splatoonsweps/weapons/primaries/bamboozler
$contents solid
$hierarchy root_1 ValveBiped.Bip01_R_Hand
$mostlyopaque
$root ValveBiped.Bip01_R_Hand
$surfaceprop wood
$texturegroup skinfamilies {
	{ bamboozler       bamboozler       bamboozler_metal }
	{ bamboozler_dried bamboozler_dried bamboozler_gold  }
}
$jigglebone cap5 {
	is_flexible {
		length 100
		tip_mass 100
		pitch_stiffness 100
		pitch_damping 3
		pitch_constraint -10 30
		yaw_constraint 0 0
	}
}
$jigglebone cap4 {
	is_flexible {
		length 100
		tip_mass 100
		pitch_stiffness 100
		pitch_damping 3
		pitch_constraint -10 0
		yaw_constraint 0 0
	}
}
$jigglebone cap3 {
	is_flexible {
		length 100
		tip_mass 100
		pitch_stiffness 100
		pitch_damping 3
		pitch_constraint -20 0
		yaw_constraint 0 0
	}
}
$jigglebone cap2 {
	is_flexible {
		length 100
		tip_mass 100
		pitch_stiffness 100
		pitch_damping 3
		pitch_constraint -10 0
		yaw_constraint 0 0
	}
}
$jigglebone cap1 {
	is_flexible {
		length 100
		tip_mass 100
		pitch_stiffness 100
		pitch_damping 3
		pitch_constraint -20 80
		yaw_constraint 0 0
	}
}
