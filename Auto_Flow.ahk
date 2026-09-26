#Requires AutoHotkey v2.0
#SingleInstance Force
CoordMode "Mouse", "Screen"

; =============================================
;   Key Flow V1 - AutoHotkey v2
; =============================================

global isRunning    := false
global isPaused     := false
global runLoop      := false
global actionList   := []
global selectedRow  := 0
global varStore     := Map()
global jumpTarget   := 0
global isRecording  := false
global recHook      := ""
global osdGui       := ""
global osdStatusLbl := ""
global osdActionLbl := ""
global osdRepeatLbl := ""
global toastGui      := ""
global undoStack    := []
global redoStack    := []
global lvDragRow    := 0
global lvDragging   := false
global ValuePresets := Map(
    "⌨️ Press Key",          ["F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12",
                              "Enter","Space","Tab","Escape","Backspace","Delete",
                              "Home","End","Page Up","Page Down",
                              "Arrow Up","Arrow Down","Arrow Left","Arrow Right",
                              "Print Screen","Insert","Caps Lock","Num Lock",
                              "a","b","c","d","e","f","g","h","i","j","k","l","m",
                              "n","o","p","q","r","s","t","u","v","w","x","y","z",
                              "0","1","2","3","4","5","6","7","8","9"],
    "🔗 Hotkey Combo",       ["Ctrl+C  (Copy)","Ctrl+V  (Paste)","Ctrl+X  (Cut)",
                              "Ctrl+Z  (Undo)","Ctrl+Y  (Redo)","Ctrl+A  (Select All)",
                              "Ctrl+S  (Save)","Ctrl+W  (Close Tab)","Ctrl+T  (New Tab)",
                              "Ctrl+N  (New)","Ctrl+Shift+Z  (Redo)","Alt+F4  (Close Window)",
                              "Ctrl+Shift+Esc  (Task Manager)","Win+D  (Show Desktop)",
                              "Win+E  (Explorer)","Win+L  (Lock PC)","Win+R  (Run Dialog)"],
    "💬 Comment",             ["-- section start --", "-- loop start --", "-- loop end --", "TODO:", "NOTE:"],
    "✏️ Type Text",           ["Hello World!","Your text here...","user@example.com","https://"],
    "🖱️ Left Click",         ["Current Position","100 100","500 300","960 540","1280 720","1920 1080"],
    "🖱️ Right Click",        ["Current Position","100 100","500 300","960 540","1280 720"],
    "🖱️ Double Click",       ["Current Position","100 100","500 300","960 540","1280 720"],
    "🖱️ Middle Click",       ["Current Position","100 100","500 300","960 540","1280 720"],
    "🖱️ Hold Left",          ["(automatic)"],
    "🖱️ Release Left",       ["(automatic)"],
    "🖱️ Hold Right",         ["(automatic)"],
    "🖱️ Release Right",      ["(automatic)"],
    "🖱️ Drag",               ["100 200 | 400 500"],
    "🎨 Wait for Color",     ["500 300 | FF0000"],
    "➡️ Move Mouse",         ["100 100","500 300","960 540","1280 720","0 0"],
    "🔼 Scroll Up",          ["1 tick","2 ticks","3 ticks","5 ticks","10 ticks"],
    "🔽 Scroll Down",        ["1 tick","2 ticks","3 ticks","5 ticks","10 ticks"],
    "⏳ Wait (ms)",           ["100 ms","250 ms","500 ms","1000 ms","2000 ms","3000 ms","5000 ms","10000 ms"],
    "🚀 Open Program",       ["notepad.exe","calc.exe","mspaint.exe","explorer.exe","chrome.exe"],
    "🔊 Volume Up",          ["1 step","2 steps","5 steps","10 steps"],
    "🔉 Volume Down",        ["1 step","2 steps","5 steps","10 steps"],
    "🔇 Mute Toggle",        ["(automatic)"],
    "📸 Screenshot",         ["(automatic)"],
    "📋 Copy",               ["(automatic)"],
    "📋 Paste",              ["(automatic)"],
    "✂️ Cut",                 ["(automatic)"],
    "↩️ Undo",               ["(automatic)"],
    "🔲 Select All",         ["(automatic)"],
    "🔒 Lock PC",            ["(automatic)"],
    "🔔 Notification",       ["Key Flow|Step done!", "Key Flow|Loop finished!", "Key Flow|Counter: $counter"],
    "🌐 Open URL",           ["https://", "www."],
    "➖ Minimize Window",    ["Current Window","Untitled - Notepad","Calculator"],
    "⬜ Maximize Window",    ["Current Window","Untitled - Notepad","Calculator"],
    "❌ Close Window",       ["Current Window","Untitled - Notepad","Calculator"],
    "📊 Var: Set",           ["counter|0", "counter|1", "limit|10", "myvar|0"],
    "📊 Var: Add",           ["counter|1", "myvar|1"],
    "📊 Var: Sub",           ["counter|1", "myvar|1"],
    "📊 Var: Set If",        [
        "counter|==|5|0",
        "counter|!=|0|1",
        "counter|>|9|0",
        "counter|>=|10|0",
        "counter|<|10|1",
        "counter|<=|0|1",
    ],
    "📊 Var: Random",        ["counter|1|100", "counter|0|10", "myvar|1|6"],
    "🔁 Repeat Key",         ["F5|$myvar","F1|$myvar","F2|$myvar","F3|$myvar","F4|$myvar",
                              "F6|$myvar","F7|$myvar","F8|$myvar","F9|$myvar","F10|$myvar",
                              "Enter|$myvar","Space|$myvar","Tab|$myvar","Escape|$myvar",
                              "Backspace|$myvar","Delete|$myvar",
                              "Arrow Up|$myvar","Arrow Down|$myvar","Arrow Left|$myvar","Arrow Right|$myvar",
                              "Page Up|$myvar","Page Down|$myvar","Home|$myvar","End|$myvar",
                              "a|$myvar","b|$myvar","c|$myvar","d|$myvar","e|$myvar",
                              "f|$myvar","g|$myvar","h|$myvar","i|$myvar","j|$myvar",
                              "k|$myvar","l|$myvar","m|$myvar","n|$myvar","o|$myvar",
                              "p|$myvar","q|$myvar","r|$myvar","s|$myvar","t|$myvar",
                              "u|$myvar","v|$myvar","w|$myvar","x|$myvar","y|$myvar","z|$myvar",
                              "0|$myvar","1|$myvar","2|$myvar","3|$myvar","4|$myvar",
                              "5|$myvar","6|$myvar","7|$myvar","8|$myvar","9|$myvar",
                              "F5|3","Enter|3","Space|3"],
    "🔁 Jump To",            ["2", "3", "1"],
    "🔍 Find Image",         ["C:\path\to\image.png"],
    "📜 Run PowerShell",     ["wsl --shutdown","Stop-Process -Name chrome -Force","Restart-Computer -Force","shutdown /s /t 0","ipconfig /flushdns","Get-Process | Out-File C:\procs.txt","Start-Sleep -Seconds 5"],
    "🔫 Kill Process",       ["notepad.exe","chrome.exe","msedge.exe","firefox.exe",
                              "explorer.exe","calc.exe","mspaint.exe","Code.exe",
                              "Discord.exe","Spotify.exe","steam.exe","vlc.exe",
                              "WINWORD.EXE","EXCEL.EXE","POWERPNT.EXE","taskmgr.exe"],
    "📋 Var: From Clipboard", ["clip", "text", "data", "result"],
    "🖱️ Var: Mouse Pos",      ["mx|my", "x|y", "posX|posY"],
    "🪟 Var: Win Title",      ["wtitle", "title", "wintitle"],
)

global AllActionTypes := [
    "━━━━━━━━ KEYS ━━━━━━━━",
    "⌨️ Press Key",
    "🔗 Hotkey Combo",
    "━━━━━━━━ MOUSE ━━━━━━━━",
    "🖱️ Left Click",
    "🖱️ Right Click",
    "🖱️ Double Click",
    "🖱️ Middle Click",
    "🖱️ Hold Left",
    "🖱️ Release Left",
    "🖱️ Hold Right",
    "🖱️ Release Right",
    "🖱️ Drag",
    "🎨 Wait for Color",
    "➡️ Move Mouse",
    "🔼 Scroll Up",
    "🔽 Scroll Down",
    "━━━━━━━━ TEXT & INPUT ━━━━━━━━",
    "💬 Comment",
    "✏️ Type Text",
    "📋 Copy",
    "📋 Paste",
    "✂️ Cut",
    "↩️ Undo",
    "🔲 Select All",
    "━━━━━━━━ SYSTEM ━━━━━━━━",
    "⏳ Wait (ms)",
    "🚀 Open Program",
    "🔊 Volume Up",
    "🔉 Volume Down",
    "🔇 Mute Toggle",
    "📸 Screenshot",
    "🔒 Lock PC",
    "🔔 Notification",
    "📜 Run PowerShell",
    "🌐 Open URL",
    "━━━━━━━━ WINDOWS ━━━━━━━━",
    "➖ Minimize Window",
    "⬜ Maximize Window",
    "❌ Close Window",
    "🔫 Kill Process",
    "━━━━━━━━ VARIABLES ━━━━━━━━",
    "📊 Var: Set",
    "📊 Var: Add",
    "📊 Var: Sub",
    "📊 Var: Set If",
    "📊 Var: Random",
    "📋 Var: From Clipboard",
    "🖱️ Var: Mouse Pos",
    "🪟 Var: Win Title",
    "━━━━━━━━ FLOW ━━━━━━━━",
    "🔁 Repeat Key",
    "🔁 Jump To",
    "🛑 Stop Sequence",
    "━━━━━━━━ VISION ━━━━━━━━",
    "🔍 Find Image",
]

global ModifierTypes := "⌨️ Press Key,🔗 Hotkey Combo"
global AutoTypes     := "🔇 Mute Toggle,📸 Screenshot,📋 Copy,📋 Paste,✂️ Cut,↩️ Undo,🔲 Select All,🔒 Lock PC,🖱️ Hold Left,🖱️ Release Left,🖱️ Hold Right,🖱️ Release Right,🛑 Stop Sequence"

; Friendly display names → exe names for Open Program dropdown
global FriendlyApps := Map(
    "Notepad",        "notepad.exe",
    "Calculator",     "calc.exe",
    "Paint",          "mspaint.exe",
    "File Explorer",  "explorer.exe",
    "Chrome",         "chrome.exe",
    "Edge",           "msedge.exe",
    "Firefox",        "firefox.exe",
    "Task Manager",   "taskmgr.exe",
    "VS Code",        "Code.exe",
    "Word",           "WINWORD.EXE",
    "Excel",          "EXCEL.EXE",
    "PowerPoint",     "POWERPNT.EXE",
    "Outlook",        "OUTLOOK.EXE",
    "Discord",        "Discord.exe",
    "Steam",          "steam.exe",
    "Spotify",        "Spotify.exe",
    "VLC",            "vlc.exe"
)

; =============================================
;   Helper Functions
; =============================================

IsAutoType(t)     => InStr(AutoTypes,     t) > 0
IsModifierType(t) => InStr(ModifierTypes, t) > 0
IsSeparator(t)    => SubStr(t, 1, 4) = "━━━━"

; Scan actionList for every variable name already in use, then build
; dropdown entries for the given Var type.  Falls back to one example
; entry when no variables exist yet.
BuildVarPresets(type) {
    global actionList
    seen     := Map()
    varNames := []
    for a in actionList {
        t := a.type
        if (t = "📊 Var: Set" || t = "📊 Var: Add" || t = "📊 Var: Sub" || t = "📊 Var: Set If" || t = "📊 Var: Random") {
            sep  := InStr(a.value, "|")
            name := sep > 0 ? Trim(SubStr(a.value, 1, sep - 1)) : Trim(a.value)
            if (name != "" && !seen.Has(name)) {
                seen[name] := true
                varNames.Push(name)
            }
        }
    }
    entries := []
    if (type = "📊 Var: Set") {
        for n in varNames
            entries.Push(n "|0")
        if (varNames.Length = 0)
            entries.Push("counter|0")
    } else if (type = "📊 Var: Add") {
        for n in varNames
            entries.Push(n "|1")
        if (varNames.Length = 0)
            entries.Push("counter|1")
    } else if (type = "📊 Var: Sub") {
        for n in varNames
            entries.Push(n "|1")
        if (varNames.Length = 0)
            entries.Push("counter|1")
    } else if (type = "📊 Var: Set If") {
        for n in varNames
            entries.Push(n "|==|0|0")
        if (varNames.Length = 0)
            entries.Push("counter|==|10|0")
    } else if (type = "📊 Var: Random") {
        for n in varNames
            entries.Push(n "|1|100")
        if (varNames.Length = 0)
            entries.Push("counter|1|100")
    }
    return entries
}

