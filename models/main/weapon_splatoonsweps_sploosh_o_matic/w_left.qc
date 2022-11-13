
$modelname splatoonsweps/weapon_splatoonsweps_sploosh_o_matic/w_left.mdl
$body base mesh/w_base.smd
$bodygroup bolt {
	studio mesh/w_bolt.smd
	studio mesh/w_bolt7.smd
}
$collisionmodel mesh/w_phys.smd { $automass }
$sequence idle mesh/w_base loop fps 30
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_L_Forearm
$cdmaterials splatoonsweps/weapons/primaries/splash_sploosh_o_matic
$cdmaterials splatoonsweps/weapons/primaries/shared
$contents solid
$hierarchy root_1 ValveBiped.Bip01_L_Forearm
$mostlyopaque
$root ValveBiped.Bip01_L_Forearm
$surfaceprop metal
$texturegroup skinfamilies {
	{
		weapon_hider
		weapon_hider2
		splash_sploosh_o_matic_bronze
		splash_sploosh_o_matic
		splash_sploosh_o_matic_meter
		splash_sploosh_o_matic_handle
		splash_sploosh_o_matic_bronze_2
		splash_sploosh_o_matic_rimlight
		splash_sploosh_o_matic_neo
		splash_sploosh_o_matic_2
	}
	{
		weapon_hider
		weapon_hider2
		splash_sploosh_o_matic_bronze
		splash_sploosh_o_matic
		splash_sploosh_o_matic_meter
		splash_sploosh_o_matic_handle
		splash_sploosh_o_matic_bronze_2
		splash_sploosh_o_matic_rimlight
		weapon_hider
		splash_sploosh_o_matic_2
	}
	{
		splash_sploosh_o_matic_7
		splash_sploosh_o_matic_7_pink
		splash_sploosh_o_matic_7_pink
		splash_sploosh_o_matic_7
		splash_sploosh_o_matic_7_light
		splash_sploosh_o_matic_7
		weapon_hider
		splash_sploosh_o_matic_rimlight
		weapon_hider
		weapon_hider
	}
}
