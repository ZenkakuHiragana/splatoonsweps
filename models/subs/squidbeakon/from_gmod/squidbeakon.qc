
$modelname "splatoonsweps/subs/squidbeakon/squidbeakon.mdl"
$body base squidbeakon.smd

$surfaceprop metal
$contents solid
$illumposition 0 -9.682 25.119
$mostlyopaque

$cdmaterials splatoonsweps/weapons/subs/squidbeakon
$sequence idle anims/idle.smd fps 30
$sequence deploy anims/deploy.smd fps 30
$collisionmodel squidbeakon_physics.smd { $automass }