HintForType(t) {
    if (t = "📊 Var: Set")
        return "Format:  varname | value          e.g.  counter | 0      Sets a variable to the given value."
    if (t = "📊 Var: Add")
        return "Format:  varname | amount          e.g.  counter | 1      Adds the amount to the variable."
    if (t = "📊 Var: Sub")
        return "Format:  varname | amount          e.g.  counter | 1      Subtracts the amount from the variable."
    if (t = "📊 Var: Set If")
        return "Format:  varname | operator | checkvalue | newvalue" . "`n"
             . "Operators:  == (equals)     != (not equals)     > (greater than)     < (less than)     >= (greater or equal)     <= (less or equal)"
    if (t = "🔁 Repeat Key")
        return "Format:  key | count          e.g.  F5 | 3    or    F5 | $counter      Use $varname to read a variable as the count."
    if (t = "🔁 Jump To")
        return "Enter the row number to jump to.     e.g.  3 = skip straight to action 3.     Use together with variables to build loops."
    if (t = "🔔 Notification")
        return "Format:  title | message     e.g.  Key Flow | Step done!     Pick the sound below.  $varname works in both fields."
    if (t = "📊 Var: Random")
        return "Format:  varname | min | max          e.g.  counter | 1 | 100      Sets varname to a random whole number between min and max (inclusive)."
    if (t = "🖱️ Drag")
        return "Format:  x1 y1 | x2 y2     Click 🎯 twice — first for start position, second for end position."
    if (t = "🎨 Wait for Color")
        return "Format:  x y | RRGGBB     e.g.  500 300 | FF0000     Use 🎯 to pick position and 🎨 to pick color from screen."
    if (t = "🌐 Open URL")
        return "Enter a URL — both https://example.com and www.example.com are supported."
    if (t = "🚀 Open Program")
        return "Pick from the list (common apps or running processes), paste a full path, or click 📂 to browse.  Full paths like C:\Program Files\...\app.exe work directly."
    if (t = "➖ Minimize Window" || t = "⬜ Maximize Window" || t = "❌ Close Window")
        return "Select a process from the list (e.g. notepad.exe) — works even if the window title changes.     Use 'Current Window' for whatever is active at the time."
    if (t = "💬 Comment")
        return "A note or label — does nothing during playback.     Use it to mark sections in your action list."
    if (t = "🔍 Find Image")
        return "Enter the full path to a .png image file.  Click 📂 to browse.  If found on screen, its center is clicked.  If not found, the step is skipped."
    if (t = "📜 Run PowerShell")
        return "Type any PowerShell command (e.g. wsl --shutdown) or a full path to a .ps1 script.  Runs hidden in the background."
    if (t = "🔫 Kill Process")
        return "Enter a process name (e.g. notepad.exe) or paste a full path (e.g. C:\Program Files\Docker\Docker\resources\com.docker.build.exe) — the filename is extracted automatically."
    if (t = "📋 Var: From Clipboard")
        return "Format:  varname          e.g.  clip      Reads the current clipboard text into the variable at runtime."
    if (t = "🖱️ Var: Mouse Pos")
        return "Format:  varX | varY          e.g.  mx | my      Stores the live mouse X and Y position into two separate variables."
    if (t = "🪟 Var: Win Title")
        return "Format:  varname          e.g.  wtitle      Reads the active window's title into the variable at runtime."
    return ""
}

; Resolve "$varname" → stored value, or return val as-is
ResolveVar(val) {
    global varStore
    if (SubStr(val, 1, 1) = "$") {
        key := SubStr(val, 2)
        return varStore.Has(key) ? varStore[key] : 0
    }
    return val
}

; --- Safe conversion / execution helpers --------------------------------
; Integer with fallback — never throws on empty or non-numeric input
SafeInt(val, default := 0) {
    val := Trim(val "")
    return IsInteger(val) ? Integer(val) : default
}

; Number (int or float) with fallback
SafeNum(val, default := 0) {
    val := Trim(val "")
    return IsNumber(val) ? Number(val) : default
}

; Resolve a value, then coerce to integer (handles "$var" and junk safely)
ResolveInt(val, default := 0) {
    return SafeInt(ResolveVar(val), default)
}

; Run a command, swallow failures and surface them as a tray notification
; instead of crashing the whole sequence
SafeRun(target, args*) {
    try {
        Run(target, args*)
        return true
    } catch as e {
        ShowToast("Key Flow", "Could not run: " target)
        return false
    }
}

; Build modifier string from checkboxes (main GUI)
BuildMods() {
    return (ChkCtrl.Value ? "^" : "") . (ChkAlt.Value ? "!" : "") . (ChkShift.Value ? "+" : "") . (ChkWin.Value ? "#" : "")
}

; Build readable display string for the ListView
BuildDisplay(type, value, mods) {
    if (value = "(auto)") {
        return "—"
    }
    if (type = "🖱️ Drag") {
        p := StrSplit(value, "|")
        return (p.Length >= 2) ? "(" Trim(p[1]) ") → (" Trim(p[2]) ")" : value
    }
    if (type = "🎨 Wait for Color") {
        p := StrSplit(value, "|")
        if (p.Length >= 4) {
            wh   := Trim(p[3])
            mode := Trim(p[4])
            return "at " Trim(p[1]) "  =  #" Trim(p[2]) "  [" wh "  " mode "]"
        }
        return (p.Length >= 2) ? "at " Trim(p[1]) "  =  #" Trim(p[2]) : value
    }
    if (type = "🌐 Open URL") {
        url := RegExReplace(value, "^https?://", "")
        url := RegExReplace(url, "/.*$", "")
        return url
    }
    if (type = "🚀 Open Program") {
        global FriendlyApps
        if (FriendlyApps.Has(value))
            return value          ; friendly name as-is
        SplitPath(value, &fname)  ; full path → just the filename
        return (fname != "") ? fname : value
    }
    if (type = "📊 Var: Set") {
        p := StrSplit(value, "|")
        return (p.Length >= 2) ? p[1] " = " p[2] : value
    }
    if (type = "📊 Var: Add") {
        p := StrSplit(value, "|")
        return (p.Length >= 2) ? p[1] " + " p[2] : value
    }
    if (type = "📊 Var: Sub") {
        p := StrSplit(value, "|")
        return (p.Length >= 2) ? p[1] " - " p[2] : value
    }
    if (type = "📊 Var: Set If") {
        p := StrSplit(value, "|")
        return (p.Length >= 4) ? "if " p[1] " " p[2] " " p[3] "  →  " p[1] " = " p[4] : value
    }
    if (type = "🔔 Notification") {
        p := StrSplit(value, "|")
        if (p.Length >= 3 && Trim(p[3]) != "")
            return Trim(p[1]) " — " Trim(p[2]) "  🔊 " Trim(p[3])
        return (p.Length >= 2) ? Trim(p[1]) " — " Trim(p[2]) : value
    }
    if (type = "📊 Var: Random") {
        p := StrSplit(value, "|")
        return (p.Length >= 3) ? p[1] " = rand(" p[2] " … " p[3] ")" : value
    }
    if (type = "🔁 Repeat Key") {
        p := StrSplit(value, "|")
        return (p.Length >= 2) ? p[1] " × " p[2] : value
    }
    if (type = "🔁 Jump To") {
        return "→ row " value
    }
    if (type = "📋 Var: From Clipboard")
        return "clipboard → $" value
    if (type = "🖱️ Var: Mouse Pos") {
        p := StrSplit(value, "|")
        return (p.Length >= 2) ? "$" Trim(p[1]) " , $" Trim(p[2]) : value
    }
    if (type = "🪟 Var: Win Title")
        return "win title → $" value
    if (type = "🔍 Find Image") {
        SplitPath(value, &fname)
        return (fname != "") ? fname : value
    }
    prefix := (InStr(mods,"^") ? "Ctrl+" : "") . (InStr(mods,"!") ? "Alt+" : "") . (InStr(mods,"+") ? "Shift+" : "") . (InStr(mods,"#") ? "Win+" : "")
    return prefix . value
}

; Convert friendly display value to real AHK send string
ToAhk(type, value, mods) {
    if (type = "🔗 Hotkey Combo") {
        static cm := Map(
            "Ctrl+C  (Copy)","^c","Ctrl+V  (Paste)","^v","Ctrl+X  (Cut)","^x",
            "Ctrl+Z  (Undo)","^z","Ctrl+Y  (Redo)","^y","Ctrl+A  (Select All)","^a",
            "Ctrl+S  (Save)","^s","Ctrl+W  (Close Tab)","^w","Ctrl+T  (New Tab)","^t",
            "Ctrl+N  (New)","^n","Ctrl+Shift+Z  (Redo)","^+z",
            "Alt+F4  (Close Window)","!F4","Ctrl+Shift+Esc  (Task Manager)","^+Escape",
            "Win+D  (Show Desktop)","#d","Win+E  (Explorer)","#e",
            "Win+L  (Lock PC)","#l","Win+R  (Run Dialog)","#r"
        )
        return cm.Has(value) ? cm[value] : value
    }
    if (type = "⌨️ Press Key") {
        static km := Map(
            "Enter","{Enter}","Space","{Space}","Tab","{Tab}","Escape","{Escape}",
            "Backspace","{Backspace}","Delete","{Delete}","Home","{Home}","End","{End}",
            "Page Up","{PgUp}","Page Down","{PgDn}",
            "Arrow Up","{Up}","Arrow Down","{Down}","Arrow Left","{Left}","Arrow Right","{Right}",
            "Print Screen","{PrintScreen}","Insert","{Insert}","Caps Lock","{CapsLock}","Num Lock","{NumLock}",
            "F1","{F1}","F2","{F2}","F3","{F3}","F4","{F4}","F5","{F5}","F6","{F6}",
            "F7","{F7}","F8","{F8}","F9","{F9}","F10","{F10}","F11","{F11}","F12","{F12}"
        )
        key := km.Has(value) ? km[value] : value
        return mods . key
    }
    ; For scroll/wait/volume, extract just the leading number
    if (type = "🔼 Scroll Up" || type = "🔽 Scroll Down" || type = "⏳ Wait (ms)" || type = "🔊 Volume Up" || type = "🔉 Volume Down") {
        return RegExReplace(value, "\s.*", "")
    }
    return value
}

; Full unfiltered list for the current type — used by search filter
global valueFullList := []

; Populate the value ComboBox for a given type.
; Also builds valueFullList for the search filter.
PopulateValues(cb) {
    type := ActionType.Text
    if (IsSeparator(type) || type = "" || type = "(no results)") {
        return
    }
    global valueFullList
    valueFullList := []
    lastSearchText := ""   ; reset filter when type changes
    cb.Delete()

    if (IsAutoType(type)) {
        cb.Add(["(automatic)"])
        cb.Choose(1)
        cb.Enabled := false
        return
    }
    cb.Enabled := true

    ; Build the raw item list first, then populate CB from it
    items := []

    ; --- Open Program: friendly presets + running processes with full path ---
    if (type = "🚀 Open Program") {
        global FriendlyApps
        for name, _ in FriendlyApps
            items.Push(name)
        items.Push("── Running ──")
        seen := Map()
        try {
            wmi   := ComObjGet("winmgmts:")
            procs := wmi.ExecQuery("SELECT Name, ExecutablePath FROM Win32_Process")
            for proc in procs {
                path := proc.ExecutablePath
                if (path != "" && !seen.Has(path) && !InStr(path, "AutoHotkey")) {
                    seen[path] := true
                    items.Push(path)
                }
            }
        }

    ; --- Window actions: visible-window processes ---
    } else if (InStr(type, "Window")) {
        items.Push("Current Window")
        seen := Map()
        for hwnd in WinGetList() {
            try {
                proc := WinGetProcessName(hwnd)
                if (proc != "" && !seen.Has(proc)
                    && proc != "AutoHotkey64.exe" && proc != "AutoHotkey32.exe") {
                    seen[proc] := true
                    items.Push(proc)
                }
            }
        }

    ; --- Kill Process: all processes via WMI with full path ---
    } else if (type = "🔫 Kill Process") {
        seen := Map()
        try {
            wmi   := ComObjGet("winmgmts:")
            procs := wmi.ExecQuery("SELECT Name, ExecutablePath FROM Win32_Process")
            for proc in procs {
                name := proc.Name
                path := proc.ExecutablePath
                if (name = "" || name = "AutoHotkey64.exe" || name = "AutoHotkey32.exe")
                    continue
                ; Show full path if available, otherwise just the name
                entry := (path != "") ? path : name
                if (!seen.Has(entry)) {
                    seen[entry] := true
                    items.Push(entry)
                }
            }
        }

    ; --- Var types ---
    } else if (InStr(type, "📊 Var:")) {
        for e in BuildVarPresets(type)
            items.Push(e)

    ; --- Static presets ---
    } else if (ValuePresets.Has(type)) {
        for v in ValuePresets[type]
            items.Push(v)
    }

    ; Store full list for search filter, then fill ComboBox
    valueFullList := items
    for item in items
        cb.Add([item])
    try cb.Choose(1)
}

