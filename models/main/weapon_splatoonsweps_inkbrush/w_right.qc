
$modelname splatoonsweps/weapon_splatoonsweps_inkbrush/w_right.mdl
$body base mesh/w_base.smd
$collisionjoints mesh/w_phys.smd {
	$automass
	$rootbone root_1
	$jointmassbias root_1 10
	$jointrotdamping root_1 10
	$jointconstrain brush1_1 x limit -110 110 0
	$jointconstrain brush1_1 y limit -60 60 0
	$jointconstrain brush1_1 z limit 0 0 0
	$jointconstrain brush2_1 x limit 0 0 0
	$jointconstrain brush2_1 y limit -65 65 0
	$jointconstrain brush2_1 z limit -50 50 0
	$jointconstrain brush3_1 x limit 0 0 0
	$jointconstrain brush3_1 y limit -75 75 0
	$jointconstrain brush3_1 z limit -50 50 0
}
$sequence idle mesh/w_base activity ACT_VM_IDLE 1 fps 30 loop
$sequence fire mesh/w_base fps 10 {event 5005 0 }
$sequence fire2 mesh/w_base fps 10 { event 5006 0 }
$attachment tip brush1_1 0 0 0
$bonemerge ValveBiped.Bip01_R_Hand
$cdmaterials splatoonsweps/weapons/primaries/inkbrush
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_R_Hand
$mostlyopaque
$root ValveBiped.Bip01_R_Hand
$surfaceprop metal
$texturegroup skinfamilies
{
	{ weapon_hider       inkbrush_base      }
	{ inkbrush_base      inkbrush_base      }
	{ inkbrush_permanent inkbrush_permanent }
}
$jigglebone brush1_1 {
	is_flexible {
		length 30
		tip_mass 10
		pitch_stiffness 50
		pitch_damping 100
		pitch_constraint -60 60
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
		pitch_constraint -60 60
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
		pitch_constraint -60 60
		yaw_stiffness 50
		yaw_damping 100
		yaw_constraint -20 20
	}
}
