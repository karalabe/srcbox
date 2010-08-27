@echo off

rem Unfuckup batch file processing
setlocal enabledelayedexpansion

rem Look through the path variable for gitbox
set gitbox=undefined
set base_path=("%PATH:;=" "%")
for %%p in %base_path% do (
    if exist %%p\gitbox.bat (
        set gitbox=%%p
    )
)

rem Make sure gitbox is in the path variable
if %gitbox%==undefined (
    set gitbox=%~dp0
    for /f "tokens=3*" %%i in ('reg query HKCU\Environment /v PATH') do (
        set user_path=%%i %%j
    )
    setx PATH "!user_path!;!gitbox:~0,-7!" 1>nul
    echo GitBox was successfully configured.
    pause
) else (
    echo GitBox is already configured.
    pause
)