; Filter the ComboBox dropdown list to items matching the search term.
; Caret stays at end, dropdown opens automatically to show results.
FilterValues(query) {
    global valueFullList, ActionValue, cbEditHwnd
    q := StrLower(Trim(query))
    ActionValue.Delete()
    if (q = "") {
        for item in valueFullList
            ActionValue.Add([item])
    } else {
        matched := 0
        for item in valueFullList {
            if (InStr(StrLower(item), q)) {
                ActionValue.Add([item])
                matched++
            }
        }
        if (matched = 0)
            ActionValue.Add(["(no results)"])
    }
    ; Restore typed text with caret at end (avoids cursor-jump artifact)
    ActionValue.Text := query
    if (cbEditHwnd)
        SendMessage(0x00B1, StrLen(query), StrLen(query), cbEditHwnd)  ; EM_SETSEL
    ; Open dropdown so results are visible immediately
    SendMessage(0x014F, 1, 0, ActionValue.Hwnd)  ; CB_SHOWDROPDOWN
}

; Polling timer — watches ActionValue.Text, fires FilterValues when user is typing
global lastSearchText    := ""
global isSearchableType  := false
global cbEditHwnd        := 0   ; internal Edit hwnd of ActionValue ComboBox

ValueSearchTick() {
    global ActionValue, lastSearchText, isSearchableType, valueFullList
    if (!isSearchableType || valueFullList.Length = 0)
        return
    cur := ActionValue.Text
    if (cur = lastSearchText)
        return
    ; Skip if text exactly matches an item — means user selected from list, not typing
    for item in valueFullList {
        if (item = cur) {
            lastSearchText := cur
            return
        }
    }
    lastSearchText := cur
    FilterValues(cur)
}

; =============================================
;   Main GUI
; =============================================
MyGui := Gui("+Resize", "Key Flow V1")
MyGui.SetFont("s10", "Segoe UI")
MyGui.BackColor := "13131F"

MyGui.SetFont("s14 cFFFFFF Bold")
MyGui.Add("Text", "x20 y12 w900", "Key Flow V1")
MyGui.SetFont("s9 c7777AA")
MyGui.Add("Text", "x20 y40 w900", "Build automation sequences with keys, mouse, text, and more.")
MyGui.Add("Text", "x0 y62 w1079 h2 Background2D2D4A")

; --- Add Action ---
MyGui.SetFont("s9 cAABBFF Bold")
MyGui.Add("Text", "x20 y72", "▸  ADD ACTION")

MyGui.SetFont("s9 cAAAAAA")
MyGui.Add("Text", "x20 y94",  "Action Type")
MyGui.Add("Text", "x250 y94", "Value")
MyGui.Add("Text", "x720 y94", "Delay (ms)")

MyGui.SetFont("s9 cFFFFFF")
global ActionType  := MyGui.Add("DropDownList", "x20  y111 w225 vActionType", AllActionTypes)
global ActionValue := MyGui.Add("ComboBox",     "x250 y111 w405 vActionValue Background1E1E32 c8899BB", [])
global BtnBrowse   := MyGui.Add("Button",       "x660 y108 w50  h28", "📂")
global ActionDelay := MyGui.Add("Edit",         "x720 y111 w90  vActionDelay Background1E1E32 cFFFFFF", "500")
global BtnAdd      := MyGui.Add("Button",       "x820 y108 w90  h28", "➕ Add")
BtnBrowse.Visible := false
BtnBrowse.OnEvent("Click", BrowseForExe)
MyGui.SetFont("s7 c556699")
global HintLabel := MyGui.Add("Text", "x250 y140 w660 h28", "")
HintLabel.Visible := false

BtnAdd.SetFont("s9 Bold")
BtnAdd.OnEvent("Click", AddAction)

ActionType.Choose(2)
ActionType.OnEvent("Change", OnTypeChange)

; --- Row 2: Modifier checkboxes (shown for key types) ---
MyGui.SetFont("s9 cAAAAAA")
global LblModRow  := MyGui.Add("Text",     "x20 y148", "Modifiers:")
global ChkCtrl    := MyGui.Add("CheckBox", "x90  y146 w58 vCtrl  cFFFFFF Background1E1E32", "Ctrl")
global ChkAlt     := MyGui.Add("CheckBox", "x150 y146 w52 vAlt   cFFFFFF Background1E1E32", "Alt")
global ChkShift   := MyGui.Add("CheckBox", "x204 y146 w58 vShift cFFFFFF Background1E1E32", "Shift")
global ChkWin     := MyGui.Add("CheckBox", "x264 y146 w50 vWin   cFFFFFF Background1E1E32", "Win")
global LblSymbols := MyGui.Add("Text",     "x320 y149 w100 c5588FF", "")
ChkCtrl.SetFont("s9")
ChkAlt.SetFont("s9")
ChkShift.SetFont("s9")
ChkWin.SetFont("s9")
ChkCtrl.OnEvent("Click",  RefreshSymbols)
ChkAlt.OnEvent("Click",   RefreshSymbols)
ChkShift.OnEvent("Click", RefreshSymbols)
ChkWin.OnEvent("Click",   RefreshSymbols)

; --- Row 2: Capture row (shown for mouse types, NOT Wait for Color) ---
global LblCaptureRow := MyGui.Add("Text", "x20 y148 cAAAAAA", "Mouse Position:")
global BtnCapture    := MyGui.Add("Button", "x130 y144 w180 h26", "🎯 Capture Position")
BtnCapture.SetFont("s9 Bold")
BtnCapture.OnEvent("Click", StartCapture)
MyGui.SetFont("s8 c555577")
global LblCaptureHint := MyGui.Add("Text", "x318 y149 w250", "Click button, then click anywhere  |  Shift+Space")

; --- Row 2: Color pick row (shown ONLY for Wait for Color) ---
global LblColorRow    := MyGui.Add("Text", "x20 y148 cAAAAAA", "Color Picker:")
global BtnPickColor   := MyGui.Add("Button", "x120 y144 w140 h26", "🎨 Pick Color")
BtnPickColor.SetFont("s9 Bold")
BtnPickColor.OnEvent("Click", StartColorPick)
global BtnColorMode   := MyGui.Add("Button", "x268 y144 w70 h26", "ANY")
BtnColorMode.SetFont("s9 Bold")
BtnColorMode.OnEvent("Click", ToggleColorMode)
global colorPickMode  := "ANY"   ; "ANY" or "AVG"
MyGui.SetFont("s8 c555577")
global LblColorHint   := MyGui.Add("Text", "x346 y149 w500", "🎨 Pick = choose color   |   Shift+Scroll = resize region   |   Tab = toggle mode")

; All hidden by default — OnTypeChange will show the right row
LblModRow.Visible       := false
ChkCtrl.Visible         := false
ChkAlt.Visible          := false
ChkShift.Visible        := false
ChkWin.Visible          := false
LblSymbols.Visible      := false
LblCaptureRow.Visible   := false
BtnCapture.Visible      := false
LblCaptureHint.Visible  := false
LblColorRow.Visible     := false
BtnPickColor.Visible    := false
BtnColorMode.Visible    := false
LblColorHint.Visible    := false

MyGui.Add("Text", "x0 y202 w1079 h1 Background2D2D4A")

; --- Action List ---
MyGui.SetFont("s9 cAABBFF Bold")
MyGui.Add("Text", "x20 y210", "▸  ACTION LIST")
MyGui.SetFont("s9 c666688")
MyGui.Add("Text", "x650 y210", "Double-click a row to edit")

global ListView := MyGui.Add("ListView",
    "x20 y228 w930 h225 -Multi Grid -Sort -SortDesc vListView Background1A1A2E cEEEEFF",
    ["#", "Type", "Value", "Delay (ms)"])
ListView.ModifyCol(1, 40)
ListView.ModifyCol(2, 200)
ListView.ModifyCol(3, 540)
ListView.ModifyCol(4, 120)
ListView.OnEvent("DoubleClick", EditAction)
ListView.OnEvent("ItemSelect",  TrackRow)
ListView.OnEvent("ColClick",    (*) => RebuildList())

; Remove HDS_DRAGDROP (0x0040) so columns cannot be reordered by drag
hdr := SendMessage(0x101F, 0, 0, ListView.Hwnd)
DllCall("SetWindowLong", "Ptr", hdr, "Int", -16,
    "Int", DllCall("GetWindowLong", "Ptr", hdr, "Int", -16, "Int") & ~0x0040)

; Intercept WM_NOTIFY to block column header clicks (sort) and enforce min column widths
global ColMins := [32, 120, 140, 80]
OnMessage(0x4E, GuardListView)

GuardListView(wParam, lParam, msg, hwnd) {
    if (!IsSet(MyGui) || hwnd != MyGui.Hwnd) {
        return
    }
    code := NumGet(lParam, 2 * A_PtrSize, "Int")
    ; HDN_ITEMCLICKW = -310  →  block sorting entirely
    if (code = -310) {
        return 0
    }
    ; HDN_ENDTRACKW = -335  →  enforce minimum column widths
    if (code = -335) {
        col := NumGet(lParam, 3 * A_PtrSize, "Int") + 1
        if (col >= 1 && col <= ColMins.Length) {
            w := ListView.GetColumnWidth(col)
            if (w < ColMins[col]) {
                ListView.ModifyCol(col, ColMins[col])
            }
        }
    }
    ; LVN_BEGINDRAG = -109  →  start drag & drop reordering
    if (code = -109) {
        global lvDragRow, lvDragging
        lvDragRow  := NumGet(lParam, 3 * A_PtrSize, "Int") + 1
        lvDragging := true
        SetTimer(LVDragLoop, 15)
        return 0
    }
}

global BtnUp    := MyGui.Add("Button", "x960 y228 w80 h35", "▲ Up")
global BtnDown  := MyGui.Add("Button", "x960 y269 w80 h35", "▼ Dn")
global BtnDel   := MyGui.Add("Button", "x960 y317 w80 h35", "🗑️ Del")
global BtnClear := MyGui.Add("Button", "x960 y358 w80 h35", "🧹 All")
BtnUp.SetFont("s9")
BtnDown.SetFont("s9")
BtnDel.SetFont("s9")
BtnClear.SetFont("s9")
BtnUp.OnEvent("Click",    MoveUp)
BtnDown.OnEvent("Click",  MoveDown)
BtnDel.OnEvent("Click",   DelRow)
BtnClear.OnEvent("Click", ClearAll)

MyGui.Add("Text", "x0 y462 w1079 h1 Background2D2D4A")

; --- Settings ---
MyGui.SetFont("s9 cAABBFF Bold")
MyGui.Add("Text", "x20 y472", "▸  SETTINGS")
MyGui.SetFont("s9 cAAAAAA")
MyGui.Add("Text", "x20  y496", "Repetitions")
MyGui.Add("Text", "x200 y496", "Pause between runs (ms)")
MyGui.SetFont("s9 cFFFFFF")
global RepeatCount := MyGui.Add("Edit", "x20  y514 w100 Background1E1E32 cFFFFFF", "1")
global LoopDelay   := MyGui.Add("Edit", "x200 y514 w100 Background1E1E32 cFFFFFF", "1000")
MyGui.SetFont("s8 c444466")
MyGui.Add("Text", "x125 y518", "(0 = ∞ loop)")
MyGui.SetFont("s9 cAAAAAA")
MyGui.Add("Text", "x320 y496", "Jitter (±ms)")
MyGui.Add("Text", "x430 y496", "Speed")
MyGui.SetFont("s9 cFFFFFF")
global JitterEdit := MyGui.Add("Edit",         "x320 y514 w80  Background1E1E32 cFFFFFF", "0")
global SpeedDDL   := MyGui.Add("DropDownList", "x430 y514 w70  Background1E1E32 cFFFFFF", ["0.25x","0.5x","0.75x","1x","1.5x","2x","3x","5x"])
SpeedDDL.Choose(4)
MyGui.SetFont("s8 c555577")
MyGui.Add("Text", "x515 y502", "Hotkeys:")
MyGui.Add("Text", "x515 y518", "F6 Start / Stop     F7 Pause     F8 Force Stop")
MyGui.Add("Text", "x0 y544 w1079 h1 Background2D2D4A")

