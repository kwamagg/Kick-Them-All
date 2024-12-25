Scriptname KickThemAll extends ReferenceAlias

Actor Property KTA_Player Auto
GlobalVariable Property KTA_Hotkey Auto
GlobalVariable Property KTA_StaminaConsumption Auto
GlobalVariable Property KTA_AssaultDamageThreshold Auto
GlobalVariable Property KTA_PushForceMultiplier Auto
GlobalVariable Property KTA_DamageValueMultiplier Auto

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
    If !Utility.IsInMenuMode() && (keyCode == KTA_Hotkey.GetValueInt())
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
            Float playerLevel = KTA_Player.GetLevel()
            Float heavyArmorSkill = KTA_Player.GetActorValue("HeavyArmor")

            If KTA_Player.IsWeaponDrawn()
                KTA_Player.SheatheWeapon()
                wasSheathed = True
            EndIf

            Debug.SendAnimationEvent(KTA_Player,"KickAnimation")
            KTA_Player.DamageActorValue("Stamina", totalPressTime * KTA_StaminaConsumption.GetValue())
            
            Utility.Wait(0.8)
            
            KTA_Player.SetAnimationVariableInt("currentDefaultState", 1)
	        Debug.SendAnimationEvent(KTA_Player, "JumpLandEnd")
            
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
                    targetActor.ApplyHavokImpulse(pushForce, 0.0, 0.0, pushForce)
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
