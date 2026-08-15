# O2om (قُوم) — Workflows & Runtime State Sequences

This document outlines the state machine transitions, background tick lifecycle, break decision branches, and configuration update workflows for **O2om**.

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

    BreakPrompt -->|No Action & Escalation Timer Exceeded| EscalationWarning[Toast Escalation Stage 1 / 2]
    EscalationWarning --> BreakPrompt

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
        App->>Toast: Dispatch "Break Time" Notification
    else Break Prompt Ignored (now - breakWaitStart >= escalationMs)
        Engine-->>App: { type: "escalation", stage: N }
        App->>Toast: Dispatch Warning Notification
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

### B. Break Trigger & Escalation Workflow
1. When work timer reaches `00:00`, the engine transitions into `isWaitingBreak`.
2. The main window pops to the front, displaying three prominent choices:
   - **Start Break (Tray Only)**: Starts countdown quietly in tray without blocking the display.
   - **Start Exercises (Fullscreen)**: Opens a dedicated 16:9 illustration displaying posture exercises.
   - **Snooze**: Postpones the break for `snoozeMin` minutes.
3. If the prompt is ignored, the engine checks `now - breakWaitStart >= escalationMs` and dispatches escalating warnings (`stage 1` and `stage 2`).

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