; --- Controls ---
global BtnStart := MyGui.Add("Button", "x20  y557 w240 h45", "▶   START  (F6)")
global BtnPause := MyGui.Add("Button", "x270 y557 w240 h45", "⏸   PAUSE  (F7)")
global BtnStop  := MyGui.Add("Button", "x520 y557 w240 h45", "⏹   STOP  (F8)")
BtnStart.SetFont("s11 cFFFFFF Bold")
BtnPause.SetFont("s11 cFFFFFF Bold")
BtnStop.SetFont("s11 cFFFFFF Bold")
BtnStart.OnEvent("Click", StartAuto)
BtnPause.OnEvent("Click", PauseAuto)
BtnStop.OnEvent("Click",  StopAuto)

global StatusLabel := MyGui.Add("Text", "x775 y557 w90 h45 BackgroundFF3355 cFFFFFF Center", "STOPPED")
StatusLabel.SetFont("s10 Bold")

MyGui.Add("Text", "x0 y612 w1079 h1 Background2D2D4A")

global BtnSave := MyGui.Add("Button", "x20  y622 w150 h30", "💾  Save Profile")
global BtnLoad := MyGui.Add("Button", "x180 y622 w150 h30", "📂  Load Profile")
BtnSave.SetFont("s9")
BtnLoad.SetFont("s9")
BtnSave.OnEvent("Click", SaveProfile)
BtnLoad.OnEvent("Click", LoadProfile)

global BtnRecord := MyGui.Add("Button", "x340 y622 w160 h30", "⏺  Record Macro")
BtnRecord.SetFont("s9")
BtnRecord.OnEvent("Click", StartRecording)

global BtnUndo := MyGui.Add("Button", "x510 y622 w115 h30", "↩  Undo  (Ctrl+Z)")
global BtnRedo := MyGui.Add("Button", "x635 y622 w115 h30", "↪  Redo  (Ctrl+Y)")
BtnUndo.SetFont("s9")
BtnRedo.SetFont("s9")
BtnUndo.OnEvent("Click", Undo)
BtnRedo.OnEvent("Click", Redo)

OnTypeChange()
LoadExamples()

MyGui.Show("w1079 h666")
MyGui.OnEvent("Close", (*) => ExitApp())

; Get the internal Edit control hwnd of the ActionValue ComboBox (needed for caret positioning)
global cbEditHwnd := DllCall("FindWindowEx", "Ptr", ActionValue.Hwnd, "Ptr", 0, "Str", "Edit", "Ptr", 0, "Ptr")

; =============================================
;   Hotkeys
; =============================================
F6:: StartAuto()
F7:: PauseAuto()
F8:: StopAuto()
+Space:: StartCapture()

#HotIf WinActive("Key Flow V1")
^z:: Undo()
^y:: Redo()
#HotIf

; =============================================
;   UI Events
; =============================================

RefreshSymbols(*) {
    mods := BuildMods()
    LblSymbols.Text := (mods = "") ? "" : "[" mods "]"
}

; ── Mouse Position Capture ──────────────────────────────────────
global isCapturing := false

StartCapture(*) {
    global isCapturing
    if (isCapturing) {
        return
    }
    isCapturing := true

    ; Wait for the button click that triggered this to be fully released first
    KeyWait("LButton")

    ToolTip("🎯 Click anywhere to capture position...`n(Press Escape to cancel)")
    SetTimer(WaitForCapture, 30)
}

WaitForCapture() {
    global isCapturing, ActionValue

    if (GetKeyState("Escape", "P")) {
        isCapturing := false
        SetTimer(WaitForCapture, 0)
        ToolTip()
        return
    }

    if (GetKeyState("LButton", "P")) {
        ; Grab position immediately at click — before mouse moves
        MouseGetPos(&mx, &my)
        coords := mx " " my

        isCapturing := false
        SetTimer(WaitForCapture, 0)
        ToolTip()
        KeyWait("LButton")

        A_Clipboard := coords

        type := ActionType.Text
        if (InStr(type, "Click") || InStr(type, "Move")) {
            ActionValue.Text := coords
        } else if (type = "🖱️ Drag") {
            ; First capture = start, second = end
            existing := ActionValue.Text
            if (!InStr(existing, "|")) {
                ActionValue.Text := coords " | "
            } else {
                p := StrSplit(existing, "|")
                ActionValue.Text := Trim(p[1]) " | " coords
            }
        }

        ToolTip("✅ Captured: " coords "  —  Copied to clipboard!", , , 2)
        SetTimer(ClearCaptureTip, -2000)
        return
    }
}

ClearCaptureTip() {
    ToolTip(, , , 2)
}

; =============================================
;   Color Picker  (magnifier + region support)
; =============================================

global isPickingColor  := false
global cpRegionW       := 1      ; region width  in pixels
global cpRegionH       := 1      ; region height in pixels
global cpZoomGui       := ""     ; magnifier window handle
global cpZoomCanvas    := ""     ; Picture control used as canvas
global CP_ZOOM         := 8      ; zoom factor (screen px per pixel)
global CP_CANVAS       := 160    ; canvas size in pixels

ToggleColorMode(*) {
    global colorPickMode, BtnColorMode
    colorPickMode := (colorPickMode = "ANY") ? "AVG" : "ANY"
    BtnColorMode.Text := colorPickMode
}

StartColorPick(*) {
    global isPickingColor, cpRegionW, cpRegionH, cpZoomGui, cpZoomCanvas
    global colorPickMode, CP_ZOOM, CP_CANVAS

    ; Restore region size from current value field if present
    existing := ActionValue.Text
    parts := StrSplit(existing, "|")
    if (parts.Length >= 3) {
        wh := StrSplit(Trim(parts[3]), " ")
        if (wh.Length >= 2 && IsInteger(Trim(wh[1])) && IsInteger(Trim(wh[2]))) {
            cpRegionW := Integer(Trim(wh[1]))
            cpRegionH := Integer(Trim(wh[2]))
        }
    }

    isPickingColor := true
    MyGui.Hide()

    ; Build magnifier window
    cpZoomGui := Gui("+ToolWindow -Caption +AlwaysOnTop -DPIScale")
    cpZoomGui.BackColor := "1A1A2E"
    cpZoomGui.MarginX := 0
    cpZoomGui.MarginY := 0
    canvasSize := CP_CANVAS + 30
    cpZoomGui.Show("w" CP_CANVAS " h" (CP_CANVAS + 30) " NoActivate")

    ; Canvas picture control (will be painted via GDI)
    cpZoomCanvas := cpZoomGui.Add("Picture", "x0 y0 w" CP_CANVAS " h" CP_CANVAS " +0x4E")
    cpZoomGui.Add("Text", "x0 y" CP_CANVAS " w" CP_CANVAS " h30 BackgroundTransparent c555577", "")
    global cpInfoLabel := cpZoomGui.Add("Text", "x2 y" (CP_CANVAS + 2) " w156 h26 cDDDDDD BackgroundTransparent")
    cpInfoLabel.SetFont("s7", "Consolas")

    SetTimer(ColorPickLoop, 30)
}

ColorPickLoop() {
    global isPickingColor, ActionValue, cpZoomGui, cpZoomCanvas, cpInfoLabel
    global cpRegionW, cpRegionH, colorPickMode
    global CP_ZOOM, CP_CANVAS

    if (!isPickingColor)
        return

    ; Cancel on Escape
    if (GetKeyState("Escape", "P")) {
        ColorPickCleanup()
        MyGui.Show()
        return
    }

    ; Toggle mode with Tab or M
    if (GetKeyState("Tab", "P") || GetKeyState("m", "P")) {
        global colorPickMode, BtnColorMode
        colorPickMode := (colorPickMode = "ANY") ? "AVG" : "ANY"
        BtnColorMode.Text := colorPickMode
        KeyWait("Tab")
        KeyWait("m")
    }

    ; Resize region with Shift+Scroll
    if (GetKeyState("Shift", "P")) {
        step := GetKeyState("Alt", "P") ? 10 : 2
        if (GetKeyState("WheelUp", "P")) {
            cpRegionW := Max(1, cpRegionW + step)
            cpRegionH := Max(1, cpRegionH + step)
        }
        if (GetKeyState("WheelDown", "P")) {
            cpRegionW := Max(1, cpRegionW - step)
            cpRegionH := Max(1, cpRegionH - step)
        }
    }

    ; Confirm on left click
    if (GetKeyState("LButton", "P")) {
        MouseGetPos(&mx, &my)
        isPickingColor := false
        SetTimer(ColorPickLoop, 0)
        KeyWait("LButton")

        ; Sample color at center
        CoordMode("Pixel", "Screen")
        colInt := PixelGetColor(mx, my)
        r := (colInt >> 16) & 0xFF
        g := (colInt >> 8)  & 0xFF
        b :=  colInt        & 0xFF
        hexColor := Format("{:02X}{:02X}{:02X}", r, g, b)

        ; Fill position from click + color + region + mode
        ActionValue.Text := mx " " my " | " hexColor " | " cpRegionW " " cpRegionH " | " colorPickMode
        ColorPickCleanup()
        MyGui.Show()
        return
    }

    ; --- Draw magnifier ---
    MouseGetPos(&mx, &my)
    CoordMode("Pixel", "Screen")

    half := CP_CANVAS // (2 * CP_ZOOM)   ; half-size of captured area in screen pixels
    capW := CP_CANVAS // CP_ZOOM
    capH := CP_CANVAS // CP_ZOOM
    srcX := mx - half
    srcY := my - half

    ; Get canvas HWND and DC
    hCanvas := cpZoomCanvas.Hwnd
    hDC     := DllCall("GetDC", "Ptr", hCanvas, "Ptr")
    hMemDC  := DllCall("CreateCompatibleDC", "Ptr", hDC, "Ptr")
    hBmp    := DllCall("CreateCompatibleBitmap", "Ptr", hDC, "Int", CP_CANVAS, "Int", CP_CANVAS, "Ptr")
    DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hBmp)

    ; Capture screen region into memory DC
    hScreenDC := DllCall("GetDC", "Ptr", 0, "Ptr")
    DllCall("StretchBlt",
        "Ptr", hMemDC,  "Int", 0,    "Int", 0,    "Int", CP_CANVAS, "Int", CP_CANVAS,
        "Ptr", hScreenDC, "Int", srcX, "Int", srcY, "Int", capW,     "Int", capH,
        "UInt", 0x00CC0020)   ; SRCCOPY
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hScreenDC)

    ; Draw crosshair
    centerPx := CP_CANVAS // 2
    hPenCross := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", 0xFF4444, "Ptr")
    hOldPen   := DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hPenCross)
    DllCall("MoveToEx", "Ptr", hMemDC, "Int", centerPx, "Int", 0, "Ptr", 0)
    DllCall("LineTo",   "Ptr", hMemDC, "Int", centerPx, "Int", CP_CANVAS)
    DllCall("MoveToEx", "Ptr", hMemDC, "Int", 0,        "Int", centerPx, "Ptr", 0)
    DllCall("LineTo",   "Ptr", hMemDC, "Int", CP_CANVAS, "Int", centerPx)
    DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hOldPen)
    DllCall("DeleteObject", "Ptr", hPenCross)

    ; Draw region rectangle
    if (cpRegionW > 1 || cpRegionH > 1) {
        rHalfW := (cpRegionW * CP_ZOOM) // 2
        rHalfH := (cpRegionH * CP_ZOOM) // 2
        rx1 := centerPx - rHalfW
        ry1 := centerPx - rHalfH
        rx2 := centerPx + rHalfW
        ry2 := centerPx + rHalfH
        hPenRect := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", 0x4488FF, "Ptr")
        hOldPen  := DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hPenRect)
        hNullBrush := DllCall("GetStockObject", "Int", 5, "Ptr")  ; NULL_BRUSH
        hOldBrush  := DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hNullBrush)
        DllCall("Rectangle", "Ptr", hMemDC, "Int", rx1, "Int", ry1, "Int", rx2, "Int", ry2)
        DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hOldPen)
        DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hOldBrush)
        DllCall("DeleteObject", "Ptr", hPenRect)
    }

    ; Blit to canvas
    DllCall("BitBlt", "Ptr", hDC, "Int", 0, "Int", 0, "Int", CP_CANVAS, "Int", CP_CANVAS,
        "Ptr", hMemDC, "Int", 0, "Int", 0, "UInt", 0x00CC0020)

    ; Cleanup GDI
    DllCall("DeleteObject", "Ptr", hBmp)
    DllCall("DeleteDC", "Ptr", hMemDC)
    DllCall("ReleaseDC", "Ptr", hCanvas, "Ptr", hDC)

    ; Sample current pixel color for info label
    colInt  := PixelGetColor(mx, my)
    r       := (colInt >> 16) & 0xFF
    g       := (colInt >> 8)  & 0xFF
    b       :=  colInt        & 0xFF
    hexNow  := Format("{:02X}{:02X}{:02X}", r, g, b)
    cpInfoLabel.Text := mx " " my "  #" hexNow "  " cpRegionW "x" cpRegionH "  " colorPickMode

    ; Move zoom window near cursor (offset so it doesn't overlap)
    offX := 20
    offY := 20
    sW := SysGet(78)   ; SM_CXVIRTUALSCREEN
    sH := SysGet(79)   ; SM_CYVIRTUALSCREEN
    winX := mx + offX
    winY := my + offY
    if (winX + CP_CANVAS > sW)
        winX := mx - CP_CANVAS - offX
    if (winY + CP_CANVAS + 30 > sH)
        winY := my - CP_CANVAS - 30 - offY
    cpZoomGui.Move(winX, winY)
}

