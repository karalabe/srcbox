@echo off

rem Unfuckup batch file processing
setlocal enabledelayedexpansion

rem Look through the path variable for srcbox
set srcbox=undefined
set base_path=("%PATH:;=" "%")
for %%p in %base_path% do (
    if exist %%p\srcbox.bat (
        set srcbox=%%p
    )
)

rem Make sure srcbox is in the path variable
if %srcbox%==undefined (
    set srcbox=%~dp0
    for /f "tokens=3*" %%i in ('reg query HKCU\Environment /v PATH') do (
        set user_path=%%i %%j
    )
    setx PATH "!user_path!;!srcbox:~0,-7!" 1>nul
    echo SrcBox was successfully configured.
    pause
) else (
    echo SrcBox is already configured.
    pause
)