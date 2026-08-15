; ---------------------------------------------------------------------------
; O2om — Configuration Settings Manager with Portable Fallback
; ---------------------------------------------------------------------------

class O2omSettings {
    static configFile := ""

    ; --- Settings State (Minutes & Preferences) ---
    language          := "ar"
    startWithWindows  := 1
    workIntervalMin   := 40
    shortBreakMin     := 5
    longBreakMin      := 15
    escalationMin     := 2
    snoozeMin         := 5
    idleThresholdMin  := 5
    cyclesBeforeLong  := 4

    static GetConfigFilePath() {
        if (O2omSettings.configFile != "")
            return O2omSettings.configFile

        localPath := A_ScriptDir "\o2om_config.ini"
        if FileExist(localPath) {
            O2omSettings.configFile := localPath
            return localPath
        }

        appDataDir  := A_AppData "\O2om"
        appDataPath := appDataDir "\o2om_config.ini"
        if FileExist(appDataPath) {
            O2omSettings.configFile := appDataPath
            return appDataPath
        }

        ; Check if local directory is writable
        try {
            testFile := A_ScriptDir "\.write_test"
            FileAppend("test", testFile)
            FileDelete(testFile)
            O2omSettings.configFile := localPath
            return localPath
        } catch {
            try DirCreate(appDataDir)
            O2omSettings.configFile := appDataPath
            return appDataPath
        }
    }

    Load() {
        cfg := O2omSettings.GetConfigFilePath()
        if !FileExist(cfg) {
            this.Save()
            return
        }

        try {
            this.language          := IniRead(cfg, "General", "Language", "ar")
            this.startWithWindows  := Integer(IniRead(cfg, "General", "StartWithWindows", 1))
            this.workIntervalMin   := Integer(IniRead(cfg, "Timer", "WorkInterval", 40))
            this.shortBreakMin     := Integer(IniRead(cfg, "Timer", "ShortBreak", 5))
            this.longBreakMin      := Integer(IniRead(cfg, "Timer", "LongBreak", 15))
            this.escalationMin     := Integer(IniRead(cfg, "Timer", "EscalationInterval", 2))
            this.snoozeMin         := Integer(IniRead(cfg, "Timer", "SnoozeDuration", 5))
            this.idleThresholdMin  := Integer(IniRead(cfg, "Timer", "IdleThreshold", 5))
            this.cyclesBeforeLong  := Integer(IniRead(cfg, "Timer", "CyclesBeforeLong", 4))
        } catch {
            this.ResetDefaults()
        }

        ; Sync language module state
        O2omLang.currentLang := this.language
    }

    Save() {
        cfg := O2omSettings.GetConfigFilePath()
        try {
            IniWrite(this.language,         cfg, "General", "Language")
            IniWrite(this.startWithWindows, cfg, "General", "StartWithWindows")
            IniWrite(this.workIntervalMin,  cfg, "Timer", "WorkInterval")
            IniWrite(this.shortBreakMin,    cfg, "Timer", "ShortBreak")
            IniWrite(this.longBreakMin,     cfg, "Timer", "LongBreak")
            IniWrite(this.escalationMin,    cfg, "Timer", "EscalationInterval")
            IniWrite(this.snoozeMin,        cfg, "Timer", "SnoozeDuration")
            IniWrite(this.idleThresholdMin, cfg, "Timer", "IdleThreshold")
            IniWrite(this.cyclesBeforeLong, cfg, "Timer", "CyclesBeforeLong")
        }
    }

    ResetDefaults() {
        this.language         := "ar"
        this.startWithWindows := 1
        this.workIntervalMin  := 40
        this.shortBreakMin    := 5
        this.longBreakMin     := 15
        this.escalationMin    := 2
        this.snoozeMin        := 5
        this.idleThresholdMin := 5
        this.cyclesBeforeLong := 4
        O2omLang.currentLang  := "ar"
    }
}
