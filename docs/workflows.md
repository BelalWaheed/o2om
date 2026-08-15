# O2om (قُوم) — Workflows & Runtime State Sequences

This document outlines the state machine transitions, background tick lifecycle, break decision branches, escalation warnings, and auto-reset workflows for **O2om**.

---

## 1. Complete Application State Machine

```mermaid
flowchart TD
    Launch([App Initialization]) --> Work[Active Work Session]

    %% Work state actions
    Work -->|Click Pause| Paused[Paused State]
    Paused -->|Click Resume| Work
    Work -->|Physical Inactivity > IdleThreshold| Idle[Idle State - Auto Paused]
    Idle -->|Physical Input Detected| Work

    %% Break trigger
    Work -->|Countdown Reaches 00:00| BreakPrompt{Break Prompt State}

    %% Break branches
    BreakPrompt -->|Click Snooze| SnoozeDelay[Snooze Countdown]
    SnoozeDelay -->|Snooze Hits 00:00| BreakPrompt

    BreakPrompt -->|Ignored 1st Warning Interval| Warning1[Toast Warning 1: Break Time Passed]
    Warning1 --> BreakPrompt

    BreakPrompt -->|Ignored 2nd Warning & Device in Use| AutoReset[Toast Final: Auto-Reset Work Timer]
    AutoReset --> Work

    BreakPrompt -->|Click Start Break| TrayBreak[Break Active - Tray Only]
    BreakPrompt -->|Click Start Exercises| ExerciseBreak[Break Active - 16:9 Fullscreen Guide]

    %% Break completion
    TrayBreak -->|Break Countdown Hits 00:00| WaitingWork[Waiting Work State]
    ExerciseBreak -->|Break Countdown Hits 00:00 / ESC / Start Work| WaitingWork

    %% Returning to work
    WaitingWork -->|Click 'Start Work' Button| Work
```

---

## 2. 1-Second Timer Tick Sequence Diagram

The central `SetTimer(ObjBindMethod(this, "Tick"), 1000)` loop evaluates hardware inputs, delta time, and state transitions every 1,000 milliseconds:

```mermaid
sequenceDiagram
    autonumber
    participant System as Windows System Timer
    participant App as O2omApp (Controller)
    participant Engine as O2omEngine (State Machine)
    participant Hardware as Input Hardware (A_TimeIdlePhysical)
    participant GUI as Dashboard & Break GUI
    participant Toast as Windows Notification Center

    System->>App: Tick() [Every 1000ms]
    App->>Engine: Tick()
    Engine->>Hardware: Read A_TimeIdlePhysical
    Hardware-->>Engine: Idle milliseconds

    alt System Sleep / Hibernate (delta > 5000ms)
        Engine-->>App: { type: "normal" }
    else User Inactive (idle >= idleThresholdMs)
        Engine-->>App: { type: "idle" }
    else Countdown Reaches 00:00 (Work ended)
        Engine-->>App: { type: "waiting_break" }
        App->>GUI: Switch to Dashboard & Display Break Buttons
        App->>Toast: Dispatch Initial "Break Time" Notification
    else Ignored Warning 1 (delta >= escalationMs, stage 1)
        Engine-->>App: { type: "escalation", stage: 1 }
        App->>Toast: Dispatch Warning 1 Toast
    else Ignored Warning 2 & Device in Use (stage >= 2, idle < idleThresholdMs)
        Engine-->>App: { type: "auto_work_reset", stage: 2 }
        App->>Toast: Dispatch "Final Warning: Auto-Reset" Notification
        App->>GUI: Reset Dashboard to Normal Work Mode
    else Break Reaches 00:00 (Break ended)
        Engine-->>App: { type: "break_ended" }
        App->>GUI: Destroy breakGui & Show "Start Work" Button
        App->>Toast: Dispatch "Break Ended" Notification
    else Standard Countdown
        Engine-->>App: { type: "normal" }
    end

    App->>GUI: UpdateDisplay() [Refresh time string & status]
```

---

## 3. Detailed Workflow Descriptions

### A. Active Work Session & Idle Recovery
1. When launched, `O2omEngine` starts in a working session with `remaining = workIntervalMin * 60 * 1000`.
2. Every tick, delta time is deducted from `remaining`.
3. If the user stops interacting with mouse and keyboard, `A_TimeIdlePhysical` begins incrementing.
4. Once `idle >= idleThresholdMs`, the engine enters `isIdle` mode, suspending countdown deduction.
5. As soon as the user returns (hardware input detected, `idle < idleThresholdMs`), the engine resets to a fresh work interval.

### B. Break Trigger & Escalation Workflow (Two Warnings + Auto-Reset)
1. When work timer reaches `00:00`, the engine transitions into `isWaitingBreak`.
2. The main window pops to the front, and the initial break notification is dispatched (`toast_break_stage1`).
3. If no action is taken after `escalationMs` (e.g. 2 minutes), Warning 1 is dispatched (`toast_break_stage2`).
4. If still ignored after a second `escalationMs` interval:
   - If the user is actively using the computer (`idle < idleThresholdMs`), the final notification (`toast_break_stage3`) is dispatched and the engine **automatically starts a new work countdown**.
   - If the user stepped away from the desk (`idle >= idleThresholdMs`), the engine transitions cleanly to idle mode.

### C. Post-Break Workflow (Clean Resumption)
1. When the break countdown expires (`00:00`), the fullscreen exercise overlay is completely destroyed (`breakGui.Destroy()`).
2. The engine transitions into `isWaitingWork` state and resets `remaining = workIntervalMin * 60 * 1000`.
3. The main dashboard appears with a prominent **"Start Work"** button.
4. The timer does **not** count down until the user explicitly clicks **"Start Work"**, ensuring the user is truly seated and ready.

---

## 4. Settings Update & Language Switch Workflow

```mermaid
sequenceDiagram
    autonumber
    participant User as User
    participant View as O2omSettingsView
    participant App as O2omApp
    participant Settings as O2omSettings
    participant Lang as O2omLang
    participant INI as o2om_config.ini

    User->>View: Edit Values & Language -> Click "Save Settings"
    View->>App: ApplySettingsFromGui()
    App->>Settings: Update values in memory
    App->>Lang: Update currentLang ("ar" | "en")
    App->>Settings: Save()
    Settings->>INI: IniWrite key-value pairs
    App->>App: SetupGui() [Re-create GUI with RTL / LTR flags]
    App->>App: ShowGui()
```