ColorPickCleanup() {
    global isPickingColor, cpZoomGui
    isPickingColor := false
    SetTimer(ColorPickLoop, 0)
    if (IsObject(cpZoomGui))
        cpZoomGui.Destroy()
    cpZoomGui := ""
}

BrowseForExe(*) {
    global ActionValue, ActionType
    type := ActionType.Text
    if (type = "🔍 Find Image")
        path := FileSelect("3", , "Select an image file", "Image Files (*.png; *.bmp; *.gif)")
    else if (type = "📜 Run PowerShell")
        path := FileSelect("3", , "Select a PowerShell script", "PowerShell Script (*.ps1)")
    else
        path := FileSelect("3", , "Select a program to open", "Programs (*.exe)")
    if (path != "")
        ActionValue.Text := path
}

OnTypeChange(*) {
    type := ActionType.Text
    if (IsSeparator(type) || type = "") {
        ; Skip to the next valid (non-separator) item automatically
        cur  := ActionType.Value
        next := cur + 1
        loop AllActionTypes.Length {
            if (next > AllActionTypes.Length)
                next := 1
            if (!IsSeparator(AllActionTypes[next]) && AllActionTypes[next] != "") {
                ActionType.Choose(next)
                return   ; OnTypeChange fires again with the valid type
            }
            next++
        }
        return
    }

    isMouseType := (InStr(type, "Click") || InStr(type, "Move Mouse") || type = "🖱️ Drag")
    isColorType := (type = "🎨 Wait for Color")
    showMod     := IsModifierType(type)
    hint        := HintForType(type)

    ; Show/hide hint label
    HintLabel.Text    := hint
    HintLabel.Visible := (hint != "")

    ; Modifier/capture/color rows sit at y=146 normally, or y=170 when hint is showing
    rowY := (hint != "") ? 170 : 146
    LblModRow.Move(, rowY)
    ChkCtrl.Move(,    rowY - 2)
    ChkAlt.Move(,     rowY - 2)
    ChkShift.Move(,   rowY - 2)
    ChkWin.Move(,     rowY - 2)
    LblSymbols.Move(, rowY + 1)
    LblCaptureRow.Move(,  rowY)
    BtnCapture.Move(,     rowY - 4)
    LblCaptureHint.Move(, rowY + 1)
    LblColorRow.Move(,    rowY)
    BtnPickColor.Move(,   rowY - 4)
    BtnColorMode.Move(,   rowY - 4)
    LblColorHint.Move(,   rowY + 1)

    LblModRow.Visible  := showMod
    ChkCtrl.Visible    := showMod
    ChkAlt.Visible     := showMod
    ChkShift.Visible   := showMod
    ChkWin.Visible     := showMod
    LblSymbols.Visible := showMod

    LblCaptureRow.Visible  := isMouseType
    BtnCapture.Visible     := isMouseType
    LblCaptureHint.Visible := isMouseType

    LblColorRow.Visible    := isColorType
    BtnPickColor.Visible   := isColorType
    BtnColorMode.Visible   := isColorType
    LblColorHint.Visible   := isColorType

    BtnBrowse.Visible      := (type = "🚀 Open Program" || type = "🔍 Find Image" || type = "🔫 Kill Process")

    ; Enable live search for types with large/dynamic lists
    global isSearchableType, lastSearchText
    isSearchableType := !IsAutoType(type) && (type = "🚀 Open Program" || type = "🔫 Kill Process"
        || InStr(type, "Window") || InStr(type, "📊 Var:")
        || (ValuePresets.Has(type) && ValuePresets[type].Length > 6))
    lastSearchText := ""
    if (isSearchableType)
        SetTimer(ValueSearchTick, 120)
    else
        SetTimer(ValueSearchTick, 0)


    ChkCtrl.Value  := 0
    ChkAlt.Value   := 0
    ChkShift.Value := 0
    ChkWin.Value   := 0
    LblSymbols.Text := ""
    PopulateValues(ActionValue)
}

TrackRow(LV, row, *) {
    global selectedRow
    selectedRow := row
}

; =============================================
;   Action Management
; =============================================

AddAction(*) {
    global actionList, ListView

    type := ActionType.Text
    if (IsSeparator(type) || type = "") {
        MsgBox("Please select a valid action type!", "Error", "Icon!")
        return
    }
    ActionType.Add(AllActionTypes)
    raw   := Trim(ActionValue.Text)
    delay := Trim(ActionDelay.Value)
    if (!IsAutoType(type) && (raw = "" || raw = "(automatic)")) {
        MsgBox("Please enter or select a value!", "Error", "Icon!")
        return
    }
    if (!IsInteger(delay) || Integer(delay) < 0) {
        MsgBox("Delay must be a positive number!", "Error", "Icon!")
        return
    }
    mods  := IsModifierType(type) ? BuildMods() : ""
    value := IsAutoType(type) ? "(auto)" : raw

    SaveSnapshot()
    actionList.Push({ type: type, value: value, mods: mods, delay: Integer(delay) })
    ListView.Add("", actionList.Length, type, BuildDisplay(type, value, mods), delay)
}

DelRow(*) {
    global actionList, ListView, selectedRow
    row := ListView.GetNext(0, "Focused")
    if (!row || row > actionList.Length) {
        MsgBox("Please select an action first.", "Hint", "Icon!")
        return
    }
    SaveSnapshot()
    actionList.RemoveAt(row)
    ListView.Delete(row)
    selectedRow := 0
    loop ListView.GetCount() {
        ListView.Modify(A_Index, "", A_Index)
    }
}

ClearAll(*) {
    global actionList, ListView
    if (MsgBox("Really delete all actions?", "Confirm", "YesNo Icon?") = "Yes") {
        SaveSnapshot()
        actionList := []
        ListView.Delete()
    }
}

MoveUp(*) {
    global actionList, ListView, selectedRow
    row := ListView.GetNext(0, "Focused")
    if (!row || row = 1) {
        return
    }
    SaveSnapshot()
    tmp               := actionList[row]
    actionList[row]   := actionList[row-1]
    actionList[row-1] := tmp
    UpdateRow(row-1)
    UpdateRow(row)
    selectedRow := row-1
    ListView.Modify(row-1, "Select Focus Vis")
}

MoveDown(*) {
    global actionList, ListView, selectedRow
    row := ListView.GetNext(0, "Focused")
    if (!row || row = actionList.Length) {
        return
    }
    SaveSnapshot()
    tmp               := actionList[row]
    actionList[row]   := actionList[row+1]
    actionList[row+1] := tmp
    UpdateRow(row)
    UpdateRow(row+1)
    selectedRow := row+1
    ListView.Modify(row+1, "Select Focus Vis")
}

; Update a single ListView row from actionList without full rebuild
UpdateRow(r) {
    global actionList, ListView
    a    := actionList[r]
    mods := a.HasOwnProp("mods") ? a.mods : ""
    ListView.Modify(r, "", r, a.type, BuildDisplay(a.type, a.value, mods), a.delay)
}

RebuildList() {
    global actionList, ListView
    ListView.Delete()
    for i, a in actionList {
        mods := a.HasOwnProp("mods") ? a.mods : ""
        ListView.Add("", i, a.type, BuildDisplay(a.type, a.value, mods), a.delay)
    }
}

; =============================================
;   Edit Dialog
; =============================================

