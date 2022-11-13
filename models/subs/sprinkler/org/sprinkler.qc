// Created by Crowbar 0.71

$modelname "props_splatoon\weapons\subs\sprinkler\sprinkler.mdl"

$bodygroup "splat_prop"
{
	studio "sprinkler.smd"
}


$surfaceprop "metal"

$contents "solid"

$illumposition 0 0 15.661

$mostlyopaque

$cdmaterials ""
$cdmaterials "models\props_splatoon\weapons\subs\sprinkler\"
$cdmaterials ""
$cdmaterials ""

$cbox 0 0 0 0 0 0

$bbox -12.244 -23.25 0 12.244 23.25 31.323

$definebone "root_1" "" 0 0 0 0 0 90.000009 0 0 0 0 0 0
$definebone "roll_1" "root_1" 0 14.235663 0.000001 0 0 0 0 0 0 0 0 0
$definebone "hammer_1" "roll_1" 0 9.764337 -0.000001 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"sprinkler_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$collisionjoints "sprinkler_physics.smd"
{
	$mass 9.7
	$inertia 1
	$damping 0
	$rotdamping 10
	$rootbone "root_1"

	$jointmassbias "root_1" 10

	$jointrotdamping "roll_1" 0
	$jointconstrain "roll_1" x limit 0 0 0
	$jointconstrain "roll_1" y limit -180 180 0
	$jointconstrain "roll_1" z limit 0 0 0
}
