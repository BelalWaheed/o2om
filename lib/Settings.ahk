; ---------------------------------------------------------------------------
; O2om — Configuration Settings Manager
; ---------------------------------------------------------------------------

class O2omSettings {
    static CONFIG_FILE := A_ScriptDir "\o2om_config.ini"

    ; --- Settings State (Minutes) ---
    language          := "ar"
    workIntervalMin   := 40
    shortBreakMin     := 5
    longBreakMin      := 15
    escalationMin     := 2
    snoozeMin         := 5
    idleThresholdMin  := 5
    cyclesBeforeLong  := 4

    Load() {
        if !FileExist(O2omSettings.CONFIG_FILE) {
            this.Save()
            return
        }

        try {
            this.language          := IniRead(O2omSettings.CONFIG_FILE, "General", "Language", "ar")
            this.workIntervalMin   := Integer(IniRead(O2omSettings.CONFIG_FILE, "Timer", "WorkInterval", 40))
            this.shortBreakMin     := Integer(IniRead(O2omSettings.CONFIG_FILE, "Timer", "ShortBreak", 5))
            this.longBreakMin      := Integer(IniRead(O2omSettings.CONFIG_FILE, "Timer", "LongBreak", 15))
            this.escalationMin     := Integer(IniRead(O2omSettings.CONFIG_FILE, "Timer", "EscalationInterval", 2))
            this.snoozeMin         := Integer(IniRead(O2omSettings.CONFIG_FILE, "Timer", "SnoozeDuration", 5))
            this.idleThresholdMin  := Integer(IniRead(O2omSettings.CONFIG_FILE, "Timer", "IdleThreshold", 5))
            this.cyclesBeforeLong  := Integer(IniRead(O2omSettings.CONFIG_FILE, "Timer", "CyclesBeforeLong", 4))
        } catch {
            this.ResetDefaults()
        }

        ; Sync language module state
        O2omLang.currentLang := this.language
    }

    Save() {
        try {
            IniWrite(this.language,         O2omSettings.CONFIG_FILE, "General", "Language")
            IniWrite(this.workIntervalMin,  O2omSettings.CONFIG_FILE, "Timer", "WorkInterval")
            IniWrite(this.shortBreakMin,    O2omSettings.CONFIG_FILE, "Timer", "ShortBreak")
            IniWrite(this.longBreakMin,     O2omSettings.CONFIG_FILE, "Timer", "LongBreak")
            IniWrite(this.escalationMin,    O2omSettings.CONFIG_FILE, "Timer", "EscalationInterval")
            IniWrite(this.snoozeMin,        O2omSettings.CONFIG_FILE, "Timer", "SnoozeDuration")
            IniWrite(this.idleThresholdMin, O2omSettings.CONFIG_FILE, "Timer", "IdleThreshold")
            IniWrite(this.cyclesBeforeLong, O2omSettings.CONFIG_FILE, "Timer", "CyclesBeforeLong")
        }
    }

    ResetDefaults() {
        this.language         := "ar"
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
