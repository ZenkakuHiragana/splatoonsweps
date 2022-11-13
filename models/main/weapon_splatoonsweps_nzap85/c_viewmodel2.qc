
$modelname splatoonsweps/weapon_splatoonsweps_nzap85/c_viewmodel2.mdl
$body base mesh/c_base.smd
$attachment muzzle muzzle 0 0 0
$bonemerge ValveBiped.Bip01_Spine4
$bonemerge ValveBiped.Bip01_L_Clavicle
$bonemerge ValveBiped.Bip01_L_UpperArm
$bonemerge ValveBiped.Bip01_L_Forearm
$bonemerge ValveBiped.Bip01_L_Hand
$bonemerge ValveBiped.Bip01_L_Finger4
$bonemerge ValveBiped.Bip01_L_Finger41
$bonemerge ValveBiped.Bip01_L_Finger42
$bonemerge ValveBiped.Bip01_L_Finger3
$bonemerge ValveBiped.Bip01_L_Finger31
$bonemerge ValveBiped.Bip01_L_Finger32
$bonemerge ValveBiped.Bip01_L_Finger2
$bonemerge ValveBiped.Bip01_L_Finger21
$bonemerge ValveBiped.Bip01_L_Finger22
$bonemerge ValveBiped.Bip01_L_Finger1
$bonemerge ValveBiped.Bip01_L_Finger11
$bonemerge ValveBiped.Bip01_L_Finger12
$bonemerge ValveBiped.Bip01_L_Finger0
$bonemerge ValveBiped.Bip01_L_Finger01
$bonemerge ValveBiped.Bip01_L_Finger02
$bonemerge ValveBiped.Bip01_R_Clavicle
$bonemerge ValveBiped.Bip01_R_UpperArm
$bonemerge ValveBiped.Bip01_R_Forearm
$bonemerge ValveBiped.Bip01_R_Hand
$bonemerge ValveBiped.Bip01_R_Finger4
$bonemerge ValveBiped.Bip01_R_Finger41
$bonemerge ValveBiped.Bip01_R_Finger42
$bonemerge ValveBiped.Bip01_R_Finger3
$bonemerge ValveBiped.Bip01_R_Finger31
$bonemerge ValveBiped.Bip01_R_Finger32
$bonemerge ValveBiped.Bip01_R_Finger2
$bonemerge ValveBiped.Bip01_R_Finger21
$bonemerge ValveBiped.Bip01_R_Finger22
$bonemerge ValveBiped.Bip01_R_Finger1
$bonemerge ValveBiped.Bip01_R_Finger11
$bonemerge ValveBiped.Bip01_R_Finger12
$bonemerge ValveBiped.Bip01_R_Finger0
$bonemerge ValveBiped.Bip01_R_Finger01
$bonemerge ValveBiped.Bip01_R_Finger02
$contents solid
$cdmaterials splatoonsweps/weapons/primaries/n_zap
$cdmaterials splatoonsweps/weapons/primaries/shared
$mostlyopaque
$origin 1 0 0
$proceduralbones c_arms.vrd
$sequence draw anim_pistol/c_deploy activity ACT_VM_DRAW 1 fps 30
$sequence fire anim_pistol/c_fire activity ACT_VM_PRIMARYATTACK 1 fps 40 snap { event 5000 0 } { event 5002 0 }
$sequence holster anim_pistol/c_idle_to_lowered activity ACT_VM_HOLSTER 1 fps 3
$sequence idle anim_pistol/c_idle activity ACT_VM_IDLE 1 loop
$sequence idle_to_lowered anim_pistol/c_idle_to_lowered activity ACT_VM_IDLE_TO_LOWERED 1 fps 10
$sequence lowered anim_pistol/c_lowered activity ACT_VM_IDLE_LOWERED 1 loop
$sequence lowered_to_idle anim_pistol/c_lowered_to_idle activity ACT_VM_LOWERED_TO_IDLE 1 fps 10
$sequence sub anim_pistol/c_sub activity ACT_VM_PULLPIN 1 loop
$sequence throw anim_pistol/c_throw activity ACT_VM_THROW 1 fps 30
$texturegroup skinfamilies {
	{ n_zap_85 n_zap_85_rimlight weapon_hider weapon_hider2 }
	{ n_zap_89 n_zap_89_rimlight weapon_hider weapon_hider2 }
	{ n_zap_83 n_zap_83_rimlight n_zap_83_G   n_zap_83_B    }
}
