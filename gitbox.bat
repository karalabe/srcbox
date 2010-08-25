@echo off

rem Restart clause
:start

rem Unfuckup batch file processing
setlocal enabledelayedexpansion

rem Setup some global variables
set root=%~dp0
set repos=%root%\repos
set git_setup="%root%\setup\dat\git.exe"

rem Look up the git command prompt either in the path or in a couple of predefined places
set paths=("C:\Program Files\Git", "C:\Program Files (x86)\Git")
set git_root=undefined

set base_path=("%PATH:;=" "%")
for %%p in %base_path% do (
    if exist %%p\git.exe (
        set base=%%p
        set git_root=!base:~0,-4!
    )
)
if %git_root%==undefined (
    for %%p in %paths% do (
        if exist %%p\bin\git.exe set git_root=%%p
    )
)

rem If the git couldn't be found, offer to install it
if %git_root%==undefined (
    echo GitBox couldn't locate a valid git installation.
    echo.
    echo If you do have it installed, please set it in your PATH variable,
    echo otherwise GitBox can install one for you.
    echo.
    
    set choice=undefined
    set /P choice="Should GitBox install its own git? (y/n): "
    
    if not '!choice!'=='' set choice=!choice:~0,1!
    if /i not '!choice!'=='Y' (
        echo Aborting.
        goto end
    ) else (
        echo Installing git
        %git_setup%
        if errorlevel 1 (
            echo GitBox couldn't install git.
            pause
        ) else (
            echo Git successfully installed.
            echo Continuing with initial command.
            echo.
            
            rem Restart the script to execute the initial command
            goto start
        )
    )
    goto end
)

rem If git was found, execute any requested operation, or simply start the git shell
set PATH=%git_root%\bin;%git_root%\cmd;%PATH%
set PLINK_PROTOCOL=ssh
if "%HOME%"=="" (
    set HOME=%USERPROFILE%
)

if /i '%1'=='' (
    start %COMSPEC% /K git --version
    goto end
)
if /i '%1'=='list' (
    rem Iterate through all the hidden directories in the repoo folder and print them
    echo List of repositories tracked by GitBox:
    for /f "Delims=" %%d in ('dir /ADH /B "%repos%"') do (
        set dir=%%d
        echo  - !dir:~0,-4!
    )
    pause
    goto end
)
if /i '%1'=='create' (
    set repository="%repos%"\%2.git
    if not exist !repository! (
        rem Create a new empty repository
        md !repository!
        git init --bare !repository!
    
        rem Since git doesn't like empty repos, place a README in there are save the user a lof of headaches
        set checkout="%TEMP%"\%2
        md !checkout!
        git clone -o dropbox file://!repository! !checkout!
    
        echo Enjoy your GitBox repository > !checkout!\README
        set pwd=%CD%
        cd /d !checkout!
        git add README
        git commit -m "Created the repository"
        git push dropbox master
        cd /d !pwd!
    
        rmdir /s /q !checkout!
    ) else (
        echo A repository named "%2" is already tracked by GitBox
        pause
    )
    goto end
)
if /i '%1'=='clone' (
    rem Clone the specified repository with the dropbox repo as the master
    set repository="%repos%"\%2.git
    if exist !repository! (
        git clone -o dropbox file://!repository!
    ) else (
        echo GitBox couldn't find the repository named: %2
        pause
    )
    goto end
)
if /i '%1'=='import' (
    rem Make sure there is actually a repository to import
    git rev-parse 2>nul
    if errorlevel 1 (
        echo In order to import a git repository into GitBox,
        echo you need to invoke the command from within the repo.
        pause
    ) else (
        rem Create a new empty repository
        set repository="%repos%"\%2.git
        if not exist !repository! (
            md !repository!
            git init --bare !repository!

            rem Add an entry to the list of remote repositories and push to it
            git remote add dropbox file://!repository!
            git push dropbox master
        ) else (
            echo A repository named "%2" is already tracked by GitBox
            pause
        )
    )
    goto end
)

rem Escape clause
:end