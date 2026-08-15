# O2om Project Rules & Invariants

These rules apply to all work within the `O2om` repository:

## 1. Localization & RTL Architecture
- Arabic (`ar`) is the default language.
- The main GUI MUST apply `+E0x400000` (`WS_EX_LAYOUTRTL`) when in Arabic mode to guarantee native right-to-left control mirroring and text alignment.

## 2. GUI Redraw, Coordinates & Cursor Management
- Every AutoHotkey `Gui` instance MUST include `+0x02000000` (`WS_CLIPCHILDREN`) in its options string to eliminate text control redraw flickering during 1-second timer updates.
- Never place two controls (such as a Progress bar separator and a Text label) at the exact same Y position. Overlapping controls cause GDI mouse cursor flickering and repaint churn.
- Whenever toggling control visibilities in dynamic layouts, call `WinRedraw("ahk_id " gui.Hwnd)` to prevent Windows GDI background ghosting artifacts.
- When opening or restoring the GUI, call `try DllCall("SetCursor", "Ptr", DllCall("LoadCursor", "Ptr", 0, "Int", 32512, "Ptr"))` to immediately release Windows `IDC_APPSTARTING` loading cursor spinners.
- Wrap all control property updates (`.Value`, `.Text`) inside `try` blocks to prevent crashes during GUI destruction or rebuilding.

## 3. Standalone Asset Resolution & Binary Portability
- All visual assets (`exercises_bg.png`, `o2om.ico`) MUST be bundled via `O2omResources` using `FileInstall` directives and extracted dynamically to `%APPDATA%\O2om\assets\` when running standalone on clean machines.
- All file paths and registry keys for Windows Autostart MUST be safely quoted (`'"' A_ScriptFullPath '"'`).

## 4. State Engine & Escalation Invariants
- Physical inactivity polling (`A_TimeIdlePhysical`) MUST strictly apply to active work sessions only. Break sessions must countdown without pausing when the user steps away to stretch.
- Unacknowledged break prompts MUST escalate through two warnings (`toast_break_stage1` at `00:00`, `toast_break_stage2` at `+escalationMin`).
- If both warnings are ignored and the device remains in active use (`A_TimeIdlePhysical < idleThresholdMs`), the engine MUST dispatch `toast_break_stage3` and automatically restart a full work countdown (`ResetToWork()`).

## 5. Exercise Guidance Overlay
- The exercise screen uses `assets/exercises_bg.png` (`o2om-exercises.png`) as a clean, text-free 16:9 illustration. Do NOT add overlaid text controls on top of the image.
- When an exercise break finishes (`00:00`), the fullscreen exercise window MUST be completely destroyed (`breakGui.Destroy()`), and the main window MUST open in `isWaitingWork` state displaying a manual **"Start Work"** button.

## 6. Input Controls & Input Validation
- `AddDropDownList` MUST include an explicit rows parameter (e.g. `r2` or `r5`) to render dropdown options properly without collapsing.
- All user-entered numeric settings MUST pass through `SafeInt()` bounds validation before saving to INI.
