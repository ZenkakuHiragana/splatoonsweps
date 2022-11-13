
$modelname splatoonsweps/weapon_splatoonsweps_dynamoroller/w_right.mdl
$body base mesh/w_base.smd
$bodygroup ink {
	studio mesh/w_ink.smd
	blank
}
$collisionjoints mesh/w_phys.smd {
	$automass
	$rootbone root_1
	$jointmassbias root_1 10
	$jointrotdamping rotate_1 10
	$jointconstrain neck_1 x limit -90 0 0
	$jointconstrain neck_1 y limit 0 0 0
	$jointconstrain neck_1 z limit 0 0 0
	$jointconstrain roll_1 x limit 0 0 0
	$jointconstrain roll_1 y limit -180 180 0
	$jointconstrain roll_1 z limit 0 0 0
}
$illumposition 4.055 0.005 20.584
$sequence idle mesh/w_base activity ACT_VM_IDLE 1 fps 30 loop
$sequence fire mesh/w_base fps 5
$sequence fire2 mesh/w_base fps 6 { event 5004 0 }
$attachment roll roll_root_1 0 0 0
$bonemerge ValveBiped.Bip01_R_Hand
$cdmaterials splatoonsweps/weapons/primaries/dynamo_roller
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_R_Hand
$mostlyopaque
$root ValveBiped.Bip01_R_Hand
$surfaceprop metal
$texturegroup skinfamilies
{
	{ weapon_hider             dynamo_roller          dynamo_roller_bronze   weapon_hider2            weapon_hider3            }
	{ weapon_hider             dynamo_roller_gold     dynamo_roller_gold     weapon_hider2            weapon_hider3            }
	{ dynamo_roller_tempered_1 dynamo_roller_tempered dynamo_roller_tempered dynamo_roller_tempered_2 dynamo_roller_tempered_3 }
}
