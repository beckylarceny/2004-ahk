Run, ".\lc-launcher.exe.lnk", , , game_pid
Run, ".\tick-metronome.ahk" %game_pid%, , , metro_pid
Run, ".\login.ahk", , , login_pid
Run, ".\mousecam.ahk", , , mousecam_pid
Run, ".\wmk.ahk", , , wmk_pid
Run, ".\runorb.ahk", , , runorb_pid

WinWait, ahk_pid %game_pid%
WinMove, ahk_pid %game_pid%, , , , 806, 598

WinGetPos, client_x, client_y, , , ahk_pid %game_pid%
metro_x := client_x + 487
metro_y := client_y + 350
if (FileExist("metro-settings.ini")) {
  IniRead, show_metro_settings_on_startup, metro-settings.ini, settings, show_settings_on_startup
}
if(!FileExist("metro-settings.ini") || show_metro_settings_on_startup) {
  WinWaitClose, tick-metronome Settings
}
WinMove, tick-metronome.ahk, , metro_x, metro_y, , 

WinWaitClose, ahk_pid %game_pid%
KillChildProcesses(metro_pid)
KillChildProcesses(login_pid)
KillChildProcesses(mousecam_pid)
KillChildProcesses(wmk_pid)
KillChildProcesses(runorb_pid)
ExitApp

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