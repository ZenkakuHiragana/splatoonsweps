// Created by Crowbar 0.71

$modelname "props_splatoon\weapons\subs\burst_bombs\burst_bomb.mdl"

$bodygroup "splat_prop"
{
	studio "burst_bomb.smd"
}


$surfaceprop "rubber"

$contents "solid"

$illumposition 0 0 11.28

$mostlyopaque

$cdmaterials ""
$cdmaterials "models\props_splatoon\weapons\subs\burst_bombs\"
$cdmaterials ""

$cbox 0 0 0 0 0 0

$bbox -18.701 -18.989 -19.34 18.701 18.989 42.376

$definebone "root_1" "" 0 0 0 0 0 90.000023 0 0 0 0 0 0
$definebone "bottom_1" "root_1" 0 -9 0 0 0 0 0 0 0 0 0 0
$definebone "middle_1" "root_1" 0 9 0 0 0 0 0 0 0 0 0 0
$definebone "top_1" "root_1" 0 24 0 0 0 0 0 0 0 0 0 0


$sequence "idle" {
	"burst_bomb_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$collisionmodel "burst_bomb_physics.smd"
{
	$mass 752.8729
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 4

}
