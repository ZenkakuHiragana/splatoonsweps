
$modelname "splatoonsweps/subs/squidbeakon/squidbeakon.mdl"
$body base squidbeakon.dmx

$surfaceprop metal
$contents solid
$illumposition 0 -9.682 25.119
$mostlyopaque

$cdmaterials splatoonsweps/weapons/subs/squidbeakon
$sequence idle anims/idle.dmx fps 60
$sequence deploy anims/deploy.dmx fps 60
$sequence wait anims/wait.dmx fps 60
$collisionmodel squidbeakon_physics.dmx { $automass }
$texturegroup skinfamilies
{
	{ squidbeakon_light }
	{ squidbeakon       }
}
