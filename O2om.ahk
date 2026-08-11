;@Ahk2Exe-SetDescription O2om - Stand Up & Physical Health Reminder
;@Ahk2Exe-SetVersion 0.6.1
;@Ahk2Exe-SetName O2om
;@Ahk2Exe-SetMainIcon assets\o2om.ico
;@Ahk2Exe-SetCopyright (c) 2026
;@Ahk2Exe-SetOrigFilename O2om.exe

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; ---------------------------------------------------------------------------
; O2om (قُوم) — Stand-Up & Physical Health Reminder
; ---------------------------------------------------------------------------

class O2omApp {
    ; --- Constants ---
    static CONFIG_FILE := A_ScriptDir "\o2om_config.ini"
    static REG_KEY     := "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
    static REG_VALUE   := "O2om"
    static SLEEP_GAP   := 5000 ; 5 seconds

    ; --- Configuration Defaults (Minutes) ---
    workIntervalMin   := 40
    escalationMin     := 2
    snoozeMin         := 5
    idleThresholdMin  := 5

    ; --- Calculated Millisecond Properties ---
    intervalMs      => this.workIntervalMin * 60 * 1000
    escalationMs    => this.escalationMin * 60 * 1000
    snoozeMs        => this.snoozeMin * 60 * 1000
    idleThresholdMs => this.idleThresholdMin * 60 * 1000

    ; --- State ---
    remaining     := 0
    lastTick      := 0
    reminderStage := 0  ; 0 = Countdown, 1 = First Warning, 2 = Final Warning
    isIdle        := false
    activeView    := 1  ; 1 = Dashboard, 2 = Settings

    ; --- GUI Handles ---
    gui           := ""
    btnNavDash    := ""
    btnNavSet     := ""
    countdownText := ""
    statusText    := ""
    startupCheck  := ""
    
    ; --- Settings Inputs ---
    editWork       := ""
    editEscalation := ""
    editSnooze     := ""
    editIdle       := ""

    ; --- Control Collections ---
    dashControls     := []
    settingsControls := []

    __New() {
        this.EnsureDefaultStartup()
        this.LoadSettings()
        this.remaining := this.intervalMs
        this.lastTick  := A_TickCount

        this.SetupTray()
        this.SetupGui()

        SetTimer(ObjBindMethod(this, "Tick"), 1000)
        this.UpdateDisplay()
    }

    ; -----------------------------------------------------------------------
    ; STARTUP & INI PERSISTENCE
    ; -----------------------------------------------------------------------
    EnsureDefaultStartup() {
        if !this.IsStartupEnabled() {
            this.SetStartupEnabled(true)
        }
    }

    LoadSettings() {
        if !FileExist(O2omApp.CONFIG_FILE) {
            this.SaveSettings()
            return
        }

        try {
            this.workIntervalMin  := Integer(IniRead(O2omApp.CONFIG_FILE, "Timer", "WorkInterval", 40))
            this.escalationMin    := Integer(IniRead(O2omApp.CONFIG_FILE, "Timer", "EscalationInterval", 2))
            this.snoozeMin        := Integer(IniRead(O2omApp.CONFIG_FILE, "Timer", "SnoozeDuration", 5))
            this.idleThresholdMin := Integer(IniRead(O2omApp.CONFIG_FILE, "Timer", "IdleThreshold", 5))
        } catch {
            this.workIntervalMin  := 40
            this.escalationMin    := 2
            this.snoozeMin        := 5
            this.idleThresholdMin := 5
        }
    }

    SaveSettings() {
        try {
            IniWrite(this.workIntervalMin,  O2omApp.CONFIG_FILE, "Timer", "WorkInterval")
            IniWrite(this.escalationMin,    O2omApp.CONFIG_FILE, "Timer", "EscalationInterval")
            IniWrite(this.snoozeMin,        O2omApp.CONFIG_FILE, "Timer", "SnoozeDuration")
            IniWrite(this.idleThresholdMin, O2omApp.CONFIG_FILE, "Timer", "IdleThreshold")
        }
    }

