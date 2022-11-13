$modelname splatoonsweps/subs/suctionbomb/suctionbomb.mdl
$body base suctionbomb.smd
$surfaceprop metal
$contents solid
$illumposition 24.536 0 0
$mostlyopaque
$cdmaterials splatoonsweps/weapons/subs/suctionbomb
$texturegroup skinfamilies {
	{ suctionbomb_lights        }
	{ suctionbomb_lights_bright }
}

$sequence idle suctionbomb fps 30
$collisionmodel suctionbomb_physics.smd {
	$automass
	$concave
	$maxconvexpieces 3
}
