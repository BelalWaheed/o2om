; ---------------------------------------------------------------------------
; O2om — System Tray Menu & Icon Management
; ---------------------------------------------------------------------------

class O2omTray {
    static Setup(appInstance) {
        iconPath := A_ScriptDir "\assets\o2om.ico"
        if FileExist(iconPath)
            TraySetIcon(iconPath)

        tray := A_TrayMenu
        tray.Delete()

        tray.Add(O2omLang.Get("tray_show"), (*) => appInstance.ShowGui())
        tray.Add()
        tray.Add(O2omLang.Get("tray_reset"), (*) => appInstance.ResetTimer())
        tray.Add(O2omLang.Get("tray_quit"), (*) => ExitApp())

        ; "1&" explicitly binds double-click to item 1 (Show Dashboard)
        tray.Default := "1&"
    }

    static UpdateTooltip(timeStr) {
        A_IconTip := O2omLang.Get("app_title") " — " timeStr
    }
}
