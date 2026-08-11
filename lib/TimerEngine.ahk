; ---------------------------------------------------------------------------
; O2om — Timer & Pomodoro Cycle Engine
; ---------------------------------------------------------------------------

class O2omEngine {
    static SLEEP_GAP := 5000 ; 5 seconds gap indicates system sleep/hibernate

    settings := ""

    ; State
    remaining       := 0
    lastTick        := 0
    reminderStage   := 0    ; 0 = Countdown, 1 = First Warning, 2 = Final Warning
    isIdle          := false
    isOnBreak       := false
    isWaitingBreak  := false
    isWaitingWork   := false
    isPaused        := false
    breakWaitStart  := 0
    completedCycles := 0

    __New(settingsObj) {
        this.settings := settingsObj
        this.ResetToWork()
    }

    ; Millisecond Calculations
    workMs          => this.settings.workIntervalMin * 60 * 1000
    shortBreakMs    => this.settings.shortBreakMin * 60 * 1000
    longBreakMs     => this.settings.longBreakMin * 60 * 1000
    snoozeMs        => this.settings.snoozeMin * 60 * 1000
    idleThresholdMs => this.settings.idleThresholdMin * 60 * 1000
    escalationMs    => this.settings.escalationMin * 60 * 1000

    ResetToWork() {
        this.remaining       := this.workMs
        this.reminderStage   := 0
        this.isIdle          := false
        this.isOnBreak       := false
        this.isWaitingBreak  := false
        this.isWaitingWork   := false
        this.isPaused        := false
        this.lastTick        := A_TickCount
    }

    TogglePause() {
        this.isPaused := !this.isPaused
        if (!this.isPaused)
            this.lastTick := A_TickCount
        return this.isPaused
    }

    StartWork() {
        this.isWaitingWork := false
        this.lastTick      := A_TickCount
    }

    StartBreak() {
        this.isOnBreak      := true
        this.isWaitingBreak := false
        this.reminderStage  := 0
        this.completedCycles += 1

        ; Determine if long break or short break
        if (Mod(this.completedCycles, this.settings.cyclesBeforeLong) == 0) {
            this.remaining := this.longBreakMs
        } else {
            this.remaining := this.shortBreakMs
        }
        this.lastTick := A_TickCount
    }

    Snooze() {
        this.remaining      := this.snoozeMs
        this.reminderStage  := 0
        this.isIdle         := false
        this.isWaitingBreak := false
        this.lastTick       := A_TickCount
    }

    Tick() {
        now   := A_TickCount
        delta := now - this.lastTick
        this.lastTick := now

        ; Handle 32-bit tick wraparound
        if (delta < 0)
            delta += 0x100000000

        idle := A_TimeIdlePhysical

        ; 1. Sleep/Wake gap check
        if (delta > O2omEngine.SLEEP_GAP) {
            if (idle >= this.idleThresholdMs) {
                this.ResetToWork()
            }
            return { type: "normal" }
        }

        ; 2. Idle State Handling
        if (this.isIdle) {
            if (idle < this.idleThresholdMs) {
                this.ResetToWork()
            }
            return { type: "idle" }
        }

        if (idle >= this.idleThresholdMs) {
            this.isIdle := true
            return { type: "idle" }
        }

        ; 3. Normal Countdown
        if (!this.isPaused && !this.isWaitingWork && !this.isWaitingBreak && this.remaining > 0)
            this.remaining -= delta

        if (this.isWaitingBreak) {
            if (this.breakWaitStart > 0 && (now - this.breakWaitStart) >= this.escalationMs) {
                this.reminderStage++
                this.breakWaitStart := now
                return { type: "escalation", stage: this.reminderStage }
            }
        }

        if (this.remaining <= 0 && !this.isWaitingWork) {
            if (this.isOnBreak) {
                ; Break finished, transition to waiting work state
                this.isOnBreak     := false
                this.isWaitingWork := true
                this.remaining     := this.workMs
                return { type: "break_ended" }
            } else if (!this.isWaitingBreak) {
                this.isWaitingBreak := true
                this.breakWaitStart := now
                return { type: "waiting_break" }
            }
        }

        return { type: "normal" }
    }
}
