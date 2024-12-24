Scriptname KickThemAll extends ReferenceAlias

Actor Property KTA_Player Auto
GlobalVariable Property KTA_Hotkey Auto
GlobalVariable Property KTA_StaminaConsumption Auto

Bool holdingKey = False
Bool wasSheathed = False
Float pressStartTime = 0.0

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
    If !Utility.IsInMenuMode()
        pressStartTime = Utility.GetCurrentRealTime()
        holdingKey = True
        RegisterForSingleUpdate(0.1)
    EndIf
EndEvent

Event OnUpdate()
    If holdingKey
        If Input.IsKeyPressed(KTA_Hotkey.GetValueInt())
            RegisterForSingleUpdate(0.1)
        Else
            holdingKey = False
            Float totalPressTime = Utility.GetCurrentRealTime() - pressStartTime
            ObjectReference crosshairRef = Game.GetCurrentCrosshairRef()
            If KTA_Player.IsWeaponDrawn()
                KTA_Player.SheatheWeapon()
                wasSheathed = True
            EndIf
            Debug.SendAnimationEvent(KTA_Player,"KickAnimation")
            KTA_Player.DamageActorValue("Stamina", totalPressTime * KTA_StaminaConsumption.GetValue())
            Utility.Wait(1.0)
            KTA_Player.SetAnimationVariableInt("currentDefaultState", 1)
	    Debug.SendAnimationEvent(KTA_Player, "JumpLandEnd")
            If crosshairRef
                Actor targetActor = crosshairRef as Actor
                If targetActor
                    KTA_Player.PushActorAway(targetActor, totalPressTime * 5.0)
                    If Game.GetCameraState() == 0
                        targetActor.DamageActorValue("Health", totalPressTime * 2.5)
                    EndIf
                Else
                    targetActor.ApplyHavokImpulse(totalPressTime * 2.5, 0.0, 0.0, 5.0)
                    crosshairRef.DamageObject(90.0)
                EndIf
            EndIf
            If wasSheathed
                KTA_Player.DrawWeapon()
                wasSheathed = False
            EndIf
        EndIf
    EndIf
EndEvent
