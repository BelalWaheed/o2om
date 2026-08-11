; ---------------------------------------------------------------------------
; O2om — Dashboard & Timer View
; ---------------------------------------------------------------------------

class O2omDashboardView {
    static Build(g, appInstance, controlsList) {
        ; Status Text
        st := g.AddText("x20 y50 w345 h24 Center c" O2omStyles.COLOR_PRIMARY, "")
        st.SetFont("s11 Bold", O2omStyles.FONT_PRIMARY)
        appInstance.statusText := st
        controlsList.Push(st)

        ; Countdown Timer Text (h75 ensures tall s44 numbers don't clip at top!)
        ct := g.AddText("x20 y80 w345 h75 Center c" O2omStyles.COLOR_TEXT, "00:00")
        ct.SetFont("s44 Bold", O2omStyles.FONT_TITLE)
        appInstance.countdownText := ct
        controlsList.Push(ct)

        ; Action Buttons (Slot 1 at y172: Reset & Pause side-by-side, or StartWork)
        btnReset := g.AddButton("x43 y172 w145 h34", O2omLang.Get("btn_reset"))
        btnReset.SetFont("s10 Bold", O2omStyles.FONT_PRIMARY)
        btnReset.OnEvent("Click", (*) => appInstance.ResetTimer())
        appInstance.btnReset := btnReset
        controlsList.Push(btnReset)

        btnPause := g.AddButton("x198 y172 w145 h34", O2omLang.Get("btn_pause"))
        btnPause.SetFont("s10 Bold", O2omStyles.FONT_PRIMARY)
        btnPause.OnEvent("Click", (*) => appInstance.TogglePauseTimer())
        appInstance.btnPause := btnPause
        controlsList.Push(btnPause)

        btnStartWork := g.AddButton("x43 y172 w300 h34", O2omLang.Get("btn_start_work"))
        btnStartWork.SetFont("s10 Bold", O2omStyles.FONT_PRIMARY)
        btnStartWork.OnEvent("Click", (*) => appInstance.StartWorkMode())
        btnStartWork.Visible := false
        appInstance.btnStartWork := btnStartWork
        controlsList.Push(btnStartWork)

        btnStartBreak := g.AddButton("x43 y172 w300 h34", O2omLang.Get("btn_start_break"))
        btnStartBreak.SetFont("s9 Bold", O2omStyles.FONT_PRIMARY)
        btnStartBreak.OnEvent("Click", (*) => appInstance.StartBreakMode(false))
        btnStartBreak.Visible := false
        appInstance.btnStartBreak := btnStartBreak
        controlsList.Push(btnStartBreak)

        btnStartExercises := g.AddButton("x43 y214 w300 h34", O2omLang.Get("btn_start_exercises"))
        btnStartExercises.SetFont("s9 Bold", O2omStyles.FONT_PRIMARY)
        btnStartExercises.OnEvent("Click", (*) => appInstance.StartBreakMode(true))
        btnStartExercises.Visible := false
        appInstance.btnStartExercises := btnStartExercises
        controlsList.Push(btnStartExercises)

        btnSnooze := g.AddButton("x43 y256 w300 h34", O2omLang.Get("btn_snooze"))
        btnSnooze.SetFont("s9 Bold", O2omStyles.FONT_PRIMARY)
        btnSnooze.OnEvent("Click", (*) => appInstance.SnoozeTimer())
        btnSnooze.Visible := false
        appInstance.btnSnooze := btnSnooze
        controlsList.Push(btnSnooze)

        ; Auto-start Checkbox (At y306)
        isStartup := O2omStartup.IsEnabled()
        chkStart := g.AddCheckbox("x43 y306 w300 h24 c" O2omStyles.COLOR_TEXT " " (isStartup ? "Checked" : ""), O2omLang.Get("chk_startup"))
        chkStart.SetFont("s9", O2omStyles.FONT_PRIMARY)
        chkStart.OnEvent("Click", (ctrl, *) => O2omStartup.SetEnabled(ctrl.Value))
        appInstance.startupCheck := chkStart
        controlsList.Push(chkStart)
    }
}
