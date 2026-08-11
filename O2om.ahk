;@Ahk2Exe-SetDescription O2om - Stand Up & Physical Health Reminder
;@Ahk2Exe-SetVersion 1.0.0
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

#Include lib/Styles.ahk
#Include lib/Language.ahk
#Include lib/Startup.ahk
#Include lib/Notifications.ahk
#Include lib/Settings.ahk
#Include lib/TimerEngine.ahk
#Include lib/Tray.ahk
#Include lib/Gui/Dashboard.ahk
#Include lib/Gui/SettingsView.ahk

class O2omApp {
    settings   := ""
    engine     := ""

    gui        := ""
    activeView := 1  ; 1 = Timer, 4 = Settings

    ; GUI Navigation Buttons
    btnNavDash   := ""
    btnStartWork     := ""
    btnStartExercises:= ""
    btnStartBreak    := ""
    btnSnooze        := ""
    btnReset         := ""
    btnPause         := ""

    ; Break Overlay GUI
    breakGui         := ""
    breakCt          := ""

    ; Control Handles
    countdownText := ""
    statusText    := ""
    startupCheck  := ""
    ddlLanguage   := ""
    ; Bound Handlers
    fnWmActivate     := ""

    ; Settings Inputs
    editWork       := ""
    editShortBreak := ""
    editLongBreak  := ""
    editEscalation := ""
    editSnooze     := ""
    editIdle       := ""

    ; Control Collections
    dashControls     := []
    settingsControls := []

    __New() {
        O2omStartup.EnsureDefault()
        O2omNotify.RegisterAUMID()

        this.settings := O2omSettings()
        this.settings.Load()

        this.engine := O2omEngine(this.settings)
        this.fnWmActivate := ObjBindMethod(this, "OnWmActivate")

        O2omTray.Setup(this)
        this.SetupGui()
        this.ShowGui()

        SetTimer(ObjBindMethod(this, "Tick"), 1000)
        this.UpdateDisplay()
    }

    SetupGui() {
        if (this.gui)
            try this.gui.Destroy()

        this.dashControls      := []
        this.settingsControls  := []

        isRTL := (O2omLang.currentLang == "ar")
        guiOpts := "+MinimizeBox -MaximizeBox +0x02000000"  ; 0x02000000 = WS_CLIPCHILDREN (eliminates redraw flicker)
        if (isRTL)
            guiOpts .= " +E0x400000"

        g := Gui(guiOpts, O2omLang.Get("app_title"))
        g.BackColor := O2omStyles.COLOR_BG

        ; 2 Top Navigation Tabs (Centered perfectly: x82 and x197)
        this.btnNavDash := g.AddButton("x82 y14 w105 h32", O2omLang.Get("tab_timer"))
        this.btnNavDash.SetFont("s9 Bold", O2omStyles.FONT_PRIMARY)
        this.btnNavDash.OnEvent("Click", (*) => this.SwitchView(1))

        this.btnNavSet := g.AddButton("x197 y14 w105 h32", O2omLang.Get("tab_settings"))
        this.btnNavSet.SetFont("s9 norm", O2omStyles.FONT_PRIMARY)
        this.btnNavSet.OnEvent("Click", (*) => this.SwitchView(4))

        ; Accent Separator Line
        g.AddProgress("x15 y50 w355 h2 Background" O2omStyles.COLOR_CARD, 0)

        ; Build Views
        O2omDashboardView.Build(g, this, this.dashControls)
        O2omSettingsView.Build(g, this, this.settingsControls)

        ; Window Close (X) minimizes to tray
        g.OnEvent("Close", (*) => g.Hide())

        this.gui := g

        this.SetupBreakGui()

        this.SwitchView(this.activeView)
        mode := this.engine.isWaitingBreak ? "wait_break" : "normal"
        this.ToggleDashboardButtons(mode)
        
        g.Show("w385 h" O2omStyles.WIN_HEIGHT " Hide")
    }

