Scriptname KickThemAllMCM extends MCM_ConfigBase

Quest Property KickThemAllQuest Auto
GlobalVariable Property KTA_Hotkey Auto
GlobalVariable Property KTA_StaminaConsumption Auto

Bool migrated = False

Int Function GetVersion()
    return 1
EndFunction

Event OnUpdate()
    parent.OnUpdate()
    If !migrated
        MigrateToMCMHelper()
        migrated = True
    EndIf
EndEvent

Event OnGameReload()
    parent.OnGameReload()
    If !migrated
        MigrateToMCMHelper()
        migrated = True
    EndIf
    If GetModSettingBool("bLoadSettingsonReload:Maintenance")
        LoadSettings()
    EndIf
EndEvent

Event OnConfigOpen()
    parent.OnConfigOpen()
    If !migrated
        MigrateToMCMHelper()
        migrated = True
    EndIf
EndEvent

Event OnConfigInit()
    parent.OnConfigInit()
    migrated = True
    LoadSettings()
EndEvent

Event OnSettingChange(String a_ID)
    parent.OnSettingChange(a_ID)
    If a_ID == "iHotkey:General"
        KTA_Hotkey.SetValue(GetModSettingInt("iHotkey:General") as Float)
        (KickThemAllQuest.GetAlias(0) as ReferenceAlias).OnPlayerLoadGame()
        SetModSettingInt("iAssignKey:Controller", 0)
        RefreshMenu()
    ElseIf a_ID == "iStaminaConsumption:General"
        KTA_StaminaConsumption.SetValue(GetModSettingInt("iStaminaConsumption:General") as Float)
        (KickThemAllQuest.GetAlias(0) as ReferenceAlias).OnPlayerLoadGame()
        RefreshMenu()
    ElseIf a_ID == "iAssignKey:Controller"
        If GetModSettingInt("iAssignKey:Controller") > 0
            KTA_Hotkey.SetValue(265 + GetModSettingInt("iAssignKey:Controller") as Float)
            SetModSettingInt("iHotkey:General", 265 + GetModSettingInt("iAssignKey:Controller"))
            (KickThemAllQuest.GetAlias(0) as ReferenceAlias).OnPlayerLoadGame()
            RefreshMenu()
        EndIf
    EndIf
EndEvent

Event OnPageSelect(String a_page)
    parent.OnPageSelect(a_page)
EndEvent

Function Default()
    SetModSettingInt("iHotkey:General", 34)
    SetModSettingInt("iAssignKey:Controller", 0)
    SetModSettingInt("iStaminaConsumption:General", 10)
    SetModSettingBool("bEnabled:Maintenance", True)
    SetModSettingInt("iLoadingDelay:Maintenance", 0)
    SetModSettingBool("bLoadSettingsonReload:Maintenance", False)
    Load()
EndFunction

Function Load()
    KTA_Hotkey.SetValue(GetModSettingInt("iHotkey:General") as Float)
    (KickThemAllQuest.GetAlias(0) as ReferenceAlias).OnPlayerLoadGame()
EndFunction

Function LoadSettings()
    If GetModSettingBool("bEnabled:Maintenance") == False
        Return
    EndIf
    Utility.Wait(GetModSettingInt("iLoadingDelay:Maintenance"))
    Load()
EndFunction

Function MigrateToMCMHelper()
    SetModSettingInt("iHotkey:General", KTA_Hotkey.GetValue() as Int)
EndFunction
