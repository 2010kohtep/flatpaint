:: @echo off
SET compiler="C:\Program Files (x86)\FASM\FASM.EXE"

IF NOT EXIST %compiler% (
	SET compiler="C:\Program Files (x86)\FASM\FASM.EXE"
	
	IF NOT EXIST %compiler% (
		SET compiler="C:\FASM\FASM.EXE"
		SET include="C:\FASM\INCLUDE"
	) ELSE (
		SET include="C:\Program Files (x86)\FASM\INCLUDE"
	)
) ELSE (
	SET include="C:\Program Files (x86)\FASM\INCLUDE"
)

IF EXIST %compiler% (
	color 0a
	CD "C:\Program Files (x86)\FASM"
	DEL bin\flatpaint.exe >nul 2>&1
	%compiler% src\main.asm
	MOVE /Y bin\flatpaint.exe . >nul 2>&1
	echo.
	pause
)