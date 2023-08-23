/*
NAME: Windows EZ (windowsEZ.ahk)
AUTH: Akoprea (https://github.com/akoprea)
DATE: March 10, 2021
DESC: Provides basic shortcuts and rules to make the Windows experience faster and better.
	v1.1 - 03/10/2021
	v1.2 - 06/01/2022
		* added hotkey to open selected URL (OSU system)
		* switched Help menu from a MessageBox to a GUI using ListView
*/
#NoEnv
#Warn
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance, Force
SetBatchLines -1
Try Menu, Tray, Icon, ws.ico
tipString_default := "Windows EZ `nMakes the Windows experience better. `n`nWin+F1: Settings `nWin+F2: Exit `nWin+F3: Reload `n`nby Zac C / 'Zactax'"
Menu, Tray, Tip, %tipString_default%

CoordMode, Mouse, Screen ; tell mouse and tooltip to use coords relative to the entire screen
CoordMode, ToolTip, Screen

;;;; VARS
wabbitemu_path := "C:\Users\Zacat\OneDrive\Documents" ; folder path where WabbitEmu.exe is installed

;;;; Settings (help) GUI
Gui, help:New, -SysMenu , Windows EZ - Settings ; min, max, and close buttons are omitted
;; Gui, help:Add, Text,, Hotkeys and Rules
; Create ListView of hotkeys and add contents
Gui, help:Add, ListView, r10 w700 NoSortHdr, Hotkey|Action|Description ; create the ListView with 3 columns: Hotkey, Action, and Description ; NoSortHdr makes col headers unclickable, which disables sorting
LV_Add("", "Win+N","Run Notepad","Opens new, unsaved, and Untitled file in notepad.exe")
LV_Add("", "Win+W","Run WabbitEmu Calculator","Runs WabbitEmu, if not running already")
LV_Add("", "Win+S","Search Selected Text","Opens new tab of Google Chrome with selected text as search query")
LV_Add("", "Win+Shift+S","Open Selected URL","Opens selected URL in search engine")
LV_Add("", "Win+B","Toggle Bluetooth","Opens Bluetooth settings window, navigates it, and toggles the ON/OFF switch")
LV_Add("", "Ctrl+Z"," * File Explorer Rule"," * Undo hotkey is disabled in File Explorer while the window is in focus")
LV_Add("", "","","") ; spacer
LV_Add("", "Win+F1","Show this Settings GUI","")
LV_Add("", "Win+F2","Terminate the Program","")
LV_Add("", "Win+F3","Reload the Program","")
LV_ModifyCol()  ; Auto-size each column to fit its contents
LV_ModifyCol(1, "AutoHdr") ; auto-size col to fit its contents AND header
; Settings GUI Variables
; var names with "on_" are for setting if a hotkey is active or not
on_notepad := True
on_wabbitemu := True
on_sst := True
on_osu := True
on_bluetooth := True
on_explorer := True
; Settings GUI - Add Checkboxes
Gui, help:Add, CheckBox, von_notepad Checked, Run Notepad
Gui, help:Add, CheckBox, von_wabbitemu Checked, Run WabbitEmu
Gui, help:Add, CheckBox, von_sst Checked, SST
Gui, help:Add, CheckBox, von_osu Checked, OSU
Gui, help:Add, CheckBox, von_bluetooth Checked, Bluetooth Toggler
Gui, help:Add, CheckBox, von_explorer Checked, File Explorer Rule

Gui, help:Add, Button, gsubmitSettings, Save Settings and Close Menu
gui_vis := False ; var describing gui visibility

return ; autorun until here


;;;; FEATURES

; Notepad - Win+N
#n::
{
	If !on_notepad
		return
	Run, Notepad
	return
}

; Wabbitemu Calculator - Win+W
#IfWinNotExist ahk_exe Wabbitemu.exe
#w::
{
	If !on_wabbitemu
		return
	Run, Wabbitemu.exe, %wabbitemu_path%
	SetNumLockState, On ;Turns NumLock ON
	return
}
#IfWinNotExist ; end conditional if statement -no blocks needed for these statements btw
/* IMPORTANT NOTE
WabbitEmu is a third-party software not included with Windows.
It can be downloaded from: http://wabbitemu.org/

*/