    ; -----------------------------------------------------------------------
    ; TRAY SETUP
    ; -----------------------------------------------------------------------
    SetupTray() {
        iconPath := A_ScriptDir "\assets\o2om.ico"
        if FileExist(iconPath)
            TraySetIcon(iconPath)

        tray := A_TrayMenu
        tray.Delete()

        tray.Add("Show Dashboard", ObjBindMethod(this, "OnTrayShow"))
        tray.Add()
        tray.Add("Reset Timer", (*) => this.ResetTimer())
        tray.Add("Quit O2om", (*) => ExitApp())

        tray.Default := "Show Dashboard"
    }

    ; -----------------------------------------------------------------------
    ; GUI SETUP
    ; -----------------------------------------------------------------------
    SetupGui() {
        g := Gui("+MinimizeBox -MaximizeBox", "O2om — Stand-Up Reminder")
        g.BackColor := "181825"

        ; Top Navigation Switcher
        this.btnNavDash := g.AddButton("x20 y16 w145 h32", "Timer")
        this.btnNavDash.SetFont("s9 Bold", "Segoe UI")
        this.btnNavDash.OnEvent("Click", (*) => this.SwitchView(1))

        this.btnNavSet := g.AddButton("x175 y16 w145 h32", "Settings")
        this.btnNavSet.SetFont("s9 norm", "Segoe UI")
        this.btnNavSet.OnEvent("Click", (*) => this.SwitchView(2))

        ; Separator Line Accent
        g.AddProgress("x20 y54 w300 h2 Background313244", 0)

        ; ===================================================================
        ; VIEW 1: DASHBOARD CONTROLS
        ; ===================================================================
        st := g.AddText("x20 y68 w300 h20 Center cE0E0E0", "Next break in...")
        st.SetFont("s10 Bold", "Segoe UI")
        this.statusText := st
        this.dashControls.Push(st)

        ct := g.AddText("x20 y90 w300 h65 Center cWhite", "00:00")
        ct.SetFont("s42 Bold", "Segoe UI")
        this.countdownText := ct
        this.dashControls.Push(ct)

        btnReset := g.AddButton("x20 y165 w145 h34", "Reset Timer")
        btnReset.SetFont("s9", "Segoe UI")
        btnReset.OnEvent("Click", (*) => this.ResetTimer())
        this.dashControls.Push(btnReset)

        btnSnooze := g.AddButton("x175 y165 w145 h34", "Snooze")
        btnSnooze.SetFont("s9", "Segoe UI")
        btnSnooze.OnEvent("Click", (*) => this.SnoozeTimer())
        this.dashControls.Push(btnSnooze)

        isStartup := this.IsStartupEnabled()
        this.startupCheck := g.AddCheckbox("x20 y215 w300 h24 cWhite " (isStartup ? "Checked" : ""), "Start automatically with Windows")
        this.startupCheck.SetFont("s9", "Segoe UI")
        this.startupCheck.OnEvent("Click", ObjBindMethod(this, "OnStartupToggle"))
        this.dashControls.Push(this.startupCheck)

        ; ===================================================================
        ; VIEW 2: SETTINGS CONTROLS
        ; ===================================================================
        lbl1 := g.AddText("x25 y72 w180 h24 cWhite", "Work Interval (min):")
        lbl1.SetFont("s9 Bold", "Segoe UI")
        this.settingsControls.Push(lbl1)

        this.editWork := g.AddEdit("x215 y68 w90 h26 Center Number", this.workIntervalMin)
        this.editWork.SetFont("s9 Bold", "Segoe UI")
        this.settingsControls.Push(this.editWork)

        lbl2 := g.AddText("x25 y112 w180 h24 cWhite", "Warning Interval (min):")
        lbl2.SetFont("s9 Bold", "Segoe UI")
        this.settingsControls.Push(lbl2)

        this.editEscalation := g.AddEdit("x215 y108 w90 h26 Center Number", this.escalationMin)
        this.editEscalation.SetFont("s9 Bold", "Segoe UI")
        this.settingsControls.Push(this.editEscalation)

        lbl3 := g.AddText("x25 y152 w180 h24 cWhite", "Snooze Duration (min):")
        lbl3.SetFont("s9 Bold", "Segoe UI")
        this.settingsControls.Push(lbl3)

        this.editSnooze := g.AddEdit("x215 y148 w90 h26 Center Number", this.snoozeMin)
        this.editSnooze.SetFont("s9 Bold", "Segoe UI")
        this.settingsControls.Push(this.editSnooze)

        lbl4 := g.AddText("x25 y192 w180 h24 cWhite", "Idle Threshold (min):")
        lbl4.SetFont("s9 Bold", "Segoe UI")
        this.settingsControls.Push(lbl4)

        this.editIdle := g.AddEdit("x215 y188 w90 h26 Center Number", this.idleThresholdMin)
        this.editIdle.SetFont("s9 Bold", "Segoe UI")
        this.settingsControls.Push(this.editIdle)

        btnSave := g.AddButton("x20 y232 w300 h36", "Save Settings")
        btnSave.SetFont("s9 Bold", "Segoe UI")
        btnSave.OnEvent("Click", (*) => this.ApplySettingsFromGui())
        this.settingsControls.Push(btnSave)

        ; Window Close (X) minimizes to tray
        g.OnEvent("Close", (*) => g.Hide())
        this.gui := g

        ; Initial View Setup
        this.SwitchView(1)
        
        ; Start application minimized (GUI hidden)
        g.Show("w340 h295 Hide")
    }

