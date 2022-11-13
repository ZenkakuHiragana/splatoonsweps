
$modelname splatoonsweps/weapon_splatoonsweps_splattershotpro/c_viewmodel.mdl
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
$cdmaterials splatoonsweps/weapons/primaries/splattershot_pro
$cdmaterials splatoonsweps/weapons/primaries/shared
$mostlyopaque
$proceduralbones c_arms.vrd
$sequence draw anim/c_lowered_to_idle activity ACT_VM_DRAW 1 fps 3
$sequence fire anim/c_fire activity ACT_VM_PRIMARYATTACK 1 fps 40 snap { event 5000 0 } { event 5001 0 }
$sequence holster anim/c_idle_to_lowered activity ACT_VM_HOLSTER 1 fps 3
$sequence idle anim/c_idle activity ACT_VM_IDLE 1 loop
$sequence idle_to_lowered anim/c_idle_to_lowered activity ACT_VM_IDLE_TO_LOWERED 1 fps 10
$sequence lowered anim/c_lowered activity ACT_VM_IDLE_LOWERED 1 loop
$sequence lowered_to_idle anim/c_lowered_to_idle activity ACT_VM_LOWERED_TO_IDLE 1 fps 10
$sequence sub anim/c_sub activity ACT_VM_PULLPIN 1 loop
$sequence throw anim/c_throw activity ACT_VM_THROW 1 fps 30
$texturegroup skinfamilies {
	{ splattershot_pro_bottle       splattershot_pro       splattershot_pro_rimlight       weapon_hider           }
	{ splattershot_pro_bottle       splattershot_pro_forge weapon_hider                    splattershot_pro_forge }
	{ splattershot_pro_bottle_berry splattershot_pro_berry splattershot_pro_berry_rimlight weapon_hider           }
}