EditAction(LV, row) {
    global actionList, ListView, AllActionTypes, ValuePresets
    if (!row) {
        return
    }
    a := actionList[row]
    storedMods := a.HasOwnProp("mods") ? a.mods : ""

    D := Gui("+Owner" MyGui.Hwnd, "Edit Action")
    D.SetFont("s10", "Segoe UI")
    D.BackColor := "13131F"
    D.SetFont("s9 cDDDDDD")

    D.Add("Text", "x10 y10", "Action Type:")
    dType := D.Add("DropDownList", "x10 y28 w340 vType", AllActionTypes)
    idx := 1
    loop AllActionTypes.Length {
        if (AllActionTypes[A_Index] = a.type) {
            idx := A_Index
            break
        }
    }
    dType.Choose(idx)

    D.Add("Text", "x10 y63", "Modifier Keys:")
    dCtrl  := D.Add("CheckBox", "x10  y81 w60 vCtrl  cFFFFFF", "Ctrl")
    dAlt   := D.Add("CheckBox", "x72  y81 w55 vAlt   cFFFFFF", "Alt")
    dShift := D.Add("CheckBox", "x129 y81 w60 vShift cFFFFFF", "Shift")
    dWin   := D.Add("CheckBox", "x191 y81 w55 vWin   cFFFFFF", "Win")
    dSyms  := D.Add("Text",     "x248 y84 w100 c5588FF", "")

    dCtrl.Value  := InStr(storedMods, "^") ? 1 : 0
    dAlt.Value   := InStr(storedMods, "!") ? 1 : 0
    dShift.Value := InStr(storedMods, "+") ? 1 : 0
    dWin.Value   := InStr(storedMods, "#") ? 1 : 0

    RefreshDSyms()
    dCtrl.OnEvent("Click",  RefreshDSyms)
    dAlt.OnEvent("Click",   RefreshDSyms)
    dShift.OnEvent("Click", RefreshDSyms)
    dWin.OnEvent("Click",   RefreshDSyms)

    D.Add("Text", "x10 y112", "Value:")
    dValue  := D.Add("ComboBox", "x10 y130 w295 vValue Background1E1E32 c8899BB", [])
    dBrowse := D.Add("Button",   "x308 y128 w42 h26", "📂")
    dBrowse.Visible := (a.type = "🚀 Open Program" || a.type = "🔍 Find Image")
    dBrowse.OnEvent("Click", DoBrowse)
    RefillDValues(a.type)
    ; For Notification, the 3rd field (sound) lives in its own dropdown —
    ; show only "title | message" in the value box.
    if (a.type = "🔔 Notification" && a.value != "(auto)") {
        np := StrSplit(a.value, "|")
        if (np.Length >= 2)
            dValue.Text := Trim(np[1]) " | " Trim(np[2])
        else
            dValue.Text := a.value
    } else {
        dValue.Text := (a.value = "(auto)") ? "" : a.value
    }

    D.SetFont("s7 c556699")
    dHint := D.Add("Text", "x10 y157 w340 h28", "")
    D.SetFont("s9 cDDDDDD")
    dHint.Text    := HintForType(a.type)
    dHint.Visible := (HintForType(a.type) != "")

    D.Add("Text", "x10 y190", "Delay (ms):")
    dDelay := D.Add("Edit", "x10 y208 w340 vDelay Background1E1E32 cFFFFFF", a.delay)

    ; --- Notification sound row (only shown for 🔔 Notification) ---
    dSoundLbl := D.Add("Text", "x10 y244", "Sound:")
    dSound    := D.Add("DropDownList", "x10 y262 w250 vSound Background1E1E32 cFFFFFF", BuildSoundList())
    dPreview  := D.Add("Button", "x265 y260 w85 h26", "▶ Preview")
    dPreview.OnEvent("Click", PreviewSound)

    ; Pre-select the saved sound (3rd field of value), default "notify"
    InitSoundChoice()

    ShowSoundRow(a.type = "🔔 Notification")

    dType.OnEvent("Change", OnDTypeChange)

    okBtn     := D.Add("Button", "x10  y300 w160 h32 Default", "✅  Save")
    cancelBtn := D.Add("Button", "x190 y300 w160 h32",         "❌  Cancel")
    okBtn.OnEvent("Click",     DoSave)
    cancelBtn.OnEvent("Click", (*) => D.Destroy())

    D.Show("w360 h348")

    DoBrowse(*) {
        t := dType.Text
        if (t = "🔍 Find Image")
            p := FileSelect("3",,"Select an image file","Image Files (*.png; *.bmp; *.gif)")
        else
            p := FileSelect("3",,"Select a program","Programs (*.exe)")
        if (p != "")
            dValue.Text := p
    }

    ; Build dropdown entries: presets first, separator, then every .wav in Media
    BuildSoundList() {
        list := []
        for name, _ in ToastSoundPresets()
            list.Push(name)
        list.Push("default")
        list.Push("──────────")
        loop files A_WinDir "\Media\*.wav" {
            list.Push(A_LoopFileName)
        }
        return list
    }

    ; Select the sound stored in the 3rd value field (if any)
    InitSoundChoice() {
        cur := ""
        p := StrSplit(a.value, "|")
        if (p.Length >= 3)
            cur := Trim(p[3])
        if (cur = "")
            cur := "notify"
        try {
            dSound.Choose(cur)
        } catch {
            try dSound.Choose("notify")
        }
    }

    ShowSoundRow(show) {
        dSoundLbl.Visible := show
        dSound.Visible    := show
        dPreview.Visible  := show
    }

    PreviewSound(*) {
        sel := dSound.Text
        if (sel = "" || InStr(sel, "──"))
            return
        PlayToastSound(sel)
    }

    RefreshDSyms(*) {
        m := (dCtrl.Value ? "^" : "") . (dAlt.Value ? "!" : "") . (dShift.Value ? "+" : "") . (dWin.Value ? "#" : "")
        dSyms.Text := (m = "") ? "" : "[" m "]"
    }

    RefillDValues(t) {
        dValue.Delete()
        if (IsAutoType(t)) {
            dValue.Add(["(automatic)"])
            dValue.Choose(1)
            dValue.Enabled := false
            return
        }
        dValue.Enabled := true
        if (t = "🚀 Open Program") {
            global FriendlyApps
            for name, _ in FriendlyApps
                dValue.Add([name])
            try dValue.Choose(1)
        } else if (InStr(t, "Window")) {
            dValue.Add(["Current Window"])
            seen := Map()
            for hwnd in WinGetList() {
                try {
                    proc := WinGetProcessName(hwnd)
                    if (proc != "" && !seen.Has(proc) && proc != "AutoHotkey64.exe" && proc != "AutoHotkey32.exe") {
                        seen[proc] := true
                        dValue.Add([proc])
                    }
                }
            }
            try dValue.Choose(1)
        } else if (InStr(t, "📊 Var:")) {
            presets := BuildVarPresets(t)
            for e in presets
                dValue.Add([e])
            try dValue.Choose(1)
        } else if (ValuePresets.Has(t)) {
            for v in ValuePresets[t] {
                dValue.Add([v])
            }
            try dValue.Choose(1)
        } else {
            dValue.Text := ""
        }
    }

    OnDTypeChange(*) {
        t := dType.Text
        if (IsSeparator(t)) {
            dType.Choose(dType.Value + 1)
            t := dType.Text
        }
        RefillDValues(t)
        h := HintForType(t)
        dHint.Text    := h
        dHint.Visible := (h != "")
        dBrowse.Visible := (t = "🚀 Open Program" || t = "🔍 Find Image")
        ShowSoundRow(t = "🔔 Notification")
    }

    DoSave(*) {
        rawVal := dValue.Text
        saved  := D.Submit()
        t := saved.Type
        if (IsSeparator(t)) {
            return
        }
        SaveSnapshot()
        m := (saved.Ctrl ? "^" : "") . (saved.Alt ? "!" : "") . (saved.Shift ? "+" : "") . (saved.Win ? "#" : "")
        v := IsAutoType(t) ? "(auto)" : rawVal

        ; For Notification, attach the chosen sound as the 3rd field:
        ; title | message | sound  (keep only the first two user fields)
        if (t = "🔔 Notification") {
            snd := dSound.Text
            if (snd = "" || InStr(snd, "──"))
                snd := "notify"
            p := StrSplit(rawVal, "|")
            title := (p.Length >= 1) ? Trim(p[1]) : "Key Flow"
            msg   := (p.Length >= 2) ? Trim(p[2]) : ""
            v := title " | " msg " | " snd
        }

        actionList[row].type  := t
        actionList[row].value := v
        actionList[row].mods  := m
        actionList[row].delay := Integer(saved.Delay)
        ListView.Modify(row, "", row, t, BuildDisplay(t, v, m), saved.Delay)
        D.Destroy()
    }
}

; =============================================
;   Automation Engine
; =============================================

StartAuto(*) {
    global isRunning, isPaused, runLoop, actionList, StatusLabel
    if (actionList.Length = 0) {
        MsgBox("No actions in the list!", "Hint", "Icon!")
        return
    }
    if (isRunning) {
        return
    }
    isRunning := true
    isPaused  := false
    runLoop   := true
    varStore.Clear()
    jumpTarget := 0
    StatusLabel.Text := "RUNNING"
    StatusLabel.Opt("Background00AA55")
    SetTimer(RunActions, -50)
}

RunActions() {
    global isRunning, isPaused, runLoop, actionList, StatusLabel, RepeatCount, LoopDelay, jumpTarget, varStore, SpeedDDL, JitterEdit
    maxRuns  := Max(0, SafeInt(RepeatCount.Value, 1))   ; 0 = infinite, blank/junk → 1
    loopWait := Max(0, SafeInt(LoopDelay.Value, 1000))
    smText   := SpeedDDL.Text
    sm       := SafeNum(RegExReplace(smText, "x$", ""), 1)
    sm       := (sm > 0) ? sm : 1                        ; guard against 0x speed
    ji       := Max(0, SafeInt(JitterEdit.Value, 0))
    runCount := 0
    CreateOSD()
    while (runLoop) {
        while (isPaused && runLoop) {
            Sleep(100)
        }
        if (!runLoop) {
            break
        }
        i := 1
        while (i <= actionList.Length && runLoop) {
            while (isPaused && runLoop) {
                Sleep(100)
            }
            if (!runLoop) {
                break
            }
            a := actionList[i]
            ListView.Modify(i, "Select Focus Vis")
            UpdateOSD(a.type, runCount + 1, maxRuns)
            DoAction(a)
            rawDelay := Round(a.delay * sm)
            rawDelay += (ji > 0) ? Random(-ji, ji) : 0
            Sleep(Max(0, rawDelay))
            if (jumpTarget > 0) {
                ; clamp to a valid row; invalid target just continues sequentially
                i := (jumpTarget <= actionList.Length) ? jumpTarget : i + 1
                jumpTarget := 0
            } else {
                i++
            }
        }
        runCount++
        if (maxRuns > 0 && runCount >= maxRuns) {
            break
        }
        Sleep(loopWait)
    }
    isRunning := false
    runLoop   := false
    isPaused  := false
    StatusLabel.Text := "STOPPED"
    StatusLabel.Opt("BackgroundFF3355")
    DestroyOSD()
    ListView.Modify(0, "-Select")
}

; =============================================
;   Action Execution  (Map-based dispatch)
; =============================================
; Each handler receives the resolved action object `a`.
; `a.value`  = raw stored value (may contain "|", "$var", etc.)
; `value`    = ToAhk()-converted value, passed in for convenience
; Handlers are registered once in a static Map keyed by the (emoji) type
; string. This replaces the previous ~380-line if/return chain: faster
; lookup, far easier to extend (add one Map entry instead of another if).

; --- small parsing helpers shared by several handlers --------------------

; Split "x y" → [x, y] integers, or "" if not parseable
ParseCoords(s) {
    p := StrSplit(Trim(s), " ")
    if (p.Length >= 2 && IsInteger(p[1]) && IsInteger(p[2]))
        return [Integer(p[1]), Integer(p[2])]
    return ""
}

; Perform a click at "Current Position"/blank or "x y", with an optional
; trailing option string ("Right", "2", "Middle", ...)
DoClick(value, opt := "") {
    if (value = "Current Position" || value = "") {
        (opt = "") ? Click() : Click(opt)
        return
    }
    c := ParseCoords(value)
    if (c)
        Click(c[1] " " c[2] (opt != "" ? " " opt : ""))
    else
        (opt = "") ? Click() : Click(opt)
}

; Numeric variable read — non-numeric stored values fall back to 0
VarNum(name, default := 0) {
    global varStore
    return (varStore.Has(name) && IsNumber(varStore[name])) ? Number(varStore[name]) : default
}

; Window target helper: "Current Window"/blank → "A", else by exe name
WinTarget(value) {
    return (value = "Current Window" || value = "") ? "A" : "ahk_exe " value
}

DoAction(a) {
    static handlers := BuildActionHandlers()
    type  := a.type
    mods  := a.HasOwnProp("mods") ? a.mods : ""
    value := ToAhk(type, a.value, mods)
    if (handlers.Has(type))
        handlers[type](a, value)
    ; unknown types are silently ignored (same as old behaviour)
}

BuildActionHandlers() {
    h := Map()

    ; --- keyboard / text ---
    h["⌨️ Press Key"]    := (a, value) => Send(value)
    h["🔗 Hotkey Combo"]  := (a, value) => Send(value)
    h["✏️ Type Text"]     := (a, value) => SendText(value)
    h["💬 Comment"]       := (a, value) => 0   ; no-op

    ; --- mouse clicks ---
    h["🖱️ Left Click"]    := (a, value) => DoClick(value)
    h["🖱️ Right Click"]   := (a, value) => DoClick(value, "Right")
    h["🖱️ Double Click"]  := (a, value) => DoClick(value, "2")
    h["🖱️ Middle Click"]  := (a, value) => DoClick(value, "Middle")
    h["🖱️ Hold Left"]     := (a, value) => Send("{LButton Down}")
    h["🖱️ Release Left"]  := (a, value) => Send("{LButton Up}")
    h["🖱️ Hold Right"]    := (a, value) => Send("{RButton Down}")
    h["🖱️ Release Right"] := (a, value) => Send("{RButton Up}")

    h["🖱️ Drag"] := (a, value) => DoDrag(value)

    ; --- mouse movement / scroll ---
    h["➡️ Move Mouse"] := (a, value) => (c := ParseCoords(value)) ? MouseMove(c[1], c[2]) : 0
    h["🔼 Scroll Up"]   := (a, value) => Send("{WheelUp "   (IsInteger(value) ? value : 3) "}")
    h["🔽 Scroll Down"] := (a, value) => Send("{WheelDown " (IsInteger(value) ? value : 3) "}")

    ; --- color / image ---
    h["🎨 Wait for Color"] := (a, value) => DoWaitForColor(value)
    h["🔍 Find Image"]     := (a, value) => DoFindImage(a.value)

    ; --- clipboard / edit shortcuts ---
    h["📋 Copy"]       := (a, value) => Send("^c")
    h["📋 Paste"]      := (a, value) => Send("^v")
    h["✂️ Cut"]        := (a, value) => Send("^x")
    h["↩️ Undo"]       := (a, value) => Send("^z")
    h["🔲 Select All"] := (a, value) => Send("^a")

    ; --- system ---
    h["🔇 Mute Toggle"] := (a, value) => Send("{Volume_Mute}")
    h["📸 Screenshot"]  := (a, value) => Send("{PrintScreen}")
    h["🔒 Lock PC"]     := (a, value) => DllCall("LockWorkStation")

    h["🔊 Volume Up"]   := (a, value) => DoVolume("{Volume_Up}",   IsInteger(value) ? Integer(value) : 2)
    h["🔉 Volume Down"] := (a, value) => DoVolume("{Volume_Down}", IsInteger(value) ? Integer(value) : 2)

    h["⏳ Wait (ms)"] := (a, value) => Sleep(IsInteger(value) ? Integer(value) : 1000)

    ; --- notifications / launch ---
    h["🔔 Notification"]  := (a, value) => DoNotification(a.value)
    h["🌐 Open URL"]      := (a, value) => DoOpenUrl(value)
    h["🚀 Open Program"]  := (a, value) => DoOpenProgram(value)

    ; --- window control ---
    h["➖ Minimize Window"] := (a, value) => SafeWin(WinMinimize, value)
    h["⬜ Maximize Window"] := (a, value) => SafeWin(WinMaximize, value)
    h["❌ Close Window"]    := (a, value) => SafeWin(WinClose,    value)

    ; --- variables ---
    h["📊 Var: Set"]    := (a, value) => DoVarSet(a.value)
    h["📊 Var: Add"]    := (a, value) => DoVarMath(a.value, 1)
    h["📊 Var: Sub"]    := (a, value) => DoVarMath(a.value, -1)
    h["📊 Var: Set If"] := (a, value) => DoVarSetIf(a.value)
    h["📊 Var: Random"] := (a, value) => DoVarRandom(a.value)

    h["📋 Var: From Clipboard"] := (a, value) => DoVarFromClip(a.value)
    h["🖱️ Var: Mouse Pos"]      := (a, value) => DoVarMousePos(a.value)
    h["🪟 Var: Win Title"]      := (a, value) => DoVarWinTitle(a.value)

    ; --- flow control ---
    h["🔁 Repeat Key"]   := (a, value) => DoRepeatKey(a.value)
    h["🔁 Jump To"]      := (a, value) => SetJump(a.value)
    h["🛑 Stop Sequence"] := (a, value) => StopSequence()

    ; --- process / scripting ---
    h["🔫 Kill Process"]  := (a, value) => DoKillProcess(value)
    h["📜 Run PowerShell"] := (a, value) => DoRunPowerShell(value)

    return h
}

