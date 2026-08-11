# O2om (قُوم) — Stand-Up & Physical Health Reminder

> **v0.6.1 (Release 1)** — A lightweight, customizable stand-up and physical health reminder utility for Windows built with AutoHotkey v2.

---

## Overview

**O2om** (derived from the Arabic word **قُوم**, meaning *"Stand up!"*) helps remote workers, software engineers, and computer users maintain physical health by prompting periodic movement, standing breaks, and stretching.

It runs quietly in the system tray, monitors physical input (keyboard/mouse) to auto-pause when you step away, handles system sleep/wake cycles gracefully, and escalates reminders in stages.

---

## Features in Release 1 (v0.6.1)

- **Smart Countdown Timer**: Default 40-minute work interval counting down to your next break.
- **Idle & Sleep Awareness**: Automatically pauses when you leave your PC and handles sleep/hibernate without firing stale notifications.
- **3-Stage Escalation System**:
  1. *First Warning*: Friendly reminder with chime to stand up and stretch.
  2. *Final Warning*: Follow-up alert if you missed the first reminder.
  3. *Auto-Reset*: Final audio alert before resetting the timer automatically.
- **Snooze & Reset**: Postpone your break by 5 minutes or reset the timer manually at any time.
- **Windows Auto-Start**: Easily toggle starting O2om automatically with Windows.
- **Sleek Dark GUI**: Modern Segoe UI interface with Dashboard and Settings tabs.
- **System Tray Integration**: Dynamic tray icon tooltip showing time remaining and a context menu for quick control.

---

## How to Run & Use O2om

### Option 1: Running the Pre-compiled Executable (`O2om.exe`)
1. Download or locate `O2om.exe`.
2. Double-click `O2om.exe` to launch.
3. The app starts minimized in your **System Tray** (near the Windows clock).
4. **Left-click** or right-click the tray icon and select **Show Dashboard** to open the main window.

### Option 2: Running from Source (`O2om.ahk`)
#### Prerequisites
- Windows OS
- [AutoHotkey v2.0+](https://www.autohotkey.com/) installed on your machine.

#### Running the Script
1. Install AutoHotkey v2 if you haven't already.
2. Double-click `O2om.ahk` or right-click `O2om.ahk` and select **Run Script**.

---

## Customization & Settings

O2om allows full customization through the GUI or directly via the `o2om_config.ini` file.

### Via the GUI (Recommended)
1. Open O2om Dashboard from the System Tray.
2. Click on the **Settings** tab.
3. Adjust the intervals:
   - **Work Interval (min)**: Duration between break reminders (default: `40`).
   - **Warning Interval (min)**: Gap between escalation alerts (default: `2`).
   - **Snooze Duration (min)**: Duration when hitting Snooze (default: `5`).
   - **Idle Threshold (min)**: Inactivity duration before auto-pausing (default: `5`).
4. Click **Save Settings**.

### Via `o2om_config.ini` File
When O2om runs, it automatically creates an `o2om_config.ini` file in the same directory:

```ini
[Timer]
WorkInterval=40
EscalationInterval=2
SnoozeDuration=5
IdleThreshold=5
```
You can edit these numbers with any text editor (like Notepad) while O2om is closed.

---

## How to Compile to `.exe`

Compiling `O2om.ahk` into a standalone `.exe` allows you to share the application with anyone—even if they don't have AutoHotkey installed!

### Step 1: Download the AutoHotkey Compiler (Ahk2Exe)
1. Open the [Official AutoHotkey Compiler Repository](https://github.com/AutoHotkey/Ahk2Exe) or install it via the AutoHotkey Dash:
   - Press `Win Key`, type **AutoHotkey Dash**, and open it.
   - Click on **Compile**. If Ahk2Exe is not installed, it will prompt you to install it automatically.
2. Alternatively, download the latest zip release directly from [GitHub Ahk2Exe Releases](https://github.com/AutoHotkey/Ahk2Exe/releases).

### Step 2: Compiling O2om
#### GUI Method:
1. Launch **Ahk2Exe**.
2. Set **Source (script file)** to `O2om.ahk`.
3. Set **Destination (.exe file)** to `O2om.exe`.
4. Set **Custom Icon (.ico file)** to `assets\o2om.ico`.
5. Base File / Executable: Choose `AutoHotkey64.exe` (v2.0+).
6. Click **Convert**.

#### Command Line Method:
If Ahk2Exe is added to your PATH or run directly:
```cmd
Ahk2Exe.exe /in "O2om.ahk" /out "O2om.exe" /icon "assets\o2om.ico" /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
```

> [!NOTE]
> `O2om.ahk` includes built-in Ahk2Exe compiler directives at the top of the file:
> ```ahk
> ;@Ahk2Exe-SetDescription O2om - Stand Up & Physical Health Reminder
> ;@Ahk2Exe-SetVersion 0.6.1
> ;@Ahk2Exe-SetName O2om
> ;@Ahk2Exe-SetMainIcon assets\o2om.ico
> ```
> Ahk2Exe reads these metadata directives automatically during compilation.

---

## Project Structure

```text
O2om/
├── O2om.ahk          # Main AutoHotkey v2 source script
├── O2om.exe          # Pre-compiled standalone executable
├── o2om_config.ini   # Generated configuration settings file
├── assets/
│   └── o2om.ico      # App & System Tray icon
└── README.md         # Documentation
```

---

## License & Copyright

Copyright (c) 2026 O2om Team. Free to use, modify, and distribute for personal wellness.
