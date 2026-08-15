; ---------------------------------------------------------------------------
; O2om — Asset & Resource Manager with Standalone Binary Extraction
; ---------------------------------------------------------------------------

class O2omResources {
    static resourceDir := ""
    static exerciseImg := ""
    static iconPath    := ""

    static Init() {
        ; Candidate locations for local asset folders:
        ; 1. Script root (normal execution)
        ; 2. Parent directory (tests/ or sub-tools)
        ; 3. Current working directory
        candidates := [
            A_ScriptDir "\assets",
            A_ScriptDir "\..\assets",
            A_WorkingDir "\assets"
        ]

        for candidate in candidates {
            img := candidate "\exercises_bg.png"
            ico := candidate "\o2om.ico"
            if (FileExist(img) && FileExist(ico)) {
                this.resourceDir := candidate
                this.exerciseImg := img
                this.iconPath    := ico
                return
            }
        }

        ; 2. Target AppData directory for standalone compiled executable extraction
        appDataAssets := A_AppData "\O2om\assets"
        try DirCreate(appDataAssets)

        this.exerciseImg := appDataAssets "\exercises_bg.png"
        this.iconPath    := appDataAssets "\o2om.ico"

        ; Extract embedded assets via FileInstall if compiled or missing
        try {
            if (!FileExist(this.exerciseImg)) {
                FileInstall("assets\exercises_bg.png", this.exerciseImg, 1)
            }
        }
        try {
            if (!FileExist(this.iconPath)) {
                FileInstall("assets\o2om.ico", this.iconPath, 1)
            }
        }

        ; 3. Fallbacks to any discoverable candidate
        for candidate in candidates {
            if (!FileExist(this.exerciseImg) && FileExist(candidate "\exercises_bg.png"))
                this.exerciseImg := candidate "\exercises_bg.png"
            if (!FileExist(this.iconPath) && FileExist(candidate "\o2om.ico"))
                this.iconPath := candidate "\o2om.ico"
        }
    }

    static GetExerciseImage() {
        return FileExist(this.exerciseImg) ? this.exerciseImg : ""
    }

    static GetIcon() {
        return FileExist(this.iconPath) ? this.iconPath : ""
    }
}
