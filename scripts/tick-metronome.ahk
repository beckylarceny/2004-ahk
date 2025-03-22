/* INSTRUCTIONS
	Middle click to open settings
	Left click to drag around
	Right click to reset
*/

#NoEnv
#SingleInstance Force
CoordMode, Pixel, Client
CoordMode, Mouse, Screen
SetTitleMatchMode, 2

;; CONFIG
loop_tick := 6
show_counter := 1
game_title := "2004Scape"
game_title_is_managed := 0
show_settings_on_startup := 1

if (A_Args[1]) {
	game_title_is_managed := 1
	game_title := A_Args[1]
}

if (!FileExist("metro-settings.ini")) {
	GoSub, write_settings_to_file
}

Gui, settings:New, -Border +ToolWindow +AlwaysOnTop +hwndsettings_hwnd
Gui, settings:Font, s8 w300 italic cGray
Gui, settings:Add, Text, ,Left click to drag around screen`nRight click to reset counter and stopwatch data`nMiddle click to open settings
Gui, settings:Font, s9 w400 norm cBlack
Gui, settings:Add, Text, xm, Show counter: 
Gui, settings:Add, Checkbox, x+5 vshow_counter
Gui, settings:Add, Text, xm, Looping count: 
Gui, settings:Add, Edit, x+5 Number W20 Limit2 vloop_tick
Gui, settings:Add, Text, xm, Game title: 
if (game_title_is_managed) { 
	Gui, settings:Font, cRed
	Gui, settings:Add, Text, x+5, %game_title%
	Gui, settings:Font, cBlack
} else {
	Gui, settings:Add, Edit, x+5 w150 vgame_title
}
Gui, settings:Add, Text, xm, Show settings on startup: 
Gui, settings:Add, Checkbox, x+5 vshow_settings_on_startup
Gui, settings:Font, s14 w1000
Gui, settings:Add, Button, xm gexit, Exit
Gui, settings:Add, Button, x+5 gsave_settings_and_close, Save
Gui, settings:Font, s12 w400
GoSub, update_timestamp
Gui, settings:Add, Text, xm w200 vtimestamp_text, % timestamp

GoSub, read_settings_from_file

;; METRONOME
tick_counter := 0
metro_w := 22
metro_h := 22
metro_font_size := 14
game_x := 0
game_y := 0
timestamp := ""

Gui, metro:New, -SysMenu -Caption +AlwaysOnTop +ToolWindow +Hwndmetro_hwnd
Gui, metro:Margin, 0, 0g
Gui, metro:Color, Black
Gui, metro:Font, s%metro_font_size% q5 cWhite
Gui, metro:Add, Text, 0x200 center vCounter w%metro_w% h%metro_h%, % formatted_counter(tick_counter)

WinGetPos, game_x, game_y, game_w, game_h, %game_title%
WinMove, ahk_id %metro_hwnd%, , game_x + (game_w / 2) - (metro_w / 2), game_y + (game_h / 2) - (metro_h / 2)

if (show_settings_on_startup) {
	GoSub, open_settings_window
} else {
	GoSub, show_metronome
}

SetTimer, move_with_game, 100
SetTimer, tick_pacemaker, 600

;; SUBROUTINES
move_with_game:
	if (game_title_is_managed) {
		WinGetPos, game_new_x, game_new_y, , , ahk_pid %game_title%
	} else {
		WinGetPos, game_new_x, game_new_y, , , %game_title%
	}
	WinGetPos, metro_x, metro_y, , , ahk_id %metro_hwnd%

	if (game_new_x != game_x || game_new_y != game_y) {
		metro_new_x := metro_x + (game_new_x - game_x)
		metro_new_y := metro_y + (game_new_y - game_y)
		WinMove, ahk_id %metro_hwnd%, , metro_new_x, metro_new_y
	}

	game_x := game_new_x
	game_y := game_new_y
	if (metro_new_x != "") {
		metro_x := metro_new_x
		metro_y := metro_new_y
	} else {
		WinMove, ahk_id %metro_hwnd%, , metro_x, metro_y
	}

	return

tick_pacemaker:
	tick_counter += 1
	GoSub, set_colors
	GoSub, update_counter
	return