; Search Selected Text (SST) - Win+S
#s::
{
	If !on_sst
		return
	Clipboard := "" ; clear clipboard
	Send, ^c ; Copies selected text. SendMode should be Input (set in opening commands)
	Sleep, 50
	; alert user and return if clipboard is empty
	If (clipboard = "") {
		SoundPlay, xp_error.mp3 ; play sound (Windows XP error) from file. file is ~0.80s long, and has gain of -36dB from original. doesn't wait until done to move to next command
		ShowToolTip( "No Text Selected" )
		return
	}
	; else, continue
	Run, https://www.google.com/search?q=%clipboard% ; search for it
	Sleep, 50
	Clipboard := "" ; clear the clipboard
	return
}
; Open Selected URL (OSU) - Win+Shift+S
#+s::
{
	If !on_osu
		return
	Clipboard := "" ; clear clipboard
	Send, ^c ; Copies selected text. SendMode should be Input (set in opening commands)
	Sleep, 50
	; alert user and return if clipboard is empty
	If (clipboard = "") {
		SoundPlay, xp_error.mp3 ; play sound (Windows XP error) from file. file is ~0.80s long, and has gain of -36dB from original. doesn't wait until done to move to next command
		ShowToolTip( "No URL Selected" )
		return
	}
	; else, continue to try
	Try
	{
		Run, %clipboard% ; running a URL should open it in search engine
	} catch {
		SoundPlay, xp_error.mp3 ; play sound (Windows XP error) from file. file is ~0.80s long, and has gain of -36dB from original. doesn't wait until done to move to next command
		ShowToolTip( "Selected text is not a URL" ) ; if selected text is not a URL, alert user of error
	}
	Sleep, 50
	Clipboard := "" ; clear the clipboard
	return
}
/*
Sample TEXT: colby jack cheese
Sample URL: https://github.com/Zactax
*/

; Toggle Bluetooth ON/OFF - Win+B
#b::
{
	; this hotkey is VERY tedious. it relies on blindly navigating the bluetooth settings menu, rather than doing anything with bluetooth directly. very likely to break!
	If !on_bluetooth
		return
	ShowToolTip( "Do not touch the following window" , 3000 )
	SendMode Input
	Run, ms-settings:bluetooth
	WinWaitActive, Settings
	Sleep 2000
	Send {Tab}{Space}
	Sleep 50
	WinClose, A
	return
}

; Disable Ctrl+Z in Windows File Explorer
#IfWinActive ahk_class CabinetWClass ; if File Explorer is the active window
^z::    ; Captures input from Ctrl+Z, and alerts user (shows tooltip a/o plays a beep)
{
	If !on_explorer
		return
	SoundBeep, 300, 100
	return
}
#IfWinActive
/* EXPLAINATION OF THIS RULE
The reason this rule is included is to prevent data loss in File Explorer.
Ex:
1. Files are moved from a flash drive to the hard drive
2. The flash drive is removed
3. Ctrl+Z is pressed
	- this may result in the files being lost, as their original destination doesn't exist anymore.
*/


;;;; UTILITY

; Save Settings from Settings Menu
submitSettings:
{
	; toggle gui visability and submit gui
	gui_vis := !gui_vis
	Gui, help:Submit
	return
}

; Showing Tooltips
ShowToolTip( message="" , delay=2000 , x="at_mouse" , y="at_mouse" , header_bool=False )
{
	; delay is in milliseconds. header_bool specifies if header should be shown before the message.
	; local var names cannot be specified when calling this function. if want default, leave var spot blank and continue.

	; Set message if none specified
	If (message = "") {
		message := "WEZ:NO_MESSAGE"
	}
	; Set x and y to mouse position if not specified
	If (x = "at_mouse" or y = "at_mouse") {
		MouseGetPos, x, y ; Set x and y to mouse position
		x+=10
		y+=10
	}

	; Show Tooltip
	; ; set temp string depending on header_bool
	temp := message ; set it as default then check
	If (header_bool = True) {
		temp := % "Windows EZ:`n" (message)
	}
	tooltip, %temp% , x , y
	settimer, ToolTipOff, %delay% ; set a timer for __ milliseconds to clear the tooltip. calls tooltipoff label when done.
	return
}
; Tooltip OFF
ToolTipOff:
{
	settimer, ToolTipOff, off ;turn the timer off
	tooltip ;clear the tooltip
	return
}

; Show Settings GUI - Win+F1
#F1::
{
	Gui, help:Show ; shows with auto-sizing
	return
}
; Terminate Program - Win+F2
#F2::
{
	MsgBox, 20, Windows EZ, Would you like to TERMINATE Windows EZ?
	IfMsgBox Yes
	{
		MsgBox,,Windows EZ, TERMINATING, 0.5
		ExitApp ; exit app if user selects Yes. continue to return if not
	}
	return
}
; Reload Script - Win+F3
#F3::
{
	; script must be SAVED in order for changes to be applied
	MsgBox, 20, Windows EZ, Would you like to RELOAD Windows EZ?
	IfMsgBox Yes
	{
		MsgBox,,Windows EZ, RELOADING, 0.5
		Reload ; reloads the script
	}
	return
}

