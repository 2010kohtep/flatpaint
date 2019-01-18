:: @echo off
set compiler="C:\Program Files (x86)\FASM\FASM.EXE"
set include=

IF NOT EXIST %compiler% (
	set compiler="C:\Program Files (x86)\FASM\FASM.EXE"
	
	IF NOT EXIST %compiler% (
		set compiler="C:\FASM\FASM.EXE"
		set include="C:\FASM\INCLUDE"
	) ELSE (
		set include="C:\Program Files (x86)\FASM\INCLUDE"
	)
) ELSE (
	set include="C:\Program Files (x86)\FASM\INCLUDE"
)

IF EXIST %compiler% (
	::color 0a
	cd "C:\Program Files (x86)\FASM"
	del bin\flatpaint.exe >nul 2>&1
	%compiler% src\main.asm
	move /Y bin\flatpaint.exe . >nul 2>&1
	echo.
	pause
)