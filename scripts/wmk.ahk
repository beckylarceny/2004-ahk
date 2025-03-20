#NoEnv
#SingleInstance Force
CoordMode, Pixel, Client
CoordMode, Mouse, Screen
SetTitleMatchMode, 2

;; GUI
active := True
gui_was_focused := False
lostcity_title := "2004Scape Game"

Gui, indicator:New, -SysMenu -Caption +AlwaysOnTop +ToolWindow +Hwndgui_hwnd
Gui, indicator:Margin, 0, 0
Gui, indicator:Color, 0x567496
Gui, indicator:Font, cWhite s14 w700
Gui, indicator:Add, Text, 0x200 center w24 h24 gtoggle_suspend, W
Gui, indicator:Show, w24 h24

SetTimer, refresh_window_lowf, 500
SetTimer, refresh_window_highf, 50

refresh_window_lowf:
	WinGetPos, lc_x, lc_y, lc_w, lc_h, %lostcity_title%
	lc_x += lc_w - 24 - 8
	lc_y += 32 + (24 * 2)

	WinMove, ahk_id %gui_hwnd%, , %lc_x%, %lc_y%
	return

refresh_window_highf:
	if WinActive(lostcity_title) {
		Gui, indicator:Show, NA
	} else {
		Gui, indicator:Show, Hide
	}
	return

switch_active_color:
	if (active) { 
		Gui, indicator:Color, 0x567496
	} else {
		Gui, indicator:Color, 0x824040
	}
	return

toggle_suspend:
	Suspend, Toggle
	active := not active
	Gosub, switch_active_color
	return

;; REBINDS
#IfWinActive 2004Scape Game

; disable accidental go-backs
*XButton1::
*XButton2::
	return

; menu options
*Del::
	SendInput, {RButton}
	return
*End::
	menu_option(2)
	return
*PgDn::
	SendInput, {LButton}
	return

*Ins::
	SendInput, {RButton}
	return
*Home::
	menu_option(3)
	return
*PgUp::
	SendInput, {LButton}
	return

*[::
	SendInput, {RButton}
	return
*]::
	menu_option(4)
	return
*\::
	SendInput, {LButton}
	return

menu_option(position) {
	pixels := 10 + (15 * position)
	
	BlockInput, MouseMove
	MouseMove, 0, pixels, 0, R
	BlockInput, MouseMoveOff
	
	return
}