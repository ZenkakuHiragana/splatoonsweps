AddCSLuaFile()
return {CVars = {
    AllowSprint = "Allow players to run. (1: enabled, 0: disabled)",
    AvoidWalls = "Prevent SWEPs from shooting at wall wastfully. (1: enabled, 0: disabled)",
    BecomeSquid = "Become squid on crouching. (1: enabled, 0: disabled)",
    CanDrown = "Whether or not inklings can drown. (1: enabled, 0: disabled)",
    CanHealInk = "Heal yourself when you are in ink. (1: enabled, 0: disabled)",
    CanHealStand = "Heal yourself when you are out of ink. (1: enabled, 0: disabled)",
    CanReloadInk = "Reload your ink when you are in ink. (1: enabled, 0: disabled)",
    CanReloadStand = "Reload your ink when you are out of ink. (1: enabled, 0: disabled)",
    Clear = "Clear all ink in the map.",
    DoomStyle = "Bring the weapon viewmodel to the center of the screen. (1: enabled, 0: disabled)",
    DrawCrosshair = "Draw Splatoon-like crosshair. (1: enabled, 0: disabled)",
    DrawInkOverlay = "Draw ink overlay in firstperson. (1: enabled, 0: disabled)",
    Enabled = "Enable or disable Splatoon SWEPs. (1: enabled, 0: disabled)",
    ExplodeOnlySquids = "Victims splatter by the SWEPs will explode only if they also have the SWEPs. (1: enabled, 0: disabled)",
    FF = "Enable friendly fire. (1: enabled, 0: disabled)",
    Gain = {
        HealSpeedInk = "A multiplier of healing speed when you're in ink.  200 means 200%, twice faster healing speed.",
        HealSpeedStand = "A multiplier of healing speed when you're out of ink.  200 means 200%, twice faster healing speed.",
        MaxHealth = "Maximum health of inklings.",
        InkAmount = "The amount ink tank can hold up to.",
        ReloadSpeedInk = "A multiplier of reloading speed when you're in ink.  200 means 200%, twice faster reloading speed.",
        ReloadSpeedStand = "A multiplier of reloading speed when you're out of ink.  200 means 200%, twice faster reloading speed.",
    },
    HideInk = "Hide painted ink in the map. (1: enabled, 0: disabled)",
    HurtOwner = "If enabled, inklings will be injured by his/her explosion. (1: enabled, 0: disabled)",
    InkColor = "Your ink color.  Available values are as follows:\n",
    LeftHand = "Use left hand to hold weapons. (1: enabled, 0: disabled)",
    MoveViewmodel = "Move viewmodel when avoid setting is enabled. (1: enabled, 0: disabled)",
    NewStyleCrosshair = "Make crosshair act like Splatoon 2. (1: enabled, 0: disabled)",
    NPCInkColor = {
        Citizen = "Ink color for citizen.",
        Combine = "Ink color for Combine forces.",
        Military = "Ink color for military forces.",
        Zombie = "Ink color for zombies.",
        Antlion = "Ink color for antlions.",
        Alien = "Ink color for aliens.",
        Barnacle = "Ink color for barnacles.",
        Others = "Ink color for other NPCs.",
    },
    Playermodel = "Your thirdperson model.  Available values are:\n",
    ResetCamera = "Resets camera angle like Y button in Splatoon.",
    RTResolution = [[The resolution of RenderTarget used in ink system.
To apply the change, restart your GMOD client.
Higher option needs more VRAM.
Make sure your graphics card has enough space of video memory.
0: If your client has crashed while SplatoonSWEPs is loading, this value is set.
    The resolution is 2048x2048, and the VRAM usage is 32MB.
1: RT has 4096x4096 resolution.
    This option uses 128MB of your VRAM.
2: RT has 2x4096x4096 resolution.
    The resolution is twice as large as option 1.
    This option uses 256MB of your VRAM.
3: 8192x8192, using 512MB.
4: 2x8192x8192, 1GB.
5: 16384x16384, 2GB.]],
    TakeFallDamage = "Whether to take fall damage when you equip a Splatoon weapon. (1: do, 0: do not)",
    ToggleADS = "Aim down sight mode. (1: toggle, 0: hold)",
    TranslucentNearbyLocalPlayer = "Whether or not local player should be translucent when it's too close to the camera. (1: do, 0: do not)",
    weapon_splatoonsweps_charger = {
        UseRTScope = "For scoped chargers, use realistic scope instead of standard scope effect. (1: enabled, 0: disabled)",
        weapon_splatoonsweps_herocharger = {
            Level = "The level of Hero Charger Replica. (0, 1, 2, 3 -> Level 1, 2, 3, 4)",
        },
    },
    weapon_splatoonsweps_shooter = {
        NZAP_PistolStyle = "Hold N-ZAP series like a pistol. (1: enabled, 0: disabled)",
        weapon_splatoonsweps_heroshot = {
            Level = "The level of Hero Shot Replica. (0, 1, 2, 3 -> Level 1, 2, 3, 4)",
        },
        weapon_splatoonsweps_octoshot = {
            Advanced = "Skin color for Octoshot Replica. (set to 0 for standard octalian's weapon color, 1 for elite octalian's)",
        },
    },
    weapon_splatoonsweps_slosher_base = {
        Automatic = "Automatically swing sloshers. (1: enabled, 0: disabled)",
    },
    weapon_splatoonsweps_roller = {
        AutomaticBrush = "Automatically swing brushes repeatedly. (1: enabled, 0: disabled)",
        DropAtFeet = "Like version 2.8.0 or above, when repeatedly using swinging attacks, ink will also be painted where the player is standing. (1: enabled, 0: disabled)",
        weapon_splatoonsweps_heroroller = {
            Level = "The level of Hero Roller Replica. (0, 1, 2, 3 -> Level 1, 2, 3, 4)",
        },
    },
}}