    SetupBreakGui() {
        if (this.breakGui)
            try this.breakGui.Destroy()

        bg := Gui("-Caption +0x02000000", O2omLang.Get("app_title"))
        bg.BackColor := O2omStyles.COLOR_BG
        
        ; Pressing ESC key closes break mode and returns to work
        bg.OnEvent("Escape", (*) => this.StartWorkMode())

        ; Timer Text at bottom left
        this.breakCt := bg.AddText("x40 y" (A_ScreenHeight - 70) " w300 h60 c" O2omStyles.COLOR_TEXT, "00:00")
        this.breakCt.SetFont("s42 Bold", O2omStyles.FONT_TITLE)

        ; High-visibility Start Work / Close Button at bottom right
        btnEnd := bg.AddButton("x" (A_ScreenWidth - 240) " y" (A_ScreenHeight - 65) " w200 h45", O2omLang.Get("btn_start_work"))
        btnEnd.SetFont("s12 Bold", O2omStyles.FONT_PRIMARY)
        btnEnd.OnEvent("Click", (*) => this.StartWorkMode())

        ; Responsive Screen Scaling for 16:9 o2om-exercises.png (No text overlays)
        maxImgH := A_ScreenHeight - 140
        maxImgW := A_ScreenWidth - 40
        imgW := Min(maxImgW, Integer(maxImgH * 16 / 9))
        imgH := Integer(imgW * 9 / 16)

        ix := (A_ScreenWidth - imgW) / 2
        iy := (A_ScreenHeight - 80 - imgH) / 2
        bg.AddPicture("x" ix " y" iy " w" imgW " h" imgH, A_ScriptDir "\assets\exercises_bg.png")

        this.breakGui := bg
    }

    OnWmActivate(wParam, lParam, msg, hwnd) {
        ; Auto-hide removed as requested by user
    }

    SwitchView(viewNum) {
        if (viewNum == 2 || viewNum == 3)
            viewNum := 1

        this.activeView := viewNum

        this.btnNavDash.SetFont(viewNum == 1 ? "s9 Bold" : "s9 norm")
        this.btnNavSet.SetFont(viewNum == 4 ? "s9 Bold" : "s9 norm")

        for ctrl in this.dashControls {
            ; Don't blindly make Action buttons visible, preserve their specific state
            if (ctrl == this.btnReset || ctrl == this.btnPause || ctrl == this.btnStartWork || ctrl == this.btnStartBreak || ctrl == this.btnStartExercises || ctrl == this.btnSnooze) {
                if (viewNum != 1)
                    ctrl.Visible := false
                continue
            }
            ctrl.Visible := (viewNum == 1)
        }

        if (viewNum == 1) {
            mode := this.engine.isWaitingWork ? "wait_work" : (this.engine.isWaitingBreak ? "wait_break" : "normal")
            this.ToggleDashboardButtons(mode)
        }

        for ctrl in this.settingsControls
            ctrl.Visible := (viewNum == 4)
    }

    ShowGui() {
        if (this.gui) {
            mode := this.engine.isWaitingWork ? "wait_work" : (this.engine.isWaitingBreak ? "wait_break" : "normal")
            this.ToggleDashboardButtons(mode)
            try this.gui.Show()
            try WinActivate("ahk_id " this.gui.Hwnd)
        }
    }



    ApplySettingsFromGui() {
        workVal       := Integer(this.editWork.Value)
        shortVal      := Integer(this.editShortBreak.Value)
        longVal       := Integer(this.editLongBreak.Value)
        escalationVal := Integer(this.editEscalation.Value)
        snoozeVal     := Integer(this.editSnooze.Value)
        idleVal       := Integer(this.editIdle.Value)

        if (workVal <= 0 || shortVal <= 0 || longVal <= 0 || escalationVal <= 0 || snoozeVal <= 0 || idleVal <= 0) {
            MsgBox(O2omLang.Get("msg_invalid_input"), O2omLang.Get("app_title"), "Icon!")
            return
        }

        oldLang := this.settings.language
        selectedLang := (this.ddlLanguage.Text == "English") ? "en" : "ar"
        
        this.settings.language         := selectedLang
        O2omLang.currentLang           := selectedLang

        this.settings.workIntervalMin  := workVal
        this.settings.shortBreakMin    := shortVal
        this.settings.longBreakMin     := longVal
        this.settings.escalationMin     := escalationVal
        this.settings.snoozeMin         := snoozeVal
        this.settings.idleThresholdMin  := idleVal

        this.settings.Save()

        ; Apply new timer duration and refresh UI
        this.engine.ResetToWork()
        O2omTray.Setup(this)
        this.SetupGui()
        this.ShowGui()

        O2omNotify.Show(O2omLang.Get("app_title"), O2omLang.Get("msg_saved"))
    }

