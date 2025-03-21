﻿/* INSTRUCTIONS
	Middle click to open settings
	Left click to drag around
	Right click to reset
*/

#NoEnv
#SingleInstance Force
CoordMode, Pixel, Client
CoordMode, Mouse, Screen
SetTitleMatchMode, 2

loop_tick := 6
show_counter := 1
game_title := "2004Scape Game"

;; CONFIG
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
Gui, settings:Add, Edit, x+5 w150 vgame_title
Gui, settings:Font, s14 w1000
Gui, settings:Add, Button, xm gexit, Exit
Gui, settings:Add, Button, x+5 gsave_settings, Save
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

GoSub, open_settings_window

SetTimer, move_with_game, 100
SetTimer, tick_pacemaker, 600

;; SUBROUTINES
move_with_game:
	WinGetPos, game_new_x, game_new_y, , , %game_title%
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
	IniWrite, %game_title%, metro-settings.ini, settings, game_title
	return

read_settings_from_file:
	IniRead, loop_tick, metro-settings.ini, settings, loop_tick
	IniRead, show_counter, metro-settings.ini, settings, show_counter
	IniRead, game_title, metro-settings.ini, settings, game_title
	return

open_settings_window:
	GuiControl, settings:, show_counter, %show_counter%
	GuiControl, settings:, loop_tick, %loop_tick%
	GuiControl, settings:, game_title, %game_title%

	WinGetPos, metro_x, metro_y, , , ahk_id %metro_hwnd%
	if (metro_x == "") {
		metro_x := A_ScreenWidth / 2 - (metro_w / 2)
		metro_y := A_ScreenHeight / 2 - (metro_h / 2)
	}
	Gui, metro:Show, Hide
	Gui, settings:Show, x%metro_x% y%metro_y%, tick-metronome Settings
	GoSub, update_timestamp
	GuiControl, settings:, timestamp_text, %timestamp%

	WinWaitClose, ahk_id %settings_hwnd%
	Gui, settings:Submit
	Gui, metro:Show, w%metro_w% h%metro_h%
	return

save_settings:
	Gui, setting:Submit
	GoSub, write_settings_to_file
	WinClose, ahk_id %settings_hwnd%
	return

exit:
	Gui, settings:Submit
	IniWrite, %loop_tick%, metro-settings.ini, settings, loop_tick
	IniWrite, %show_counter%, metro-settings.ini, settings, show_counter
	IniWrite, %game_title%, metro-settings.ini, settings, game_title
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