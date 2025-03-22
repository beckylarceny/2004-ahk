Run, ".\lc-launcher.exe.lnk", , , game_pid
Run, ".\tick-metronome.ahk" %game_pid%, , , metro_pid
Run, ".\login.ahk", , , login_pid
Run, ".\mousecam.ahk", , , mousecam_pid
Run, ".\wmk.ahk", , , wmk_pid
Run, ".\runorb.ahk", , , runorb_pid

WinWait, ahk_pid %game_pid%
WinMove, ahk_pid %game_pid%, , , , 806, 598

metro_child_pid := GetFirstChild(metro_pid)
login_child_pid := GetFirstChild(login_pid)
mousecam_child_pid := GetFirstChild(mousecam_pid)
wmk_child_pid := GetFirstChild(wmk_pid)
runorb_child_pid := GetFirstChild(runorb_pid)

WinGetPos, client_x, client_y, , , ahk_pid %game_pid%
metro_x := client_x + 487
metro_y := client_y + 350
WinMove, ahk_pid %metro_child_pid%, , metro_x, metro_y, , 

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