    ; -----------------------------------------------------------------------
    ; VIEW SWITCHER
    ; -----------------------------------------------------------------------
    SwitchView(viewNum) {
        this.activeView := viewNum

        if (viewNum == 1) {
            this.btnNavDash.SetFont("s9 Bold")
            this.btnNavSet.SetFont("s9 norm")
        } else {
            this.btnNavDash.SetFont("s9 norm")
            this.btnNavSet.SetFont("s9 Bold")
        }

        for ctrl in this.dashControls
            ctrl.Visible := (viewNum == 1)

        for ctrl in this.settingsControls
            ctrl.Visible := (viewNum == 2)
    }

    ; -----------------------------------------------------------------------
    ; APPLY SETTINGS
    ; -----------------------------------------------------------------------
    ApplySettingsFromGui() {
        workVal       := Integer(this.editWork.Value)
        escalationVal := Integer(this.editEscalation.Value)
        snoozeVal     := Integer(this.editSnooze.Value)
        idleVal       := Integer(this.editIdle.Value)

        if (workVal <= 0 || escalationVal <= 0 || snoozeVal <= 0 || idleVal <= 0) {
            MsgBox("All interval values must be greater than 0.", "O2om — Invalid Input", "Icon!")
            return
        }

        this.workIntervalMin  := workVal
        this.escalationMin    := escalationVal
        this.snoozeMin        := snoozeVal
        this.idleThresholdMin := idleVal

        this.SaveSettings()
        this.ResetTimer()
        this.SwitchView(1)
        
        TrayTip("Settings updated successfully.", "O2om (قُوم)")
    }

    ; -----------------------------------------------------------------------
    ; TIMER TICK ENGINE
    ; -----------------------------------------------------------------------
    Tick() {
        now   := A_TickCount
        delta := now - this.lastTick
        this.lastTick := now

        if (delta < 0)
            delta += 0x100000000

        idle := A_TimeIdlePhysical

        if (delta > O2omApp.SLEEP_GAP) {
            if (idle >= this.idleThresholdMs) {
                this.ResetTimer()
            }
            this.UpdateDisplay()
            return
        }

        if (this.isIdle) {
            if (idle < this.idleThresholdMs) {
                this.ResetTimer()
            }
            this.UpdateDisplay()
            return
        }

        if (idle >= this.idleThresholdMs) {
            this.isIdle := true
            this.UpdateDisplay()
            return
        }

        this.remaining -= delta
        if (this.remaining <= 0) {
            this.HandleEscalation()
            return
        }

        this.UpdateDisplay()
    }

