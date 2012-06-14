@echo off

rem Restart clause
:start

rem Unfuckup batch file processing
setlocal enabledelayedexpansion

rem Setup some global variables
set root=%~dp0
set repos=%root%\repos
set git_setup="%root%\setup\git\git.exe"

rem Look up the git command prompt either in the path or in a couple of predefined places
set paths=("C:\Program Files\Git", "C:\Program Files (x86)\Git")
set git_root=undefined

set base_path=("%PATH:;=" "%")
for %%p in %base_path% do (
    if exist %%p\git.exe (
        set base=%%~p
        set git_root="!base:~0,-4!"
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
        echo Installing git...
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
set PATH=%git_root:"=%\bin;%git_root:"=%\cmd;%PATH%
set PLINK_PROTOCOL=ssh
if "%HOME%"=="" (
    set HOME=%USERPROFILE%
)

if /i '%1'=='' (
    start sh.exe --login -i
    goto end
)
if /i '%1'=='list' (
     rem Get the group name or the default (all) and indentation (internal)
    set group=%~2
    if '%2'=='' set group=.
    set indent=%~3
    if '%3'=='' (
        set "indent= "
        echo List of repositories tracked by GitBox:
    )
    
    rem Iterate through all the groups in the requested folder and print them
    for /f "Delims=" %%d in ('dir /AD /B "%repos%\!group!"') do (
        set folder=%%d
        if not '!folder:~-4!'=='.git' (
            echo !indent!+ !folder!
            call %0 list "!group!/!folder!" "  !indent!"
        )
    )
    
    rem Iterate through all the repositories in the requested folder and print them
    for /f "Delims=" %%d in ('dir /AD /B "%repos%\!group!"') do (
        set dir=%%d
        if '!dir:~-4!'=='.git' (
            echo !indent!- !dir:~0,-4!
        )
    )
    if '%3'=='' (
        pause
    )
    goto end
)
if /i '%1'=='create' (
    rem Strip sorrounding quotes
    set repo_name=%2
    set repo_name=!repo_name:"=!
    
    set repository="%repos%\!repo_name!.git"
    if not exist !repository! (
        rem Create a new empty repository
        echo Creating empty repository...
        md !repository!
        git init --quiet --bare !repository!
    
        rem Since git doesn't like empty repos, place a README in there are save the user a lof of headaches
        echo Initializing new repository...
        set checkout="%TEMP%\!repo_name!"
        md !checkout!
        git clone --quiet --origin gitbox file://!repository! !checkout! 2>nul
    
        echo Enjoy your GitBox repository > !checkout!\README
        set pwd="%CD%"
        cd /d !checkout!
        git add README
        git commit --quiet -m "Created the repository" 2>nul
        git push --quiet gitbox master 2>nul
        cd /d !pwd!
    
        rmdir /s /q !checkout!
        echo Repository successfully created.
    ) else (
        echo A repository named "!repo_name!" is already tracked by GitBox.
        pause
    )
    goto end
)
if /i '%1'=='clone' (
    rem Strip sorrounding quotes
    set repo_name=%2
    set repo_name=!repo_name:"=!

    rem Clone the specified repository with the gitbox repo as the master
    set repository="%repos%\!repo_name!.git"
    if exist !repository! (
        echo Cloning repository...
        echo !repository!
        git clone --quiet --origin gitbox file://!repository!
        if errorlevel 1 (
            echo Failed to clone repository.
        ) else (
            echo Repository successfully cloned.
        )
    ) else (
        echo GitBox couldn't find the repository named: !repo_name!
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
        rem Strip sorrounding quotes
        set repo_name=%2
        set repo_name=!repo_name:"=!

        rem Create a new empty repository
        set repository="%repos%\!repo_name!.git"
        if not exist !repository! (
            echo Creating empty repository...
            md !repository!
            git init --quiet --bare !repository!

            rem Add an entry to the list of remote repositories and push to it
            echo Importing data into new repository...
            git remote add gitbox file://!repository!
            git push --quiet gitbox master
            echo Repository successfully imported.
        ) else (
            echo A repository named "!repo_name!" is already tracked by GitBox.
            pause
        )
    )
    goto end
)
echo Unknown GitBox command.
echo.
echo Gitbox command list:
echo   list          Lists all the git repositories tracked by GitBox.
echo   create ^<repo^> Creates a new empty git repository called ^<repo^> inside the
echo                 GitBox repository collection.
echo   clone  ^<repo^> Clones a git repository called ^<repo^> from the GitBox
echo                 collection into the current folder (remote called gitbox).
echo   import ^<repo^> Imports an existing git repository into GitBox (remote
echo                 called gitbox).
pause

rem Escape clause
:end