; =============================================
;   Action handler implementations
; =============================================

DoDrag(value) {
    sep := InStr(value, "|")
    if (sep <= 0)
        return
    p1 := ParseCoords(SubStr(value, 1, sep - 1))
    p2 := ParseCoords(SubStr(value, sep + 1))
    if (p1 && p2)
        MouseClickDrag("Left", p1[1], p1[2], p2[1], p2[2])
}

DoWaitForColor(value) {
    ; Format: x y | RRGGBB | w h | MODE   (fallback: x y | RRGGBB)
    parts := StrSplit(value, "|")
    if (parts.Length < 2)
        return
    coords := ParseCoords(parts[1])
    if (!coords)
        return
    hexColor := Trim(parts[2])
    if (!RegExMatch(hexColor, "^[0-9A-Fa-f]{6}$"))
        return
    wh   := (parts.Length >= 3) ? StrSplit(Trim(parts[3]), " ") : ["1", "1"]
    mode := (parts.Length >= 4) ? Trim(parts[4]) : "ANY"
    rW   := (wh.Length >= 1 && IsInteger(Trim(wh[1]))) ? Max(1, Integer(Trim(wh[1]))) : 1
    rH   := (wh.Length >= 2 && IsInteger(Trim(wh[2]))) ? Max(1, Integer(Trim(wh[2]))) : 1
    targetColor := Integer("0x" hexColor)
    cx := coords[1], cy := coords[2]

    prevMode := A_CoordModePixel
    CoordMode("Pixel", "Screen")
    timeout := A_TickCount + 10000   ; 10 second timeout
    loop {
        matched := false
        try {
            if (mode = "AVG") {
                rTotal := 0, gTotal := 0, bTotal := 0, count := 0
                loop rH {
                    py := cy - rH // 2 + A_Index - 1
                    loop rW {
                        px := cx - rW // 2 + A_Index - 1
                        c := PixelGetColor(px, py)
                        rTotal += (c >> 16) & 0xFF
                        gTotal += (c >> 8)  & 0xFF
                        bTotal +=  c        & 0xFF
                        count++
                    }
                }
                if (count > 0) {
                    avgColor := (Round(rTotal / count) << 16) | (Round(gTotal / count) << 8) | Round(bTotal / count)
                    matched := (avgColor = targetColor)
                }
            } else {
                loop rH {
                    py := cy - rH // 2 + A_Index - 1
                    loop rW {
                        px := cx - rW // 2 + A_Index - 1
                        if (PixelGetColor(px, py) = targetColor) {
                            matched := true
                            break
                        }
                    }
                    if (matched)
                        break
                }
            }
        }
        if (matched || A_TickCount > timeout)
            break
        Sleep(50)
    }
    CoordMode("Pixel", prevMode)   ; restore previous mode
}

DoFindImage(imgPath) {
    if (!FileExist(imgPath))
        return
    prevMode := A_CoordModePixel
    CoordMode("Pixel", "Screen")
    try {
        if (ImageSearch(&foundX, &foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, imgPath))
            Click(foundX " " foundY)
    }
    CoordMode("Pixel", prevMode)
}

DoVolume(key, amt) {
    loop Max(0, amt)
        Send(key)
}

DoNotification(raw) {
    ; Format: title | message | sound    (sound optional → defaults to "notify")
    parts := StrSplit(raw, "|")
    if (parts.Length >= 2) {
        title := Trim(ResolveVar(parts[1]))
        msg   := Trim(ResolveVar(parts[2]))
        sound := (parts.Length >= 3 && Trim(parts[3]) != "") ? Trim(parts[3]) : "notify"
    } else {
        title := "Key Flow"
        msg   := Trim(ResolveVar(raw))
        sound := "notify"
    }
    ShowToast(title, msg, 3000, sound)
}

; Self-contained on-screen toast — bypasses Windows' TrayTip system entirely,
; so it shows regardless of notification / Focus Assist settings.
; Auto-closes after `durationMs` without blocking the running sequence.
ShowToast(title, msg, durationMs := 3000, sound := "notify") {
    global toastGui

    ; Play a Windows system sound so the toast is also audible.
    PlayToastSound(sound)

    ; Tear down any previous toast still on screen
    if (IsObject(toastGui)) {
        try toastGui.Destroy()
        toastGui := ""
    }
    SetTimer(CloseToast, 0)   ; cancel a pending auto-close from a prior toast

    if (msg = "")
        msg := " "

    w := 300
    toastGui := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000") ; WS_EX_NOACTIVATE
    toastGui.BackColor := "0D0D1A"
    toastGui.MarginX   := 14
    toastGui.MarginY   := 12

    toastGui.SetFont("s9 Bold cAABBFF", "Segoe UI")
    toastGui.Add("Text", "x14 y12 w" (w - 28), "🔔  " title)

    toastGui.SetFont("s10 cFFFFFF", "Segoe UI")
    ; Auto-height message label so longer text isn't clipped
    msgCtrl := toastGui.Add("Text", "x14 y34 w" (w - 28), msg)
    msgCtrl.GetPos(, , , &mh)
    h := 34 + mh + 14

    WinSetTransparent(235, toastGui)
    ; Bottom-right corner, above the taskbar
    x := A_ScreenWidth  - w - 20
    y := A_ScreenHeight - h - 60
    toastGui.Show("x" x " y" y " w" w " h" h " NoActivate")

    SetTimer(CloseToast, -durationMs)   ; negative = run once
}

CloseToast() {
    global toastGui
    if (IsObject(toastGui)) {
        try toastGui.Destroy()
        toastGui := ""
    }
}

; Built-in sound presets → file in C:\Windows\Media (single source of truth,
; used by both PlayToastSound and the Edit dialog dropdown).
ToastSoundPresets() {
    return Map(
        "notify", "Windows Notify System Generic.wav",
        "ding",   "Windows Ding.wav",
        "chime",  "Windows Notify.wav",
        "alert",  "Windows Background.wav",
        "error",  "Windows Critical Stop.wav"
    )
}

