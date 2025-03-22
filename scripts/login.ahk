#NoEnv
#SingleInstance Force
CoordMode, Pixel, Client
CoordMode, Mouse, Client
SetTitleMatchMode, 2

if (!FileExist("login-settings.ini")) {
	IniWrite, "", login-settings.ini, credentials, username
	IniWrite, "", login-settings.ini, credentials, password
	MsgBox, % "Write your login details in the 'login-settings.ini' file generated in this folder.`nBoth fields are optional (don't write your password in plain text if you don't want to)"
}
IniRead, username, login-settings.ini, credentials, username
IniRead, password, login-settings.ini, credentials, password

;; GUI
active := True
gui_was_focused := False
lostcity_title := "2004Scape Game"

Gui, indicator:New, -SysMenu -Caption +AlwaysOnTop +ToolWindow +Hwndgui_hwnd
Gui, indicator:Margin, 0, 0
Gui, indicator:Color, 0x567496
Gui, indicator:Font, cWhite s14 w700
Gui, indicator:Add, Text, 0x200 center w24 h24 gtoggle_suspend, L
Gui, indicator:Show, w24 h24

SetTimer, refresh_window_lowf, 500
SetTimer, refresh_window_highf, 50

refresh_window_lowf:
	WinGetPos, lc_x, lc_y, lc_w, lc_h, %lostcity_title%
	lc_x += lc_w - 24 - 8
	lc_y += 32 + (24 * 0)

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
XButton1::
XButton2::
	return

; paste credentials
*!1::
	if (!active) { 
		SendInput, 1
		return
	}
	SendInput, %username%{Enter}%password%
	return