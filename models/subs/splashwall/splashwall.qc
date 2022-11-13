$modelname splatoonsweps/subs/splashwall/splashwall.mdl
$model base splashwall.smd {
	flexfile splashwall.vta 
	{
		defaultflex frame 0
		flex "InkAmount" frame 1
	}

	flexcontroller InkAmount range 0 9.7 "InkAmount"
	%InkAmount = InkAmount
}

$surfaceprop plastic
$contents solid
$illumposition 0 0 65.074

$mostlyopaque
$cdmaterials splatoonsweps/weapons/subs/splashwall
$cdmaterials splatoonsweps/weapons/primaries/shared

$texturegroup skinfamilies
{
	{ splashwall     splashwall_rimlight }
	{ splashwall     weapon_hider        }
	{ splashwall_alt weapon_hider        }
}

$sequence ref anims/ref.smd fadein 0.2 fadeout 0.2 fps 30
$sequence folded anims/folded.smd fadein 0.2 fadeout 0.2 fps 30
$sequence unfolding anims/unfolding.smd fadein 0.2 fadeout 0.2 fps 160
$sequence idle anims/idle.smd fadein 0.2 fadeout 0.2 fps 140 loop
$attachment arm_att_1_L arm_att_1_L 0 0 0 rotate 0 0 0
$attachment arm_att_2_L arm_att_2_L 0 0 0 rotate 0 0 0
$attachment arm_att_3_L arm_att_3_L 0 0 0 rotate 0 0 0
$attachment arm_att_4_L arm_att_4_L 0 0 0 rotate 0 0 0
$attachment arm_att_5_L arm_att_5_L 0 0 0 rotate 0 0 0
$attachment arm_att_6_L arm_att_6_L 0 0 0 rotate 0 0 0
$attachment arm_att_7_L arm_att_7_L 0 0 0 rotate 0 0 0
$attachment arm_att_1_R arm_att_1_R 0 0 0 rotate 0 0 0
$attachment arm_att_2_R arm_att_2_R 0 0 0 rotate 0 0 0
$attachment arm_att_3_R arm_att_3_R 0 0 0 rotate 0 0 0
$attachment arm_att_4_R arm_att_4_R 0 0 0 rotate 0 0 0
$attachment arm_att_5_R arm_att_5_R 0 0 0 rotate 0 0 0
$attachment arm_att_6_R arm_att_6_R 0 0 0 rotate 0 0 0
$attachment arm_att_7_R arm_att_7_R 0 0 0 rotate 0 0 0
$collisionmodel splashwall_physics.smd { $automass }
