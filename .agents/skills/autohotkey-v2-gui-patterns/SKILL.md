---
name: autohotkey-v2-gui-patterns
description: Conventions and patterns for building robust, flicker-free, localized AutoHotkey v2 desktop GUI applications.
---

# AutoHotkey v2 GUI Engineering Patterns

## 1. Eliminating Redraw Flicker (`WS_CLIPCHILDREN`)
When updating text controls periodically (e.g. every second in a timer tick), Windows erases the parent window background under child controls, causing noticeable screen flickering.
- **Fix**: Pass `+0x02000000` (`WS_CLIPCHILDREN`) in the Gui constructor options:
  ```autohotkey
  g := Gui("+MinimizeBox -MaximizeBox +0x02000000", "App Title")
  ```

## 2. Preventing Visibility Ghosting (`WinRedraw`)
Toggling control visibility (`ctrl.Visible := false`) on overlapping or stacked controls in Windows GDI / RTL mode leaves painted background artifacts ("ghosting").
- **Fix**: Immediately call `WinRedraw` after modifying control visibilities:
  ```autohotkey
  ctrl.Visible := false
  if (gui && gui.Hwnd)
      try WinRedraw("ahk_id " gui.Hwnd)
  ```

## 3. Exception Guarding on Control Property Updates
Accessing `.Value` or `.Text` on destroyed control references throws unrecoverable runtime errors (`The control is destroyed`).
- **Fix**: Wrap control property updates in `try` blocks whenever a background timer updates UI elements during GUI reconstruction:
  ```autohotkey
  try countdownText.Value := timeStr
  try statusText.Value := statusVal
  ```

## 4. Native RTL (Right-to-Left) Layout
For Arabic or Hebrew GUI applications:
- **Fix**: Append `+E0x400000` (`WS_EX_LAYOUTRTL`) to the GUI options:
  ```autohotkey
  if (isRTL)
      guiOpts .= " +E0x400000"
  ```
  Windows automatically mirrors control positioning, title bar, checkboxes, and text flow natively.

## 5. DropDownList Popup Height (`rN`)
`AddDropDownList` without an explicit row parameter collapses the popup menu list.
- **Fix**: Always specify `r2` or `r5`:
  ```autohotkey
  ddl := g.AddDropDownList("x260 y56 w100 r2 Choose1", ["العربية", "English"])
  ```
