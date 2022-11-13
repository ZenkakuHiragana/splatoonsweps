
$modelname splatoonsweps/weapon_splatoonsweps_minisplatling/w_right.mdl
$body base mesh/w_base.smd
$collisionjoints mesh/w_phys.smd {
	$automass
	$rootbone root_1
	$jointmassbias root_1 10
	$jointrotdamping rotate_1 0
	$jointconstrain rotate_1 x limit 0 0 0
	$jointconstrain rotate_1 y limit 0 0 0
	$jointconstrain rotate_1 z limit -180 180 0
}
$sequence idle mesh/w_base activity ACT_VM_IDLE 1 fps 30 loop
$sequence fire mesh/w_base activity ACT_HL2MP_RANGE_ATTACK_CROSSBOW 1 fps 5 { event 5000 0 }
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_R_Hand
$cdmaterials splatoonsweps/weapons/primaries/minisplatling
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_R_Hand
$mostlyopaque
$root ValveBiped.Bip01_R_Hand
$surfaceprop plastic
$texturegroup skinfamilies
{
	{ weapon_hider       weapon_hider2             minisplatling             minisplatling_rimlight             }
	{ minisplatling_zink weapon_hider2             minisplatling             minisplatling_rimlight             }
	{ weapon_hider       minisplatling_refurbished minisplatling_refurbished minisplatling_refurbished_rimlight }
}
