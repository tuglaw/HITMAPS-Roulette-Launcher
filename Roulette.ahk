/*
	HITMAPS™ Roulette Launcher by tuglaw
	
	This launcher runs as a background process in Windows.
	If HITMAN3.exe or Hitman2Patcher.exe aren't running,
	the launcher will close automatically after a few seconds.
*/

#NoTrayIcon
#SingleInstance Force
#NoEnv
SendMode Input
#Persistent
SetWorkingDir %A_ScriptDir%
#WinActivateForce
DetectHiddenWindows, On

; Hitman2Patcher needs elevated rights to run.
If ( not A_IsAdmin )
{
	Try
		Run *RunAs "%A_ScriptFullPath%"
	Catch
		ExitApp
}

OnExit( "ExitFunc" )

SetTimer, CheckIfRunning, 300000 ; Initial run check for HITMAN3.exe or Hitman2Patcher.exe.

If ( ProcessExist( "Hitman2Patcher.exe" ) ) ; Avoids opening a second instance of Hitman2Patcher when launching.
	Process, Close, Hitman2Patcher.exe

If ( !ProcessExist( "HITMAN3.exe" ) )
	Run, %A_ScriptDir%\..\Retail\HITMAN3.exe ; Starts HITMAN 3.

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
			If ( !ProcessExist( "Hitman2Patcher.exe" ) )
			{
				Run, Hitman2Patcher.exe,, Min
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
	If (  ProcessExist( "Hitman2Patcher.exe" ) && !ProcessExist( "HITMAN3.exe" ) )
	|| ( !ProcessExist( "Hitman2Patcher.exe" ) && !ProcessExist( "HITMAN3.exe" ) )
		ExitApp
}

ProcessExist( Name )
{
	Process, Exist, %Name%
	Return Errorlevel
}

ExitFunc() ; Closes Hitman2Patcher when the Roulette Launcher closes.
{
	If ( ProcessExist( "Hitman2Patcher.exe" ) )
		Process, Close, Hitman2Patcher.exe
}