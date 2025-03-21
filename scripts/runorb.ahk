#NoEnv
#SingleInstance Force
CoordMode, Pixel, Client
CoordMode, Mouse, Screen
SetTitleMatchMode, 2

;; GUI
running := False
should_run := False
gui_was_focused := False
lostcity_title := "2004Scape Game"
lostcity_hwnd := ""

Gui, runorb:New, -SysMenu -Caption +AlwaysOnTop +ToolWindow +Hwndgui_hwnd
Gui, runorb:Margin, 0, 0
Gui, runorb:Color, 0x666600
Gui, runorb:Font, cWhite s14 w700
Gui, runorb:Add, Text, 0x200 center w32 h32 vKYS gtoggle_run, Ctrl
Gui, runorb:Show, w32 h32

SetTimer, refresh_window_lowf, 500
SetTimer, refresh_window_highf, 50

refresh_window_lowf:
	WinGetPos, lc_x, lc_y, lc_w, lc_h, %lostcity_title%
	lc_x += 540
	lc_y += 180
	WinMove, ahk_id %gui_hwnd%, , %lc_x%, %lc_y%
  if (running && ms_lostcity) {
    Send, {LCtrl down}
  }
	return

refresh_window_highf:
  MouseGetPos, , , ms_hwnd
  WinGetTitle, ms_title, ahk_id %ms_hwnd%
  cur_active := WinActive(lostcity_title)
  ms_lostcity := ms_title == lostcity_title
  if (cur_active != prev_cur_active) {
    if (cur_active) {
      if (running && (ms_lostcity != prev_ms_lostcity)) {
        if (ms_lostcity) {
          Send, {LCtrl down}
        } else {
          Send, {LCtrl up}
        }
      }
      Gui, runorb:Show, NA
    } else {
      Send, {LCtrl up}
      Gui, runorb:Show, Hide
    }
  }
  prev_active := cur_active
  prev_ms_lostcity := ms_lostcity
	return

toggle_run:
  running := !running
  switch (running) {
    case True:
      Gui, runorb:Color, 0xCCCC00
      Send, {LCtrl down}
      return
    case False:
      Gui, runorb:Color, 0x666600
      Send, {LCtrl up}
      return
  }
	return

;; FIXES
#IfWinActive 2004Scape Game

^PrintScreen::
  Send, {PrintScreen}
  return

^Pause::
  Send, {Pause}
  return

^0::
  Send, 0
  return

^WheelUp::
^WheelDown::
  return