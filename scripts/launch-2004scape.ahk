game_x := 0
game_y := 0
game_w := 806
game_h := 601
metro_x := 488
metro_y := 383
start_metronome := 1
start_login := 1
start_mousecam := 1
start_wmk := 1
start_runorb := 1
show_metro_settings_on_startup := 1

if (!FileExist("launch-settings.ini")) {
	GoSub, write_settings_to_file
} else {
	GoSub, read_settings_from_file
}

Run, ".\lc-launcher.exe.lnk", , , game_pid
WinWait, ahk_pid %game_pid%
WinMove, ahk_pid %game_pid%, , game_x, game_y, game_w, game_h

if (start_metronome) {
	Run, ".\tick-metronome.ahk" %game_pid%, , , metro_pid
	if (FileExist("metro-settings.ini")) {
		IniRead, show_metro_settings_on_startup, metro-settings.ini, settings, show_settings_on_startup
	}
	if(show_metro_settings_on_startup) {
		WinWait, tick-metronome Settings ahk_class AutoHotkeyGUI
		WinWaitClose, tick-metronome Settings ahk_class AutoHotkeyGUI
	}
	if (!WinExist("tick-metronome.ahk ahk_class AutoHotkeyGUI")) {
		WinWait, tick-metronome.ahk ahk_class AutoHotkeyGUI, , metro_x, metro_y 
	}
	WinMove, tick-metronome.ahk ahk_class AutoHotkeyGUI, , metro_x, metro_y
}

if (start_login) {
	Run, ".\login.ahk", , , login_pid
}

if (start_mousecam) {
	Run, ".\mousecam.ahk", , , mousecam_pid
}

if (start_wmk) {
	Run, ".\wmk.ahk", , , wmk_pid
}

if (start_runorb) {
	Run, ".\runorb.ahk", , , runorb_pid
}

SetTimer, get_game_pos, 1000

; CLEANUP
WinWaitClose, ahk_pid %game_pid%

SetTimer, get_game_pos, Off
WinGetPos, metro_x, metro_y, , , tick-metronome ahk_class AutoHotkeyGUI
GoSub, write_settings_to_file

KillChildProcesses(metro_pid)
KillChildProcesses(login_pid)
KillChildProcesses(mousecam_pid)
KillChildProcesses(wmk_pid)
KillChildProcesses(runorb_pid)
ExitApp

get_game_pos:
	WinGetPos, game_x, game_y, game_w, game_h, ahk_pid %game_pid%
	return

write_settings_to_file:
	IniWrite, %game_x%, launch-settings.ini, metronome_settings, game_x
	IniWrite, %game_y%, launch-settings.ini, metronome_settings, game_y
	IniWrite, %game_w%, launch-settings.ini, metronome_settings, game_w
	IniWrite, %game_h%, launch-settings.ini, metronome_settings, game_h
	IniWrite, %metro_x%, launch-settings.ini, metronome_settings, metro_x
	IniWrite, %metro_y%, launch-settings.ini, metronome_settings, metro_y
	IniWrite, %start_metronome%, launch-settings.ini, metronome_settings, start_metronome
	IniWrite, %start_login%, launch-settings.ini, metronome_settings, start_login
	IniWrite, %start_mousecam%, launch-settings.ini, metronome_settings, start_mousecam
	IniWrite, %start_wmk%, launch-settings.ini, metronome_settings, start_wmk
	IniWrite, %start_runorb%, launch-settings.ini, metronome_settings, start_runorb
	return

read_settings_from_file:
	IniRead, game_x, launch-settings.ini, metronome_settings, game_x
	IniRead, game_y, launch-settings.ini, metronome_settings, game_y
	IniRead, game_w, launch-settings.ini, metronome_settings, game_w
	IniRead, game_h, launch-settings.ini, metronome_settings, game_h
	IniRead, metro_x, launch-settings.ini, metronome_settings, metro_x
	IniRead, metro_y, launch-settings.ini, metronome_settings, metro_y
	IniRead, start_metronome, launch-settings.ini, metronome_settings, start_metronome
	IniRead, start_login, launch-settings.ini, metronome_settings, start_login
	IniRead, start_mousecam, launch-settings.ini, metronome_settings, start_mousecam
	IniRead, start_wmk, launch-settings.ini, metronome_settings, start_wmk
	IniRead, start_runorb, launch-settings.ini, metronome_settings, start_runorb
	return

; https://www.autohotkey.com/boards/viewtopic.php?p=70273&sid=ceb82e0f23176ab20429ed1b7a8d0da5#p70273
KillChildProcesses(ParentPidOrExe){
	static Processes, i
	ParentPID:=","
	If !(Processes)
		Processes:=ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
	i++
	for Process in Processes
		If (Process.Name=ParentPidOrExe || Process.ProcessID=ParentPidOrExe)
			ParentPID.=process.ProcessID ","
	for Process in Processes
		If InStr(ParentPID,"," Process.ParentProcessId ","){
			KillChildProcesses(process.ProcessID)
			Process,Close,% process.ProcessID 
		}
	i--
	If !i
		Processes=
}

GetFirstChild(ParentPid) {
  Processes := ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
	for Process in Processes
		If InStr(ParentPid,Process.ParentProcessId){
			return Process.ProcessID
		}
}