set_colors:
	if (Mod(tick_counter, 2) = 0) {
		Gui, metro:Color, White
		Gui, metro:Font, s%metro_font_size% q5 cBlack
		GuiControl, metro:Font, Counter
	} else {
		Gui, metro:Color, Black
		Gui, metro:Font, s%metro_font_size% q5 cWhite
		GuiControl, metro:Font, Counter
	}
	return

reset_tick_pacemaker:
	tick_counter := 0
	SetTimer, tick_pacemaker, 600
	GoSub, set_colors
	GoSub, update_counter
	return

move_window:
	Loop {
		if (GetKeyState("LButton", "P") == 1) {
			MouseGetPos, cursor_x, cursor_y, 
			WinMove, ahk_id %metro_hwnd%, , % cursor_x - (metro_w / 2), % cursor_y - (metro_h / 2)
		} else {
			break
		}
	}
	return

update_counter:
	GuiControl, metro:Text, Counter, % formatted_counter(tick_counter)
	return

formatted_counter(num) {
	global show_counter
	global loop_tick

	if (!show_counter) {
		return " "
	}

	trunc_num := Mod(num, loop_tick) + 1
	if (trunc_num < 10) {
		return "0" . trunc_num
	} else {
		return trunc_num
	}
}

update_timestamp:
	tick_counter_copy := tick_counter
	timestamp := "" . tick_counter_copy . " tick" . ((tick_counter_copy > 1) ? "s" : "") . " | " . Floor((tick_counter_copy * 0.6) / (60 * 60)) . "H " . Floor(Mod((tick_counter_copy * 0.6) / 60, 60)) . "M " . Format("{1:.4}", Mod(tick_counter_copy * 0.6, 60)) . "S "
	return 

write_settings_to_file:
	IniWrite, %loop_tick%, metro-settings.ini, settings, loop_tick
	IniWrite, %show_counter%, metro-settings.ini, settings, show_counter
	if (!game_title_is_managed){
		IniWrite, %game_title%, metro-settings.ini, settings, game_title
	}
	IniWrite, %show_settings_on_startup%, metro-settings.ini, settings, show_settings_on_startup
	return

read_settings_from_file:
	IniRead, loop_tick, metro-settings.ini, settings, loop_tick
	IniRead, show_counter, metro-settings.ini, settings, show_counter
	if (!game_title_is_managed){
		IniRead, game_title, metro-settings.ini, settings, game_title
	}
	IniRead, show_settings_on_startup, metro-settings.ini, settings, show_settings_on_startup
	return

open_settings_window:
	GuiControl, settings:, show_counter, %show_counter%
	GuiControl, settings:, loop_tick, %loop_tick%
	GuiControl, settings:, game_title, %game_title%
	GuiControl, settings:, show_settings_on_startup, %show_settings_on_startup%

	WinGetPos, metro_x, metro_y, , , ahk_id %metro_hwnd%
	Gui, metro:Show, Hide
	try {
		Gui, settings:Show, x%metro_x% y%metro_y%, tick-metronome Settings
	} catch e {
		Gui, settings:Show, , tick-metronome Settings
		; retarded bugs demand retarded fixes
		; (Gui, settings:Show was still being passed metro_x and _y as empty strings
		; even with an if statement guarding that very possibility)
	}
	GoSub, update_timestamp
	GuiControl, settings:, timestamp_text, %timestamp%

	WinWaitClose, ahk_id %settings_hwnd%
	GoSub, show_metronome
	return

save_settings_and_close:
	Gui, settings:Submit
	GoSub, write_settings_to_file
	return

show_metronome:
	Gui, metro:Show, w%metro_w% h%metro_h%
	return

exit:
	GoSub, save_settings_and_close
	ExitApp
	return

;; CONTROLS
~LButton::
	MouseGetPos, , , cursor_win
	if (cursor_win = metro_hwnd) {
		GoSub, move_window
	}
	return

~RButton::
	MouseGetPos, , , cursor_win
	if (cursor_win = metro_hwnd) {
		GoSub, reset_tick_pacemaker
	}
	return

~MButton::
	MouseGetPos, , , cursor_win
	if (cursor_win = metro_hwnd) {
		GoSub, open_settings_window
	}
	return