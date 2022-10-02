AddCSLuaFile()
return {
    AllowSprint = false,
    AvoidWalls = true,
    BecomeSquid = true,
    CanDrown = {true, order = 4, serverside = true},
    CanHealInk = true,
    CanHealStand = true,
    CanReloadInk = true,
    CanReloadStand = true,
    DoomStyle = false,
    DrawCrosshair = true,
    DrawInkOverlay = true,
    Enabled = {true, order = 1, serverside = true},
    ExplodeOnlySquids = {false, order = 6, serverside = true},
    FF = {false, order = 3, serverside = true},
    Gain = {
        HealSpeedInk = {100, min = 1, max = 500, decimals = 0, order = 4, serverside = true},
        HealSpeedStand = {100, min = 1, max = 500, decimals = 0, order = 3, serverside = true},
        InkAmount = {100, min = 1, max = 500, decimals = 0, order = 2, serverside = true},
        MaxHealth = {100, min = 1, max = 500, decimals = 0, order = 1, serverside = true},
        ReloadSpeedInk = {100, min = 1, max = 500, decimals = 0, order = 6, serverside = true},
        ReloadSpeedStand = {100, min = 1, max = 500, decimals = 0, order = 5, serverside = true},
    },
    HideInk = {false, order = 2, serverside = true},
    HurtOwner = {false, order = 7, serverside = true},
    InkColor = {1, bottomorder = 1, type = "color"},
    LeftHand = false,
    MoveViewmodel = true,
    NewStyleCrosshair = false,
    NPCInkColor = {
        __closed = true,
        Citizen = {1, order = 1, type = "color", serverside = true},
        Combine = {2, order = 2, type = "color", serverside = true},
        Military = {3, order = 3, type = "color", serverside = true},
        Zombie = {4, type = "color", serverside = true},
        Antlion = {5, type = "color", serverside = true},
        Alien = {6, type = "color", serverside = true},
        Barnacle = {7, type = "color", serverside = true},
        Others = {8, bottomorder = 1, type = "color", serverside = true},
    },
    Playermodel = {1, hidden = true},
    RTResolution = {1, hidden = true},
    TakeFallDamage = {false, order = 5, serverside = true},
    ToggleADS = false,
    TranslucentNearbyLocalPlayer = true,
    weapon_splatoonsweps_charger = {
        UseRTScope = false,
        weapon_splatoonsweps_herocharger = {Level = {0, min = 0, max = 3}, __subcategory = true},
    },
    weapon_splatoonsweps_shooter = {
        NZAP_PistolStyle = false,
        weapon_splatoonsweps_heroshot = {Level = {0, min = 0, max = 3}, __subcategory = true},
        weapon_splatoonsweps_octoshot = {Advanced = true, __subcategory = true},
    },
    weapon_splatoonsweps_slosher_base = {
        Automatic = false,
    },
    weapon_splatoonsweps_roller = {
        AutomaticBrush = false,
        DropAtFeet = true,
        weapon_splatoonsweps_heroroller = {Level = {0, min = 0, max = 3}, __subcategory = true},
    },
}
