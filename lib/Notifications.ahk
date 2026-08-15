; ---------------------------------------------------------------------------
; O2om — Windows Toast Notifications with Action Center Persistence & AUMID
; ---------------------------------------------------------------------------

class O2omNotify {
    static AUMID := "O2om.StandUpReminder"
    static APP_NAME := "O2om"

    static RegisterAUMID() {
        ; Register AppUserModelID in registry so Windows Action Center attributes toasts
        ; to "O2om" and retains them in the Notification Center panel.
        regPath := "HKCU\Software\Classes\AppUserModelId\" this.AUMID
        try {
            RegWrite(this.APP_NAME, "REG_SZ", regPath, "DisplayName")
            iconPath := O2omResources.GetIcon()
            if (iconPath != "")
                RegWrite(iconPath, "REG_SZ", regPath, "IconUri")
        }
    }

    static Show(title, message, soundType := 64) {
        ; Sound feedback
        try SoundPlay("*" soundType)

        ; Native TrayTip / Toast dispatch (0 = No Icon, removes blue info circle)
        try {
            TrayTip(message, title, 0)
        } catch {
            ; Fallback
        }
    }
}
