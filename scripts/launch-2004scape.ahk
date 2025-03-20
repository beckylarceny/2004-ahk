Run, ".\lc-launcher.exe.lnk"
Run, ".\tick-metronome.ahk"
Run, ".\login.ahk"
Run, ".\mousecam.ahk"
Run, ".\wmk.ahk"
Run, ".\runorb.ahk"

WinWait, 2004Scape Game ahk_class Chrome_WidgetWin_1
WinGet, client_hwnd, ID, 2004Scape Game ahk_class Chrome_WidgetWin_1
WinMove, ahk_id %client_hwnd%, , -7, 457, 806, 598

WinWait, tick-metronome.ahk ahk_class AutoHotkeyGUI
WinGet, tick_metro_hwnd, ID, tick-metronome.ahk ahk_class AutoHotkeyGUI
WinMove, ahk_id %tick_metro_hwnd%, ,487, 838, , 