    Tick() {
        res := this.engine.Tick()

        if (res.type == "waiting_break") {
            this.SwitchView(1)
            this.ToggleDashboardButtons("wait_break")
            this.ShowGui()
            O2omNotify.Show(O2omLang.Get("toast_break_title"), O2omLang.Get("toast_break_stage1"))
        } else if (res.type == "escalation") {
            toastMsg := (res.stage == 1) ? O2omLang.Get("toast_break_stage2") : O2omLang.Get("toast_break_stage3")
            O2omNotify.Show(O2omLang.Get("toast_break_title"), toastMsg)
        } else if (res.type == "break_ended") {
            O2omNotify.Show(O2omLang.Get("toast_break_title"), O2omLang.Get("toast_break_ended"), 64)
            if (this.breakGui) {
                try this.breakGui.Destroy()
                this.breakGui := ""
            }
            this.SwitchView(1)
            this.ToggleDashboardButtons("wait_work")
            this.ShowGui()
        }

        this.UpdateDisplay()
    }

    ToggleDashboardButtons(mode) {
        if !IsObject(this.btnReset)
            return

        if (this.activeView != 1) {
            this.btnReset.Visible          := false
            this.btnPause.Visible          := false
            this.btnStartWork.Visible      := false
            this.btnStartBreak.Visible     := false
            this.btnStartExercises.Visible := false
            this.btnSnooze.Visible         := false
            return
        }

        this.btnReset.Visible          := (mode == "normal")
        this.btnPause.Visible          := (mode == "normal")
        this.btnStartWork.Visible      := (mode == "wait_work")
        this.btnStartBreak.Visible     := (mode == "wait_break")
        this.btnStartExercises.Visible := (mode == "wait_break")
        this.btnSnooze.Visible         := (mode == "wait_break")

        if (this.gui && this.gui.Hwnd)
            try WinRedraw("ahk_id " this.gui.Hwnd)
    }

    TogglePauseTimer() {
        isPaused := this.engine.TogglePause()
        if IsObject(this.btnPause)
            this.btnPause.Text := O2omLang.Get(isPaused ? "btn_resume" : "btn_pause")
        this.UpdateDisplay()
    }

    StartWorkMode() {
        this.engine.StartWork()
        if (this.breakGui) {
            try this.breakGui.Destroy()
            this.breakGui := ""
        }
        this.ToggleDashboardButtons("normal")
        this.SwitchView(1)
        this.UpdateDisplay()
    }

    StartBreakMode(showExercises) {
        this.engine.StartBreak()
        this.gui.Hide()
        this.ToggleDashboardButtons("normal")
        if (showExercises) {
            this.SetupBreakGui()
            this.breakGui.Show("w" A_ScreenWidth " h" A_ScreenHeight)
        }
    }

    ResetTimer() {
        this.ToggleDashboardButtons("normal")
        this.breakGui.Hide()
        this.engine.ResetToWork()
        this.SwitchView(1)
        this.UpdateDisplay()
    }

    SnoozeTimer() {
        this.ToggleDashboardButtons("normal")
        this.breakGui.Hide()
        this.engine.Snooze()
        this.SwitchView(1)
        this.UpdateDisplay()
    }

    UpdateDisplay() {
        totalSec := Max(0, this.engine.remaining) // 1000
        mins := Format("{:02}", totalSec // 60)
        secs := Format("{:02}", Mod(totalSec, 60))
        timeStr := mins ":" secs

        try this.countdownText.Value := timeStr
        try this.breakCt.Value := timeStr

        try {
            if (this.engine.isIdle)
                statusVal := O2omLang.Get("status_idle")
            else if (this.engine.isPaused)
                statusVal := O2omLang.Get("status_paused")
            else if (this.engine.isOnBreak)
                statusVal := O2omLang.Get("status_on_break")
            else if (this.engine.isWaitingBreak)
                statusVal := O2omLang.Get("toast_break_stage1")
            else if (this.engine.isWaitingWork)
                statusVal := O2omLang.Get("btn_start_work")
            else
                statusVal := O2omLang.Get("status_next_break")
            this.statusText.Value := statusVal
        }

        try this.gui.Title := O2omLang.Get("app_title")
        O2omTray.UpdateTooltip(timeStr)
    }
}

; App Entry Point
O2omApp()