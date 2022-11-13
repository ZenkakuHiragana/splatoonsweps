
$modelname splatoonsweps/weapon_splatoonsweps_octobrush/w_left.mdl
$body base mesh/w_base.smd
$bodygroup brand {
	blank
	studio mesh/w_brand.smd
}
$collisionjoints mesh/w_phys.smd {
	$automass
	$rootbone root_1
	$jointmassbias root_1 10
	$jointrotdamping root_1 10
	$jointconstrain brush1_1 x limit -15 15 0
	$jointconstrain brush1_1 y limit -15 15 0
	$jointconstrain brush1_1 z limit 0 0 0
	$jointconstrain brush2_1 x limit -15 15 0
	$jointconstrain brush2_1 y limit -35 35 0
	$jointconstrain brush2_1 z limit 0 0 0
	$jointconstrain brush3_1 x limit -15 15 0
	$jointconstrain brush3_1 y limit -70 70 0
	$jointconstrain brush3_1 z limit 0 0 0
}
$illumposition 0 -2.004 -1.762
$sequence idle mesh/w_base loop fps 30
$attachment tip brush1_1 0 0 0
$bonemerge ValveBiped.Bip01_L_Hand
$cdmaterials splatoonsweps/weapons/primaries/octobrush
$contents solid
$hierarchy root_1 ValveBiped.Bip01_L_Hand
$mostlyopaque
$root ValveBiped.Bip01_L_Hand
$surfaceprop wood
$jigglebone brush1_1 {
	is_flexible {
		length 30
		tip_mass 10
		pitch_stiffness 50
		pitch_damping 100
		pitch_constraint -20 20
		yaw_stiffness 50
		yaw_damping 100
		yaw_constraint -20 20
	}
}
$jigglebone brush2_1 {
	is_flexible {
		length 30
		tip_mass 10
		pitch_stiffness 50
		pitch_damping 100
		pitch_constraint -20 20
		yaw_stiffness 50
		yaw_damping 100
		yaw_constraint -20 20
	}
}
$jigglebone brush3_1 {
	is_flexible {
		length 30
		tip_mass 10
		pitch_stiffness 50
		pitch_damping 100
		pitch_constraint -20 20
		yaw_stiffness 50
		yaw_damping 100
		yaw_constraint -20 20
	}
}