; Play a toast sound. Accepts: a preset name ("notify"...), "default"/""
; (system default), a bare .wav filename from C:\Windows\Media, or a full path.
PlayToastSound(name := "notify") {
    name := Trim(name)
    presets := ToastSoundPresets()

    if (name = "" || name = "default") {
        try SoundPlay("*-1")
        return
    }
    if (presets.Has(name)) {
        path := A_WinDir "\Media\" presets[name]
    } else if (InStr(name, "\")) {
        path := name                      ; full path given
    } else {
        path := A_WinDir "\Media\" name   ; bare filename → assume Media folder
    }

    if (FileExist(path)) {
        try SoundPlay(path)               ; async, doesn't block the sequence
    } else {
        try SoundPlay("*-1")              ; fallback: default system sound
    }
}

DoOpenUrl(value) {
    url := Trim(value)
    if (url = "")
        return
    if (SubStr(url, 1, 4) != "http")
        url := "https://" url
    SafeRun(url)
}

DoOpenProgram(value) {
    global FriendlyApps
    if (value = "" || value = "── Running ──")
        return
    target := FriendlyApps.Has(value) ? FriendlyApps[value] : value
    SafeRun(target)
}

; Run a window action, ignoring "target not found" errors
SafeWin(fn, value) {
    try fn(WinTarget(value))
}

DoVarSet(raw) {
    global varStore
    sep := InStr(raw, "|")
    if (sep <= 0)
        return
    varStore[Trim(SubStr(raw, 1, sep - 1))] := Trim(SubStr(raw, sep + 1))
}

; sign = +1 for Add, -1 for Sub
DoVarMath(raw, sign) {
    global varStore
    sep := InStr(raw, "|")
    if (sep <= 0)
        return
    name := Trim(SubStr(raw, 1, sep - 1))
    amt  := SafeInt(ResolveVar(Trim(SubStr(raw, sep + 1))), 0)
    varStore[name] := VarNum(name, 0) + sign * amt
}

DoVarSetIf(raw) {
    global varStore
    parts := StrSplit(raw, "|")
    if (parts.Length < 4)
        return
    name  := Trim(parts[1])
    op    := Trim(parts[2])
    check := SafeNum(Trim(parts[3]), 0)
    cur   := VarNum(name, 0)
    match := (op = "==" && cur =  check)
          || (op = "!=" && cur != check)
          || (op = ">"  && cur >  check)
          || (op = "<"  && cur <  check)
          || (op = ">=" && cur >= check)
          || (op = "<=" && cur <= check)
    if (match)
        varStore[name] := Trim(parts[4])
}

DoVarRandom(raw) {
    global varStore
    parts := StrSplit(raw, "|")
    if (parts.Length < 3)
        return
    name := Trim(parts[1])
    mn   := SafeInt(ResolveVar(parts[2]), 0)
    mx   := SafeInt(ResolveVar(parts[3]), 0)
    if (mn > mx) {   ; tolerate swapped bounds
        tmp := mn, mn := mx, mx := tmp
    }
    varStore[name] := Random(mn, mx)
}

DoVarFromClip(raw) {
    global varStore
    name := Trim(raw)
    if (name != "")
        varStore[name] := A_Clipboard
}

DoVarMousePos(raw) {
    global varStore
    sep := InStr(raw, "|")
    if (sep <= 0)
        return
    vx := Trim(SubStr(raw, 1, sep - 1))
    vy := Trim(SubStr(raw, sep + 1))
    MouseGetPos(&px, &py)
    varStore[vx] := px
    varStore[vy] := py
}

DoVarWinTitle(raw) {
    global varStore
    name := Trim(raw)
    if (name = "")
        return
    try varStore[name] := WinGetTitle("A")
}

DoRepeatKey(raw) {
    sep := InStr(raw, "|")
    if (sep <= 0)
        return
    key   := ToAhk("⌨️ Press Key", Trim(SubStr(raw, 1, sep - 1)), "")
    count := Max(0, ResolveInt(Trim(SubStr(raw, sep + 1)), 0))
    loop count
        Send(key)
}

SetJump(raw) {
    global jumpTarget
    jumpTarget := Max(0, SafeInt(raw, 0))   ; out-of-range handled in RunActions
}

StopSequence() {
    global runLoop
    runLoop := false
}

DoKillProcess(value) {
    if (value = "")
        return
    SplitPath(value, &exeName)
    target := (exeName != "") ? exeName : value
    try RunWait("taskkill /F /IM " target, , "Hide")
}

DoRunPowerShell(value) {
    if (value = "")
        return
    if (SubStr(StrLower(value), -3) = ".ps1")
        SafeRun('powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "' value '"')
    else
        SafeRun('powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -Command "' value '"')
}


PauseAuto(*) {
    global isRunning, isPaused, StatusLabel
    if (!isRunning) {
        return
    }
    isPaused := !isPaused
    if (isPaused) {
        StatusLabel.Text := "PAUSED"
        StatusLabel.Opt("BackgroundDD8800")
    } else {
        StatusLabel.Text := "RUNNING"
        StatusLabel.Opt("Background00AA55")
    }
}

StopAuto(*) {
    global isRunning, isPaused, runLoop, StatusLabel
    runLoop   := false
    isPaused  := false
    isRunning := false
    StatusLabel.Text := "STOPPED"
    StatusLabel.Opt("BackgroundFF3355")
    DestroyOSD()
}

; =============================================
;   Undo / Redo
; =============================================

SaveSnapshot() {
    global undoStack, redoStack, actionList
    snap := []
    for a in actionList
        snap.Push({ type: a.type, value: a.value, mods: (a.HasOwnProp("mods") ? a.mods : ""), delay: a.delay })
    undoStack.Push(snap)
    if (undoStack.Length > 50)
        undoStack.RemoveAt(1)
    redoStack := []
}

Undo(*) {
    global undoStack, redoStack, actionList
    if (undoStack.Length = 0)
        return
    snap := []
    for a in actionList
        snap.Push({ type: a.type, value: a.value, mods: (a.HasOwnProp("mods") ? a.mods : ""), delay: a.delay })
    redoStack.Push(snap)
    actionList := undoStack.Pop()
    RebuildList()
}

Redo(*) {
    global undoStack, redoStack, actionList
    if (redoStack.Length = 0)
        return
    snap := []
    for a in actionList
        snap.Push({ type: a.type, value: a.value, mods: (a.HasOwnProp("mods") ? a.mods : ""), delay: a.delay })
    undoStack.Push(snap)
    actionList := redoStack.Pop()
    RebuildList()
}

; =============================================
;   Save / Load
; =============================================

; Strip leading emoji/non-ASCII chars for clean plain-text export
StripEmoji(s) {
    return Trim(RegExReplace(s, "^[^\x00-\x7F]+\s*", ""))
}

; Find full type name (with emoji) from a plain stripped name
FindType(plain) {
    global AllActionTypes
    for t in AllActionTypes {
        if (Trim(RegExReplace(t, "^[^\x00-\x7F]+\s*", "")) = plain)
            return t
    }
    return plain
}

; Escape a field so "|" and newlines survive a round-trip.
; \  → \\ ,  |  → \p ,  `n → \n ,  `r → (dropped)
EscapeField(s) {
    s := StrReplace(s, "\", "\\")
    s := StrReplace(s, "|", "\p")
    s := StrReplace(s, "`r", "")
    s := StrReplace(s, "`n", "\n")
    return s
}

UnescapeField(s) {
    ; reverse order matters: handle \\ last via placeholder
    s := StrReplace(s, "\\", "`r`r")   ; temp marker for literal backslash
    s := StrReplace(s, "\p", "|")
    s := StrReplace(s, "\n", "`n")
    s := StrReplace(s, "`r`r", "\")
    return s
}

SaveProfile(*) {
    global actionList
    file := FileSelect("S16", "MyProfile.txt", "Save Profile", "Text File (*.txt)")
    if (!file) {
        return
    }
    ; v2 format marker so the loader knows fields are escaped.
    content := "#KEYFLOW v2`n"
    for a in actionList {
        mods := a.HasOwnProp("mods") ? a.mods : ""
        ; Format: type|delay|mods|value  — all fields escaped (no raw | or newlines)
        content .= EscapeField(StripEmoji(a.type)) "|" a.delay "|" EscapeField(mods) "|" EscapeField(a.value) "`n"
    }
    try {
        f := FileOpen(file, "w", "UTF-8")
        if (!f) {
            MsgBox("Could not open file for writing.", "Error", "Icon!")
            return
        }
        f.Write(content)
        f.Close()
        MsgBox("Profile saved!", "Success", "Icon!")
    } catch as e {
        MsgBox("Save failed: " e.Message, "Error", "Icon!")
    }
}

LoadProfile(*) {
    global actionList, ListView
    file := FileSelect(1, , "Load Profile", "Text File (*.txt)")
    if (!file || !FileExist(file)) {
        return
    }
    actionList := []
    ListView.Delete()
    isV2 := false
    loop read, file {
        line := Trim(A_LoopReadLine)
        if (line = "") {
            continue
        }
        if (A_Index = 1 && SubStr(line, 1, 9) = "#KEYFLOW ") {
            isV2 := InStr(line, "v2") > 0
            continue
        }
        if (InStr(line, "§")) {
            ; oldest format:  type§value§delay§mods
            old := StrSplit(line, "§")
            if (old.Length >= 3) {
                t     := FindType(old[1])
                val   := old[2]
                delay := IsInteger(old[3]) ? Integer(old[3]) : 0
                mods  := (old.Length >= 4) ? old[4] : ""
                actionList.Push({ type: t, value: val, delay: delay, mods: mods })
                ListView.Add("", actionList.Length, t, BuildDisplay(t, val, mods), delay)
            }
            continue
        }
        ; pipe format: type|delay|mods|value  (MaxParts=4 keeps | inside value)
        parts := StrSplit(line, "|", , 4)
        if (parts.Length >= 4) {
            t     := FindType(isV2 ? UnescapeField(parts[1]) : parts[1])
            delay := IsInteger(parts[2]) ? Integer(parts[2]) : 0
            mods  := isV2 ? UnescapeField(parts[3]) : parts[3]
            val   := isV2 ? UnescapeField(parts[4]) : parts[4]
            actionList.Push({ type: t, value: val, delay: delay, mods: mods })
            ListView.Add("", actionList.Length, t, BuildDisplay(t, val, mods), delay)
        }
    }
    MsgBox("Loaded " actionList.Length " actions.", "Success", "Icon!")
}

; =============================================
;   Example Actions
; =============================================

LoadExamples() {
    global actionList, ListView
    examples := [
        { type: "⌨️ Press Key",  value: "F5",           mods: "^", delay: 500  },
        { type: "✏️ Type Text",  value: "Hello World!", mods: "",  delay: 1000 },
        { type: "🖱️ Left Click", value: "960 540",      mods: "",  delay: 500  },
        { type: "🔽 Scroll Down",value: "3 ticks",      mods: "",  delay: 300  },
        { type: "⏳ Wait (ms)",   value: "2000 ms",      mods: "",  delay: 0    },
    ]
    for a in examples {
        actionList.Push(a)
        ListView.Add("", actionList.Length, a.type, BuildDisplay(a.type, a.value, a.mods), a.delay)
    }
}

; =============================================
;   OSD / HUD  (Feature 1: Visual Feedback)
; =============================================

CreateOSD() {
    global osdGui, osdStatusLbl, osdActionLbl, osdRepeatLbl
    DestroyOSD()
    osdGui := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale")
    osdGui.BackColor := "0D0D1A"
    osdGui.MarginX   := 0
    osdGui.MarginY   := 0
    osdGui.SetFont("s8 Bold cAABBFF", "Segoe UI")
    osdGui.Add("Text", "x10 y7 w186", "AUTO FLOW  ·  LIVE")
    osdGui.SetFont("s9 cFFFFFF", "Segoe UI")
    osdStatusLbl := osdGui.Add("Text", "x10 y24 w186", "Status: Running")
    osdGui.SetFont("s8 c88CCFF", "Segoe UI")
    osdActionLbl := osdGui.Add("Text", "x10 y40 w186", "Action: —")
    osdGui.SetFont("s8 c88FF88", "Segoe UI")
    osdRepeatLbl := osdGui.Add("Text", "x10 y56 w186", "Rep: — / —")
    WinSetTransparent(210, osdGui)
    osdGui.Show("x" (A_ScreenWidth - 214) " y10 w204 h76 NoActivate")
}

UpdateOSD(actionType, repCur, repMax) {
    global osdGui, osdActionLbl, osdRepeatLbl
    if (!IsObject(osdGui))
        return
    plain := Trim(RegExReplace(actionType, "^[^\x00-\x7F]+\s*", ""))
    osdActionLbl.Text := "Action: " plain
    osdRepeatLbl.Text := "Rep: " repCur " / " (repMax = 0 ? "∞" : repMax)
}

DestroyOSD() {
    global osdGui
    if (IsObject(osdGui))
        osdGui.Destroy()
    osdGui := ""
}

; =============================================
;   Macro Recorder  (Feature 2)
; =============================================

StartRecording(*) {
    global isRecording, isRunning, MyGui
    if (isRunning) {
        MsgBox("Stop the sequence before recording!", "Error", "Icon!")
        return
    }
    if (isRecording) {
        StopRecording()
        return
    }
    isRecording := true
    MyGui.Minimize()
    Sleep(300)
    recHook := InputHook("L0 I")
    recHook.OnKeyDown := RecordKeyDown
    recHook.Start()
    ToolTip("⏺ Recording  —  Click or type to capture.`nPress ESC to stop.", 10, 10, 3)
    SetTimer(RecordLoop, 30)
}

RecordLoop() {
    global isRecording, actionList, ListView
    if (!isRecording) {
        SetTimer(RecordLoop, 0)
        return
    }
    if (GetKeyState("Escape", "P")) {
        StopRecording()
        return
    }
    if (GetKeyState("LButton", "P")) {
        MouseGetPos(&rx, &ry)
        KeyWait("LButton")
        coords := rx " " ry
        actionList.Push({ type: "🖱️ Left Click", value: coords, mods: "", delay: 500 })
        ListView.Add("", actionList.Length, "🖱️ Left Click",
            BuildDisplay("🖱️ Left Click", coords, ""), 500)
        ToolTip("⏺ Captured: " coords "  (" actionList.Length " total)`nPress ESC to stop.", 10, 10, 3)
    }
}

RecordKeyDown(ih, vk, sc) {
    global isRecording, actionList, ListView
    if (!isRecording)
        return
    ; Skip Escape (handled by RecordLoop), and bare modifier keys
    static skipVK := Map(0x1B,1, 0x10,1, 0x11,1, 0x12,1, 0x5B,1, 0x5C,1)
    if (skipVK.Has(vk))
        return
    keyName := GetKeyName(Format("vk{:02X}", vk))
    if (keyName = "")
        return
    mods := ""
    if (GetKeyState("Ctrl",  "P")) mods .= "^"
    if (GetKeyState("Alt",   "P")) mods .= "!"
    if (GetKeyState("Shift", "P")) mods .= "+"
    if (GetKeyState("LWin",  "P") || GetKeyState("RWin", "P")) mods .= "#"
    actionList.Push({ type: "⌨️ Press Key", value: keyName, mods: mods, delay: 100 })
    ListView.Add("", actionList.Length, "⌨️ Press Key",
        BuildDisplay("⌨️ Press Key", keyName, mods), 100)
    ToolTip("⏺ Recorded: " mods keyName "  (" actionList.Length " total)`nPress ESC to stop.", 10, 10, 3)
}

StopRecording() {
    global isRecording, actionList, MyGui, recHook
    isRecording := false
    SetTimer(RecordLoop, 0)
    if (IsObject(recHook))
        recHook.Stop()
    recHook := ""
    ToolTip(, , , 3)
    MyGui.Show()
    total := actionList.Length
    ToolTip("✅ Recording stopped — " total " action(s) in list.", , , 2)
    SetTimer(ClearCaptureTip, -2000)
}

; =============================================
;   Drag & Drop  (ListView row reordering)
; =============================================

GetLVRowAtCursor() {
    global ListView
    MouseGetPos(&mx, &my)
    pt := Buffer(8, 0)
    NumPut("Int", mx, pt, 0)
    NumPut("Int", my, pt, 4)
    DllCall("ScreenToClient", "Ptr", ListView.Hwnd, "Ptr", pt)
    hti := Buffer(24, 0)   ; LVHITTESTINFO: POINT + flags + iItem + iSubItem
    NumPut("Int", NumGet(pt, 0, "Int"), hti, 0)
    NumPut("Int", NumGet(pt, 4, "Int"), hti, 4)
    result := SendMessage(0x1012, 0, hti, ListView.Hwnd)   ; LVM_HITTEST
    return (result >= 0) ? result + 1 : 0   ; 1-based; 0 = no item under cursor
}

LVDragLoop() {
    global lvDragging, lvDragRow, actionList, ListView
    if (!lvDragging) {
        SetTimer(LVDragLoop, 0)
        ToolTip()
        return
    }
    ; Cancel on Escape
    if (GetKeyState("Escape", "P")) {
        SetTimer(LVDragLoop, 0)
        ToolTip()
        lvDragging := false
        return
    }
    ; Mouse released → perform drop
    if (!GetKeyState("LButton", "P")) {
        SetTimer(LVDragLoop, 0)
        ToolTip()
        lvDragging := false
        targetRow := GetLVRowAtCursor()
        if (targetRow > 0 && targetRow != lvDragRow && lvDragRow <= actionList.Length) {
            SaveSnapshot()
            tmp := actionList[lvDragRow]
            actionList.RemoveAt(lvDragRow)
            insertAt := Min(targetRow, actionList.Length + 1)
            actionList.InsertAt(insertAt, tmp)
            RebuildList()
            ListView.Modify(insertAt, "Select Focus Vis")
        }
        return
    }
    ; Show live feedback tooltip
    targetRow := GetLVRowAtCursor()
    if (targetRow > 0 && targetRow != lvDragRow)
        ToolTip("  ↕  Move row " lvDragRow " → " targetRow "  ")
    else
        ToolTip("  ↕  Dragging row " lvDragRow "…  ")
}