    ; -----------------------------------------------------------------------
    ; ESCALATION NOTIFICATIONS
    ; -----------------------------------------------------------------------
    HandleEscalation() {
        if (this.reminderStage == 0) {
            this.reminderStage := 1
            this.remaining     := this.escalationMs
            SoundPlay("*64")
            TrayTip("حان وقت الاستراحة! قوم للوقوف والتمدد.", "O2om (قُوم)")
        } 
        else if (this.reminderStage == 1) {
            this.reminderStage := 2
            this.remaining     := this.escalationMs
            SoundPlay("*48")
            TrayTip("تنبيه إضافي: مرت فترة الاستراحة، يرجى القيام والتحرك!", "O2om (قُوم)")
        } 
        else if (this.reminderStage == 2) {
            SoundPlay("*16")
            TrayTip("التنبيه الأخير: تم إعادة تشغيل المؤقت تلقائياً.", "O2om (قُوم)")
            this.ResetTimer()
            return
        }

        this.UpdateDisplay()
    }

    ResetTimer() {
        this.remaining     := this.intervalMs
        this.reminderStage := 0
        this.isIdle        := false
        this.UpdateDisplay()
    }

    SnoozeTimer() {
        this.remaining     := this.snoozeMs
        this.reminderStage := 0
        this.isIdle        := false
        this.UpdateDisplay()
    }

    ; -----------------------------------------------------------------------
    ; DISPLAY & SYSTEM INTEGRATION
    ; -----------------------------------------------------------------------
    UpdateDisplay() {
        totalSec := Max(0, this.remaining) // 1000
        mins := Format("{:02}", totalSec // 60)
        secs := Format("{:02}", Mod(totalSec, 60))
        timeStr := mins ":" secs

        if IsObject(this.countdownText)
            this.countdownText.Value := timeStr

        if IsObject(this.statusText) {
            if (this.isIdle)
                this.statusText.Value := "المستخدم غير نشط — توقف مؤقت"
            else if (this.reminderStage == 1)
                this.statusText.Value := "تنبيه أول (" timeStr " متبقي)"
            else if (this.reminderStage == 2)
                this.statusText.Value := "تنبيه أخير (" timeStr " متبقي)"
            else
                this.statusText.Value := "Next break in..."
        }

        ; Keep the window title fixed
        try this.gui.Title := "O2om — Stand-Up Reminder"

        ; Keep the timer in the system tray tooltip
        A_IconTip := "O2om — " timeStr
    }

    IsStartupEnabled() {
        try return (RegRead(O2omApp.REG_KEY, O2omApp.REG_VALUE) != "")
        catch
            return false
    }

    SetStartupEnabled(enable) {
        if (enable) {
            exePath := A_IsCompiled ? A_ScriptFullPath : ('"' A_AhkPath '" "' A_ScriptFullPath '"')
            RegWrite(exePath, "REG_SZ", O2omApp.REG_KEY, O2omApp.REG_VALUE)
        } else {
            try RegDelete(O2omApp.REG_KEY, O2omApp.REG_VALUE)
        }
    }

    ; -----------------------------------------------------------------------
    ; EVENT HANDLERS
    ; -----------------------------------------------------------------------
    OnTrayShow(*) {
        this.gui.Show()
        WinActivate("ahk_id " this.gui.Hwnd)
    }

    OnStartupToggle(*) {
        this.SetStartupEnabled(this.startupCheck.Value)
    }
}

; Entry Point
O2omApp()