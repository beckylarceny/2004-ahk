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
Gui, indicator:Add, Text, 0x200 center w24 h24 gtoggle_suspend, M
Gui, indicator:Show, w24 h24

Gui, mousecam:New, -SysMenu -Caption +AlwaysOnTop +ToolWindow +Hwndmousecam_hwnd
Gui, mousecam:Margin, 0, 0
Gui, mousecam:Color, B7B7B7

SetTimer, refresh_window_lowf, 500
SetTimer, refresh_window_highf, 50

refresh_window_lowf:
	WinGetPos, lc_x, lc_y, lc_w, lc_h, %lostcity_title%
	lc_x += lc_w - 300 - (24 * 1)
	lc_y += 4

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

; middle mouse camera
*MButton::
	MouseGetPos, mousecam_anchor_x, mousecam_anchor_y
	
	deadzone_size := 20
	deadzone_size_twice := deadzone_size * 2
	cur_state_left := 0
	cur_state_right := 0
	cur_state_down := 0
	cur_state_up := 0
	anchor_gui_offset_x := mousecam_anchor_x - (deadzone_size)
	anchor_gui_offset_y := mousecam_anchor_y - (deadzone_size)

	Gui, mousecam:Show, w%deadzone_size_twice% h%deadzone_size_twice% x%anchor_gui_offset_x% y%anchor_gui_offset_y% NA
	WinSet, Transparent, 100, ahk_id %mousecam_hwnd%

	while GetKeyState("MButton", "P") {
		MouseGetPos, mousecam_cur_x, mousecam_cur_y
		
		if (mousecam_cur_x > (mousecam_anchor_x + deadzone_size)) {
			left_diff := 1 - cur_state_Left
		} else {
			left_diff := -1
		}
		if (mousecam_cur_x < (mousecam_anchor_x - deadzone_size)) {
			right_diff := 1 - cur_state_Right
		} else {
			right_diff := -1
		}
		if (mousecam_cur_y < (mousecam_anchor_y - deadzone_size)) {
			down_diff := 1 - cur_state_Down
		} else {
			down_diff := -1
		}
		if (mousecam_cur_y > (mousecam_anchor_y + deadzone_size)) {
			up_diff := 1 - cur_state_Up
		} else {
			up_diff := -1
		}

		if (left_diff == 1) {
			SendInput, {Left down}
			cur_state_left = 1
		} else if (left_diff == -1) {
			SendInput, {Left up}
			cur_state_left = 0
		}
		if (right_diff == 1) {
			SendInput, {Right down}
			cur_state_right = 1
		} else if (right_diff == -1) {
			SendInput, {Right up}
			cur_state_right = 0
		}
		if (down_diff == 1) {
			SendInput, {Down down}
			cur_state_down = 1
		} else if (down_diff == -1) {
			SendInput, {Down up}
			cur_state_down = 0
		}
		if (up_diff == 1) {
			SendInput, {Up down}
			cur_state_up = 1
		} else if (up_diff == -1) {
			SendInput, {Up up}
			cur_state_up = 0
		}
		
		Sleep, 5
	}

	SendInput, {Left up}{Down up}{Up up}{Right up}
	Gui, mousecam:Hide

	return