ScriptName KickThemAll extends ReferenceAlias

Actor Property KTA_Player Auto
GlobalVariable Property KTA_Hotkey Auto
GlobalVariable Property KTA_StaminaConsumption Auto
GlobalVariable Property KTA_AssaultDamageThreshold Auto
GlobalVariable Property KTA_PushForceMultiplier Auto
GlobalVariable Property KTA_DamageValueMultiplier Auto

Bool holdingKey = False
Bool wasDrawn = False
Float pressStartTime = 0.0

Function KTA_StartKickAnimation(Float totalPressTime)
    Float playerLevel = KTA_Player.GetLevel()
    Float heavyArmorSkill = KTA_Player.GetActorValue("HeavyArmor")

    Debug.SendAnimationEvent(KTA_Player, "KickAnimation")

    Utility.Wait(0.8)
    
    KTA_Player.SetAnimationVariableInt("currentDefaultState", 1)
    Debug.SendAnimationEvent(KTA_Player, "JumpLandEnd")
    KTA_Player.DamageActorValue("Stamina", totalPressTime * KTA_StaminaConsumption.GetValue())

    ObjectReference crosshairRef = Game.GetCurrentCrosshairRef()
    If crosshairRef
        Actor targetActor = crosshairRef as Actor
        Float damageValue = (totalPressTime + (0.01 * playerLevel) + (0.05 * heavyArmorSkill)) * KTA_DamageValueMultiplier.GetValue()
        Float pushForce  = totalPressTime * KTA_PushForceMultiplier.GetValue()
        
        If targetActor
            KTA_Player.PushActorAway(targetActor, pushForce)

            If Game.GetCameraState() == 0
                targetActor.DamageActorValue("Health", damageValue)

                If damageValue >= KTA_AssaultDamageThreshold.GetValueInt()
                    If !targetActor.IsHostileToActor(KTA_Player)
                        targetActor.SendAssaultAlarm()
                        Faction crimeFaction = targetActor.GetCrimeFaction()
                        If crimeFaction
                            crimeFaction.ModCrimeGold(damageValue as Int)
                        EndIf
                    EndIf
                EndIf
            EndIf

        Else
            crosshairRef.ApplyHavokImpulse(pushForce, 0.0, 0.0, pushForce)
            crosshairRef.DamageObject(90.0)
        EndIf
    EndIf
EndFunction

Event OnInit()
    KTA_SetUp()
EndEvent

Event OnPlayerLoadGame()
    KTA_SetUp()
EndEvent

Function KTA_SetUp()
    UnregisterForAllKeys()
    RegisterForKey(KTA_Hotkey.GetValueInt())
EndFunction

Event OnKeyDown(int keyCode)
    If !Utility.IsInMenuMode() && (GetState() != "Busy") && (keyCode == KTA_Hotkey.GetValueInt()) && !KTA_Player.IsFlying() && !KTA_Player.IsInKillMove() && !KTA_Player.IsOnMount()
        Bool bFound = False
        If UI.IsMenuOpen("Crafting Menu") || UI.IsMenuOpen("ContainerMenu") || UI.IsMenuOpen("MessageBoxMenu") ||  UI.IsMenuOpen("InventoryMenu") || UI.IsMenuOpen("Console") || UI.IsMenuOpen("BarterMenu") || UI.IsTextInputEnabled()
            bFound = True
        EndIf

        If !bFound
            pressStartTime = Utility.GetCurrentRealTime()
            holdingKey = True
            RegisterForSingleUpdate(0.1)
        EndIf
    EndIf
EndEvent

Event OnUpdate()
    If holdingKey
        If Input.IsKeyPressed(KTA_Hotkey.GetValueInt())
            RegisterForSingleUpdate(0.1)
        Else
            holdingKey = False
            Float totalPressTime = Utility.GetCurrentRealTime() - pressStartTime

            GoToState("Busy")
            If KTA_Player.IsWeaponDrawn()
                wasDrawn = True
            EndIf

            KTA_StartKickAnimation(totalPressTime)

            If wasDrawn
                KTA_Player.SheatheWeapon()
                KTA_Player.DrawWeapon()
                wasDrawn = False
            EndIf
            GoToState("")
        EndIf
    EndIf
EndEvent

State Busy

    Event OnKeyDown(int keyCode)
    EndEvent

    Event OnUpdate()
    EndEvent

EndState
