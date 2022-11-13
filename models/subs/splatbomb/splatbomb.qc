$modelname splatoonsweps/subs/splatbomb/splatbomb.mdl
$model base splatbomb_octarian.smd {
	flexfile splatbomb_01.vta
	{
		defaultflex frame 0
		flex "Expand" frame 1
	}

	flexcontroller Expand range 0 1 "Expand"
	%Expand = Expand
}

$surfaceprop plastic
$contents solid
$illumposition 0 5.236 4.727
$mostlyopaque
$cdmaterials splatoonsweps/weapons/subs/splatbomb
$texturegroup skinfamilies
{
	{ splatbomb_trim  splatbomb_body          splatbomb_ink          splatbomb_hider        }
	{ splatbomb_trim  splatbomb_body          splatbomb_ink          splatbomb_plastic_glow }
	{ splatbomb_hider splatbomb_body          splatbomb_ink          splatbomb_hider        }
	{ splatbomb_hider splatbomb_body          splatbomb_ink          splatbomb_plastic_glow }
	{ splatbomb_hider splatbomb_body2         splatbomb_ink          splatbomb_hider        }
	{ splatbomb_hider splatbomb_body2         splatbomb_ink          splatbomb_plastic_glow }
	{ splatbomb_hider splatbomb_octarian_body splatbomb_octarian_ink splatbomb_hider        }
	{ splatbomb_hider splatbomb_octarian_body splatbomb_octarian_ink splatbomb_plastic_glow }
}

$sequence idle idle fps 30
$collisionmodel splatbomb_smooth_physics.smd { $automass }
