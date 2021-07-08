/*
	HITMAPS™ Roulette Launcher by tuglaw
	
	This launcher runs as a background process in Windows.
	If HITMAN3.exe or LocalGhostPatcher.exe aren't running,
	the launcher will close automatically after a few seconds.
*/

#SingleInstance Force
#NoEnv
#Persistent
#WinActivateForce
SetWorkingDir %A_ScriptDir%
DetectHiddenWindows, On

; Tray Menu
Menu, Tray, NoStandard
Menu, Tray, Add, Exit, TrayExit
Menu, Tray, Tip, HITMAPS™ Roulette Launcher

TrayExit()
{
	ExitApp
}

; LocalGhostPatcher needs elevated rights to run.
If ( not A_IsAdmin )
{
	Try
		Run *RunAs "%A_ScriptFullPath%"
	Catch
		ExitApp
}

OnExit( "ExitFunc" )

If !FileExist( "LocalGhostPatcher.exe" )
{
	MsgBox, 016, Error, LocalGhostPatcher.exe must be located in:`n"\HITMAN3\Roulette\LocalGhostPatcher.exe"`n`nPress OK to close the launcher.
	IfMsgBox OK
		ExitApp
}

SetTimer, CheckIfRunning, 300000 ; Initial run check for HITMAN3.exe or LocalGhostPatcher.exe.

If ( ProcessExist( "LocalGhostPatcher.exe" ) ) ; Avoids opening a second instance of LocalGhostPatcher when launching.
	Process, Close, LocalGhostPatcher.exe

If ( !ProcessExist( "HITMAN3.exe" ) )
{
	Try
		Run, %A_ScriptDir%\..\Retail\HITMAN3.exe ; Starts HITMAN 3.
	Catch
	{
		MsgBox, 016, Error, Roulette.exe must be located in:`n"\HITMAN3\Roulette\Roulette.exe"`n`nPress OK to close the launcher.
		IfMsgBox OK
			ExitApp
	}
}

SetTimer, checkStartup, 250 ; Checks if HITMAN 3 has started.

checkStartup()
{
	SetTimer, checkStartup, Off
	
	If ( ProcessExist( "HITMAN3.exe" ) )
	{
		#IfWinNotActive, ahk_exe HITMAN3.exe ; Checks if HITMAN 3 isn't in focus.
		{
			WinActivate, ahk_exe HITMAN3.exe ; Forces and waits for HITMAN 3 to be in focus.
			WinWaitActive, ahk_exe HITMAN3.exe
		}
		#If
		
		#IfWinActive, ahk_exe HITMAN3.exe
		{
			SetTimer, checkStartup, Off ; Stops checking if HITMAN 3 has started.
			If ( !ProcessExist( "LocalGhostPatcher.exe" ) )
			{
				Run, LocalGhostPatcher.exe,, Min
				SetTimer, CheckIfRunning, 6000 ; Change run check timer.
			}
			Return
		}
		#If
	}
	Else
		SetTimer, checkStartup, 250
}

#IfWinActive, ahk_exe HITMAN3.exe ; Close Roulette Launcher when closing HITMAN 3 with Alt+F4.
	~!F4::
		ExitApp
	Return
#If

CheckIfRunning()
{
	If (  ProcessExist( "LocalGhostPatcher.exe" ) && !ProcessExist( "HITMAN3.exe" ) )
	|| ( !ProcessExist( "LocalGhostPatcher.exe" ) && !ProcessExist( "HITMAN3.exe" ) )
		ExitApp
}

ProcessExist( Name )
{
	Process, Exist, %Name%
	Return Errorlevel
}

ExitFunc() ; Closes LocalGhostPatcher when the Roulette Launcher closes.
{
	If ( ProcessExist( "LocalGhostPatcher.exe" ) )
		Process, Close, LocalGhostPatcher.exe
}