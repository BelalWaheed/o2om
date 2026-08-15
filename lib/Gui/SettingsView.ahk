; ---------------------------------------------------------------------------
; O2om — Settings GUI View
; ---------------------------------------------------------------------------

class O2omSettingsView {
    static Build(g, appInstance, controlsList) {
        s := appInstance.settings

        ; Language Dropdown (r2 ensures dropdown items render properly)
        lblLang := g.AddText("x25 y58 w220 h24 c" O2omStyles.COLOR_TEXT, O2omLang.Get("lbl_language"))
        lblLang.SetFont("s10", O2omStyles.FONT_PRIMARY)
        controlsList.Push(lblLang)

        langs := ["العربية", "English"]
        appInstance.ddlLanguage := g.AddDropDownList("x260 y56 w100 r2 Choose" (s.language == "ar" ? 1 : 2), langs)
        controlsList.Push(appInstance.ddlLanguage)

        ; Work Interval
        lblWork := g.AddText("x25 y95 w220 h24 c" O2omStyles.COLOR_TEXT, O2omLang.Get("lbl_work_min"))
        lblWork.SetFont("s10", O2omStyles.FONT_PRIMARY)
        controlsList.Push(lblWork)

        appInstance.editWork := g.AddEdit("x260 y93 w100 h24 Number Center Background" O2omStyles.COLOR_CARD " c" O2omStyles.COLOR_TEXT, s.workIntervalMin)
        appInstance.editWork.SetFont("s10", O2omStyles.FONT_PRIMARY)
        controlsList.Push(appInstance.editWork)

        ; Short Break
        lblShort := g.AddText("x25 y132 w220 h24 c" O2omStyles.COLOR_TEXT, O2omLang.Get("lbl_short_break_min"))
        lblShort.SetFont("s10", O2omStyles.FONT_PRIMARY)
        controlsList.Push(lblShort)

        appInstance.editShortBreak := g.AddEdit("x260 y130 w100 h24 Number Center Background" O2omStyles.COLOR_CARD " c" O2omStyles.COLOR_TEXT, s.shortBreakMin)
        appInstance.editShortBreak.SetFont("s10", O2omStyles.FONT_PRIMARY)
        controlsList.Push(appInstance.editShortBreak)

        ; Long Break
        lblLong := g.AddText("x25 y169 w220 h24 c" O2omStyles.COLOR_TEXT, O2omLang.Get("lbl_long_break_min"))
        lblLong.SetFont("s10", O2omStyles.FONT_PRIMARY)
        controlsList.Push(lblLong)

        appInstance.editLongBreak := g.AddEdit("x260 y167 w100 h24 Number Center Background" O2omStyles.COLOR_CARD " c" O2omStyles.COLOR_TEXT, s.longBreakMin)
        appInstance.editLongBreak.SetFont("s10", O2omStyles.FONT_PRIMARY)
        controlsList.Push(appInstance.editLongBreak)

        ; Escalation / Warning
        lblEsc := g.AddText("x25 y206 w220 h24 c" O2omStyles.COLOR_TEXT, O2omLang.Get("lbl_escalation_min"))
        lblEsc.SetFont("s10", O2omStyles.FONT_PRIMARY)
        controlsList.Push(lblEsc)

        appInstance.editEscalation := g.AddEdit("x260 y204 w100 h24 Number Center Background" O2omStyles.COLOR_CARD " c" O2omStyles.COLOR_TEXT, s.escalationMin)
        appInstance.editEscalation.SetFont("s10", O2omStyles.FONT_PRIMARY)
        controlsList.Push(appInstance.editEscalation)

        ; Snooze
        lblSnooze := g.AddText("x25 y243 w220 h24 c" O2omStyles.COLOR_TEXT, O2omLang.Get("lbl_snooze_min"))
        lblSnooze.SetFont("s10", O2omStyles.FONT_PRIMARY)
        controlsList.Push(lblSnooze)

        appInstance.editSnooze := g.AddEdit("x260 y241 w100 h24 Number Center Background" O2omStyles.COLOR_CARD " c" O2omStyles.COLOR_TEXT, s.snoozeMin)
        appInstance.editSnooze.SetFont("s10", O2omStyles.FONT_PRIMARY)
        controlsList.Push(appInstance.editSnooze)

        ; Idle
        lblIdle := g.AddText("x25 y280 w220 h24 c" O2omStyles.COLOR_TEXT, O2omLang.Get("lbl_idle_min"))
        lblIdle.SetFont("s10", O2omStyles.FONT_PRIMARY)
        controlsList.Push(lblIdle)

        appInstance.editIdle := g.AddEdit("x260 y278 w100 h24 Number Center Background" O2omStyles.COLOR_CARD " c" O2omStyles.COLOR_TEXT, s.idleThresholdMin)
        appInstance.editIdle.SetFont("s10", O2omStyles.FONT_PRIMARY)
        controlsList.Push(appInstance.editIdle)

        ; Save Button
        btnSave := g.AddButton("x20 y315 w345 h30", O2omLang.Get("btn_save"))
        btnSave.SetFont("s9 Bold", O2omStyles.FONT_PRIMARY)
        btnSave.OnEvent("Click", (*) => appInstance.ApplySettingsFromGui())
        controlsList.Push(btnSave)
    }
}
