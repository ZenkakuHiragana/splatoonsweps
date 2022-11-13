
$modelname splatoonsweps/weapon_splatoonsweps_slosher/w_left.mdl
$body base mesh/w_base.smd
$bodygroup ink {
	studio mesh/w_ink.smd
	blank
}
$collisionmodel mesh/w_phys.smd {
	$automass
	$concave
	$maxconvexpieces 18
}
$illumposition 0 -1.347 0
$sequence idle mesh/w_base loop fps 30
$attachment spout spout 0 0 0
$bonemerge ValveBiped.Bip01_L_Hand
$cdmaterials splatoonsweps/weapons/primaries/slosher
$contents solid
$hierarchy Wmn_BigBall_Strong_1 ValveBiped.Bip01_L_Hand
$mostlyopaque
$root ValveBiped.Bip01_L_Hand
$surfaceprop plastic
$texturegroup skinfamilies {
	{ slosher      }
	{ slosher_deco }
	{ slosher_soda }
}
