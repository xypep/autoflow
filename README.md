# Key Flow (autoflow)

A GUI tool for building and running Windows automation sequences with keys, mouse, text, variables and more, written in **AutoHotkey v2**.

You build a list of actions (press a key, click at a position, wait for a color, open a program, …), then run it once, several times or in an endless loop.

---

## Features

- **39 action types**: keyboard, mouse, text, clipboard, windows, processes, PowerShell, notifications
- **Variables** (`$name`) with set, add, subtract, conditional set, random, clipboard, mouse position and window title
- **Flow control** with Jump To, Repeat Key and Stop Sequence
- **Screen vision**: Wait for Color (pixel or region) and Find Image
- **Position capture** and **color picker** with magnifier
- **Macro recorder** for clicks and keystrokes
- **Run settings**: repetitions, pause between runs, random jitter, speed factor
- **Editing**: double-click to edit, drag & drop reordering, undo/redo (50 steps)
- **Profiles**: save and load sequences as `.txt`
- **Live OSD** showing the current action and repetition while running

---

## Requirements

- Windows 10 / 11
- [AutoHotkey **v2.0**](https://www.autohotkey.com/). v1.1 will **not** work.

## Getting Started

1. Install AutoHotkey v2.
2. Download or clone this repository.
3. Double-click `Auto_Flow.ahk`.

The window opens with a few example actions already in the list.

### Quick Start

1. Choose an **Action Type**.
2. Pick or type a **Value**. Many types have presets, and long lists can be searched by typing.
3. Set the **Delay (ms)**, which is the pause *after* this action.
4. Click **➕ Add**.
5. Press **F6** or **▶ START**.

---

## Hotkeys

| Key | Action | Scope |
|---|---|---|
| `F6` | Start sequence | Global |
| `F7` | Pause / resume | Global |
| `F8` | Stop | Global |
| `Shift+Space` | Capture mouse position | Global |
| `Ctrl+Z` / `Ctrl+Y` | Undo / Redo | Key Flow window only |
| `Esc` | Cancel capture, color pick, recording or row drag | While active |

> Pause and Stop take effect **after the current action** finishes. A long `Wait (ms)` or `Wait for Color` delays them.

---

## Run Settings

| Setting | Description |
|---|---|
| **Repetitions** | How many times the whole list runs. `0` = endless loop |
| **Pause between runs (ms)** | Wait time between two repetitions |
| **Jitter (±ms)** | Random offset added to every step delay |
| **Speed** | Factor applied to every step delay (the Delay column, not `Wait (ms)` actions) |

Variables are reset every time a run starts.

---

## Action Reference

Coordinates are **screen coordinates** (`x y`). Fields are separated by `|`.

### Keys

| Type | Value | Example |
|---|---|---|
| ⌨️ Press Key | Key name, plus Ctrl/Alt/Shift/Win checkboxes | `F5`, `Enter`, `a` |
| 🔗 Hotkey Combo | Preset combo | `Ctrl+S  (Save)` |

### Mouse

| Type | Value | Example |
|---|---|---|
| 🖱️ Left / Right / Double / Middle Click | `Current Position` or `x y` | `960 540` |
| 🖱️ Hold / Release Left, Hold / Release Right | none | — |
| 🖱️ Drag | `x1 y1 \| x2 y2` | `100 200 \| 400 500` |
| ➡️ Move Mouse | `x y` | `500 300` |
| 🔼 Scroll Up / 🔽 Scroll Down | Number of ticks | `3 ticks` |
| 🎨 Wait for Color | `x y \| RRGGBB` or `x y \| RRGGBB \| w h \| ANY\|AVG` | `500 300 \| FF0000 \| 5 5 \| ANY` |

**Wait for Color** waits until the color appears, **for at most 10 seconds**, then continues either way.
- `ANY`: at least one pixel in the `w × h` region matches exactly.
- `AVG`: the region's average color matches exactly.

### Text & Input

| Type | Value |
|---|---|
| 💬 Comment | Any text. Does nothing, useful for labeling sections |
| ✏️ Type Text | Text to type |
| 📋 Copy / 📋 Paste / ✂️ Cut / ↩️ Undo / 🔲 Select All | none (sends `Ctrl+C/V/X/Z/A`) |

### System

| Type | Value | Example |
|---|---|---|
| ⏳ Wait (ms) | Milliseconds | `2000 ms` |
| 🚀 Open Program | Friendly name, exe name or full path | `Notepad`, `C:\Tools\app.exe` |
| 🔊 Volume Up / 🔉 Volume Down | Steps | `2 steps` |
| 🔇 Mute Toggle, 📸 Screenshot, 🔒 Lock PC | none | — |
| 🔔 Notification | `title \| message`. The sound can be chosen in the edit dialog | `Key Flow \| Counter: $counter` |
| 📜 Run PowerShell | Command or path to a `.ps1` file (runs hidden) | `ipconfig /flushdns` |
| 🌐 Open URL | URL (`https://` is added if missing) | `www.example.com` |

### Windows & Processes

| Type | Value |
|---|---|
| ➖ Minimize / ⬜ Maximize / ❌ Close Window | `Current Window` or a process name like `notepad.exe` |
| 🔫 Kill Process | Process name or full path (force-kills via `taskkill /F`) |

### Variables

| Type | Value | Effect |
|---|---|---|
| 📊 Var: Set | `name \| value` | `name = value` |
| 📊 Var: Add | `name \| amount` | `name += amount` |
| 📊 Var: Sub | `name \| amount` | `name -= amount` |
| 📊 Var: Set If | `name \| op \| check \| newvalue` | If `name op check`, then `name = newvalue`. Operators: `== != > < >= <=` |
| 📊 Var: Random | `name \| min \| max` | Random whole number, inclusive |
| 📋 Var: From Clipboard | `name` | Stores the clipboard text |
| 🖱️ Var: Mouse Pos | `xName \| yName` | Stores the current mouse position |
| 🪟 Var: Win Title | `name` | Stores the active window's title |

`$name` reads a variable in these places:

- Var: Add / Sub (amount)
- Var: Random (min, max)
- Repeat Key (count)
- Notification (anywhere in title and message)

Other fields take their value literally.

### Flow

| Type | Value | Effect |
|---|---|---|
| 🔁 Repeat Key | `key \| count` | Presses the key `count` times. `count` may be `$var` |
| 🔁 Jump To | Row number | Continues at that row (unconditional) |
| 🛑 Stop Sequence | none | Ends the run |

> `Jump To` uses the row **number**. If you move or delete rows, check your jump targets.

### Vision

| Type | Value |
|---|---|
| 🔍 Find Image | Path to a `.png` / `.bmp` / `.gif` file. Searches the whole screen and clicks the match position. If not found, the step is skipped |

---

## Tools

### Position Capture

For click, move and drag types, click **🎯 Capture Position** or press `Shift+Space`, then click anywhere on screen. The position is filled in and also copied to the clipboard. For **Drag**, capture twice: the first click sets the start, the second sets the end.

### Color Picker

For **Wait for Color**, click **🎨 Pick Color**. A magnifier follows the cursor.

| Input | Effect |
|---|---|
| Left click | Pick position and color |
| `Shift` + scroll | Resize the sample region (`Shift+Alt` for bigger steps) |
| `Tab` or `M` | Toggle `ANY` / `AVG` mode |
| `Esc` | Cancel |

### Macro Recorder

Click **⏺ Record Macro**. The window minimizes and the recorder captures:
- **Left clicks** with their position (500 ms delay each)
- **Key presses** including Ctrl/Alt/Shift/Win (100 ms delay each)

Press `Esc` to stop. Recorded actions are appended to the list.

### Editing the List

- **Double-click** a row to edit it.
- **Drag & drop** rows, or use **▲ Up / ▼ Dn**, to reorder.
- **🗑️ Del** removes the selected row, **🧹 All** clears the list.
- **Undo / Redo** keeps up to 50 steps.

---

## Profiles

**💾 Save Profile** and **📂 Load Profile** store the action list as a UTF-8 text file:

```text
#KEYFLOW v2
Press Key|500|^|F5
Type Text|1000||Hello World!
Left Click|500||960 540
```

Each line is `type|delay|mods|value`. Emojis are stripped from the type, and `|` or line breaks inside fields are escaped. Older profile formats still load.

> Only the action list is saved. Run settings (Repetitions, Speed, Jitter, Pause) are **not** part of a profile.

---

## ⚠️ Safety

Some actions can do real damage when a sequence misbehaves or runs in an endless loop:

- **🔫 Kill Process** force-closes programs without asking, so unsaved work is lost.
- **📜 Run PowerShell** runs commands hidden with `-ExecutionPolicy Bypass`. The presets include `Restart-Computer -Force` and `shutdown /s /t 0`.
- **Clicks and keystrokes** go to whatever window is active.

Test new sequences with **Repetitions = 1** and keep `F8` in reach.

---

## Known Limitations

- Pause and Stop wait for the current action to finish.
- **Wait for Color** has a fixed 10 s timeout and no color tolerance.
- **Find Image** always searches the full screen, with no tolerance or retry.
- **Jump To** is unconditional. There are no real loop or if blocks yet.
- Profiles don't store run settings.
