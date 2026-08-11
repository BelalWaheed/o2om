; ---------------------------------------------------------------------------
; O2om — Windows Startup Registry Manager
; ---------------------------------------------------------------------------

class O2omStartup {
    static REG_KEY   := "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
    static REG_VALUE := "O2om"

    static IsEnabled() {
        try return (RegRead(this.REG_KEY, this.REG_VALUE) != "")
        catch
            return false
    }

    static SetEnabled(enable) {
        if (enable) {
            exePath := A_IsCompiled ? A_ScriptFullPath : ('"' A_AhkPath '" "' A_ScriptFullPath '"')
            RegWrite(exePath, "REG_SZ", this.REG_KEY, this.REG_VALUE)
        } else {
            try RegDelete(this.REG_KEY, this.REG_VALUE)
        }
    }

    static EnsureDefault() {
        if !this.IsEnabled() {
            this.SetEnabled(true)
        }
    }
}
