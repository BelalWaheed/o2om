#Requires AutoHotkey v2.0
#SingleInstance Force

OnError(TestErrorHandler)

TestErrorHandler(thrown, mode) {
    FileAppend(Format("FATAL TEST ERROR in {1} (Line {2}): {3}`n", thrown.File, thrown.Line, thrown.Message), A_ScriptDir "\test_results.txt", "UTF-8")
    ExitApp(1)
}

#Include ../lib/Styles.ahk
#Include ../lib/Language.ahk
#Include ../lib/Startup.ahk
#Include ../lib/Notifications.ahk
#Include ../lib/Settings.ahk
#Include ../lib/TimerEngine.ahk
#Include ../lib/Resources.ahk

class Assert {
    static passCount := 0
    static failCount := 0
    static logFile   := A_ScriptDir "\test_results.txt"

    static Init() {
        try FileDelete(this.logFile)
    }

    static Equal(expected, actual, testName := "Test") {
        if (expected == actual) {
            this.passCount++
            FileAppend(Format("[PASS] {1}`n", testName), this.logFile, "UTF-8")
        } else {
            this.failCount++
            FileAppend(Format("[FAIL] {1}: Expected '{2}', got '{3}'`n", testName, expected, actual), this.logFile, "UTF-8")
        }
    }

    static True(condition, testName := "Test") {
        this.Equal(true, !!condition, testName)
    }

    static Summary() {
        resText := Format("`n====================================`nTest Results: {1} Passed, {2} Failed`n====================================`n", this.passCount, this.failCount)
        FileAppend(resText, this.logFile, "UTF-8")
        ExitApp(this.failCount > 0 ? 1 : 0)
    }
}

RunTests() {
    Assert.Init()
    FileAppend("Running O2om Unit Tests...`n`n", Assert.logFile, "UTF-8")

    ; 1. Settings Mock & Default Values
    s := O2omSettings()
    s.workIntervalMin   := 40
    s.shortBreakMin     := 5
    s.longBreakMin      := 15
    s.snoozeMin         := 5
    s.idleThresholdMin  := 5
    s.cyclesBeforeLong  := 4
    s.startWithWindows  := 1

    engine := O2omEngine(s)

    ; Test 1: Initial State
    Assert.Equal(40 * 60 * 1000, engine.remaining, "Initial remaining matches work interval (40 min)")
    Assert.True(!engine.isPaused, "Engine is not paused by default")
    Assert.True(!engine.isOnBreak, "Engine is not on break by default")
    Assert.True(!engine.isWaitingBreak, "Engine is not waiting for break by default")
    Assert.True(!engine.isWaitingWork, "Engine is not waiting for work by default")

    ; Test 2: Pause and Resume
    isPaused := engine.TogglePause()
    Assert.True(isPaused, "TogglePause pauses the engine")
    Assert.True(engine.isPaused, "engine.isPaused is true")
    isPaused := engine.TogglePause()
    Assert.True(!isPaused, "TogglePause resumes the engine")

    ; Test 3: Short Break Calculation
    engine.StartBreak()
    Assert.True(engine.isOnBreak, "StartBreak activates isOnBreak")
    Assert.Equal(5 * 60 * 1000, engine.remaining, "First break is a Short Break (5 min)")
    Assert.Equal(1, engine.completedCycles, "Completed cycles count incremented to 1")

    ; Test 4: Long Break Trigger after cyclesBeforeLong (4 cycles)
    engine.StartBreak() ; cycle 2
    engine.StartBreak() ; cycle 3
    engine.StartBreak() ; cycle 4
    Assert.Equal(15 * 60 * 1000, engine.remaining, "4th break is a Long Break (15 min)")
    Assert.Equal(4, engine.completedCycles, "Completed cycles equals 4")

    ; Test 5: Snooze
    engine.Snooze()
    Assert.True(!engine.isOnBreak, "Snooze deactivates break mode")
    Assert.Equal(5 * 60 * 1000, engine.remaining, "Snooze sets remaining to snooze duration (5 min)")

    ; Test 6: Reset to Work
    engine.ResetToWork()
    Assert.Equal(40 * 60 * 1000, engine.remaining, "ResetToWork resets remaining to work duration (40 min)")
    Assert.True(!engine.isOnBreak, "ResetToWork clears isOnBreak")
    Assert.True(!engine.isIdle, "ResetToWork clears isIdle")

    ; Test 7: StartWork Mode
    engine.isWaitingWork := true
    engine.StartWork()
    Assert.True(!engine.isWaitingWork, "StartWork clears isWaitingWork flag")

    ; Test 8: Resource Manager Initialization
    O2omResources.Init()
    Assert.True(O2omResources.GetIcon() != "", "O2omResources resolves icon path")
    Assert.True(O2omResources.GetExerciseImage() != "", "O2omResources resolves exercise illustration path")

    ; Test 9: Safe Integer Parsing
    Assert.True(IsInteger("40"), "IsInteger parses valid string integer")
    Assert.True(!IsInteger(""), "IsInteger rejects empty string")
    Assert.True(!IsInteger("abc"), "IsInteger rejects alphanumeric string")

    ; Test 10: Settings Path Discovery
    cfgPath := O2omSettings.GetConfigFilePath()
    Assert.True(cfgPath != "", "Settings path resolved successfully")

    ; Test 11: Localization Dictionary
    O2omLang.currentLang := "ar"
    Assert.Equal("قُوم — O2om", O2omLang.Get("app_title"), "Arabic app_title translation loaded")
    O2omLang.currentLang := "en"
    Assert.Equal("O2om — Stand-Up Reminder", O2omLang.Get("app_title"), "English app_title translation loaded")
    O2omLang.currentLang := "ar" ; restore default

    Assert.Summary()
}

RunTests()
