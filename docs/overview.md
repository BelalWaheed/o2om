# O2om (قُوم) — Overview & Product Vision

**O2om** (derived from the Arabic imperative **قُوم**, meaning *"Stand up!"*) is a lightweight, open-source desktop health and ergonomics utility for Windows built in **AutoHotkey v2.0+**. It is designed to mitigate sedentary fatigue, reduce musculoskeletal strain, and prevent screen-induced eye fatigue for engineers, remote professionals, gamers, and long-session desk workers.

---

## 1. Core Problem & Product Value

Prolonged seated computer use leads to reduced blood circulation, postural degradation (slumped shoulders, forward neck tilt), and digital eye fatigue. Most desktop break timers suffer from three common issues:
1. **Intrusive disruption**: Locking the desktop aggressively during critical workflows.
2. **Resource bloat**: Consuming hundreds of megabytes of RAM via heavy web runtimes (Electron/Webview).
3. **Lack of actionable guidance**: Notifying users to "take a break" without visual exercise instruction.

**O2om** resolves these problems by providing:
- A non-intrusive, native Windows utility consuming < 15MB RAM.
- Integrated 16:9 full-screen posture stretch and eye relaxation illustrations.
- Automatic physical idle detection (`A_TimeIdlePhysical`) that pauses timers when stepping away from the desk.
- Native Arabic (Right-to-Left) and English dual-language architecture.

---

## 2. Key Features

- **Automated Work Countdown**: Automatically begins a work session upon launch and after completing break sessions.
- **Physical Inactivity Detection**: Senses user absence via physical input hardware polling (`A_TimeIdlePhysical`) and automatically suspends countdown.
- **Flexible Break Controls**:
  - *Start Break (Tray Only)*: Minimalist quiet break running in the background/tray.
  - *Start Exercises (Fullscreen)*: Displays clean 16:9 posture stretch exercises.
  - *Snooze*: Postpones the break for a configurable delay (default: 5 minutes).
  - *Pause / Resume*: Manually freezes the session at any time.
- **Escalation Notification System**: Escalates break reminders at configurable intervals if a break prompt remains unattended.
- **Post-Break Workflow Control**: Closes exercise overlays cleanly at `00:00` and displays a manual **"Start Work"** button to guarantee users are ready before the next work interval begins.
- **Native Dual Localization**: Arabic (`ar`) with native Right-To-Left layout mirroring (`WS_EX_LAYOUTRTL`), plus English (`en`).
- **Windows Integration**: Native toast notifications with AppUserModelID (`O2om.StandUpReminder`) and optional startup registry integration.

---

## 3. Technology Stack & Runtime Specifications

| Attribute | Specification |
| :--- | :--- |
| **Language / Framework** | AutoHotkey v2.0+ (Strict v2 syntax) |
| **Target OS** | Windows 10 / Windows 11 (64-bit) |
| **Architecture Pattern** | Decoupled State Engine + Modular View Controller |
| **Styling Tokens** | Catppuccin Mocha Dark Palette |
| **Configuration Storage** | INI File (`o2om_config.ini`) |
| **Binary Distribution** | Standalone Compiled Executable (`O2om.exe` via Ahk2Exe) |
| **Default Language** | Arabic (`ar`) with native `+E0x400000` RTL layout |

---

## 4. Repository & File Structure

```text
O2om/
├── O2om.ahk                  # Application Entry Point & Orchestrator (O2omApp)
├── O2om.exe                  # Standalone Compiled 64-Bit Executable
├── o2om_config.ini           # Persistent User Configuration INI File
├── README.md                 # Project README and Quick Start
├── llms.txt                  # Machine-readable AI Agent Summary
├── assets/                   # Graphical & Binary Assets
│   ├── o2om.ico              # Main Application & System Tray Icon
│   └── exercises_bg.png      # 16:9 Posture Stretch Graphic Guide
├── docs/                     # Living Technical Documentation
│   ├── overview.md           # Product vision, features, and tech specs
│   ├── architecture.md       # Layered architecture, state machine, invariants
│   ├── workflows.md          # State workflows and sequence diagrams
│   └── adr/                  # Architecture Decision Records
│       └── 0001-autohotkey-v2-architecture.md
├── lib/                      # Core Domain & Infrastructure Libraries
│   ├── Resources.ahk         # Asset Bundling & Dynamic Extractor (O2omResources)
│   ├── TimerEngine.ahk       # Non-blocking Countdown & Pomodoro State Engine
│   ├── Settings.ahk          # INI Settings Manager (O2omSettings)
│   ├── Language.ahk          # Dual-language Localization Dictionary (O2omLang)
│   ├── Styles.ahk            # Theme Colors & UI Design Tokens (O2omStyles)
│   ├── Notifications.ahk     # Windows Toast & Action Center Dispatcher (O2omNotify)
│   ├── Startup.ahk           # Windows Startup Registry Manager (O2omStartup)
│   ├── Tray.ahk              # System Tray Menu & Tooltip Manager (O2omTray)
│   └── Gui/                  # Presentation Layer
│       ├── Dashboard.ahk     # Main Timer & Action Controls View (O2omDashboardView)
│       └── SettingsView.ahk  # User Configuration Form View (O2omSettingsView)
├── tests/                    # Automated Unit Testing Suite
│   └── TimerEngineTest.ahk   # State Engine & Resource Assertion Suite
└── .agents/                  # AI Agent Context & Reusable Engineering Skills
    ├── AGENTS.md             # Repository Invariants & Layout Safeguards
    └── skills/
        └── autohotkey-v2-gui-patterns/SKILL.md
```
