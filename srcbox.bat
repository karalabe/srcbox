@echo off

rem Restart clause
:start

rem Unfuckup batch file processing
setlocal enabledelayedexpansion

rem Setup some global variables
set root=%~dp0
set srcbox_repos=%root%\repos
set srcbox_libs=%root%\libs

set git_setup="%root%\setup\git\git.exe"
set hg_setup="%root%\setup\hg\hg.exe"

rem Look up the vcs command prompts either in the path or in a couple of predefined places
set git_paths=("C:\Program Files\Git", "C:\Program Files (x86)\Git")
set git_root=undefined
set hg_paths=("C:\Program Files\Mercurial", "C:\Program Files (x86)\Mercurial")
set hg_root=undefined

set base_path=("%PATH:;=" "%")
for %%p in %base_path% do (
  if exist %%p\git.exe (
    set base=%%~p
    set git_root="!base:~0,-4!"
  )
  if exist %%p\hg.exe (
    set hg_root="%%~p"
  )
)
if %git_root%==undefined (
  for %%p in %git_paths% do (
    if exist %%p\bin\git.exe set git_root=%%p
  )
)
if %hg_root%==undefined (
  for %%p in %hg_paths% do (
    if exist %%p\hg.exe set hg_root=%%p
  )
)

rem If git couldn't be found, offer to install it
if %git_root%==undefined (
  echo SrcBox couldn't locate a valid git installation.
  echo.
  echo If you do have it installed, please set it in your PATH variable,
  echo otherwise SrcBox can install one for you.
  echo.
  
  set choice=undefined
  set /P choice="Should SrcBox install its own git? (y/n): "
  
  if not '!choice!'=='' set choice=!choice:~0,1!
  if /i not '!choice!'=='Y' (
    echo Aborting.
    goto end
  ) else (
    echo Installing git...
    %git_setup%
    if errorlevel 1 (
      echo SrcBox couldn't install git.
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

rem If mercurial couldn't be found, offer to install it
if %hg_root%==undefined (
  echo SrcBox couldn't locate a valid mercurial installation.
  echo.
  echo If you do have it installed, please set it in your PATH variable,
  echo otherwise SrcBox can install one for you.
  echo.
  
  set choice=undefined
  set /P choice="Should SrcBox install its own mercurial? (y/n): "
  
  if not '!choice!'=='' set choice=!choice:~0,1!
  if /i not '!choice!'=='Y' (
    echo Aborting.
    goto end
  ) else (
    echo Installing mercurial...
    %hg_setup%
    if errorlevel 1 (
      echo SrcBox couldn't install mercurial.
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

rem If the vcss were found, execute any requested operation
set PATH=%hg_root:"=%;%git_root:"=%\bin;%git_root:"=%\cmd;%PATH%
set PLINK_PROTOCOL=ssh
if "%HOME%"=="" (
  set HOME=%USERPROFILE%
)

if /i '%1'=='list' (
  rem Get the group name or the default (all) and indentation (internal)
  set group=%~2
  if '%2'=='' set group=.
  set indent=%~3
  if '%3'=='' (
    set "indent= "
    echo List of repositories tracked by SrcBox:
  )
  rem Iterate through all the groups in the requested folder and print them
  for /f "Delims=" %%d in ('dir /AD /B "%srcbox_repos%\!group!"') do (
    set folder=%%d
    if not '!folder:~-4!'=='.git' (
      if not '!folder:~-3!'=='.hg' (
        echo !indent!+ !folder!
        call %0 list "!group!/!folder!" "  !indent!"
      )
    )
  )
  rem Iterate through all the repositories in the requested folder and print them
  for /f "Delims=" %%d in ('dir /AD /B "%srcbox_repos%\!group!"') do (
    set dir=%%d
    if '!dir:~-4!'=='.git' (
      echo !indent!- !dir:~0,-4!
    )
    if '!dir:~-3!'=='.hg' (
      echo !indent!- !dir:~0,-3!
    )
  )
  if '%3'=='' (
    pause
  )
  goto :eof
)
if /i '%1'=='create' (
  rem Make sure there's a repo to create
  if [%2] == [] (
    echo No repository name specified to create.
    pause
    goto :eof
  )
  rem Strip sorrounding quotes
  set repo_name=%2
  set repo_name=!repo_name:"=!

  set raw_repo="%srcbox_repos%\!repo_name!"
  set git_repo="%srcbox_repos%\!repo_name!.git"
  set hg_repo="%srcbox_repos%\!repo_name!.hg"

  if not exist !git_repo! (
    if not exist !hg_repo! (
      rem Make sure a valid VCS is given
      if not "%3" == "git" (
        if not "%3" == "hg" (
          echo Unsupported or no version control system given: '%3'.
          pause
          goto :eof
        )
      )
      rem Source the correct library and create the new repository
      call %srcbox_libs%\%3.bat :create %2 !raw_repo!
      goto :eof
    )
  )
  echo A repository named "!repo_name!" is already tracked by SrcBox.
  pause
  goto :eof
)
if /i '%1'=='clone' (
  rem Make sure there's a repo to clone
  if [%2] == [] (
    echo No repository name specified to clone.
    pause
    goto :eof
  )
  rem Strip sorrounding quotes
  set repo_name=%2
  set repo_name=!repo_name:"=!

  set raw_repo="%srcbox_repos%\!repo_name!"
  set git_repo="%srcbox_repos%\!repo_name!.git"
  set hg_repo="%srcbox_repos%\!repo_name!.hg"

  rem Find the version control system used
  if exist !git_repo! (
    set vcs="git"
  )
  if exist !hg_repo! (
    set vcs="hg"
  )
  if "!vcs!" == "" (
    echo SrcBox couldn't find the repository named: !repo_name!
    pause
    goto :eof
  )
  rem Source the correct library and clone the repository
  call %srcbox_libs%\!vcs!.bat :clone %2 !raw_repo!
  goto :eof
)
if /i '%1'=='import' (
  rem Make sure there is actually a repository to import
  git rev-parse 2>nul
  if errorlevel 1 (
    hg identify 1>nul 2>nul
    if errorlevel 1 (
      echo In order to import a git repository into SrcBox,
      echo you need to invoke the command from within the repo.
      pause
      goto :eof
    ) else (
      set vcs="hg"
    )
  ) else (
    set vcs="git"
  )
  rem Make sure there's a repo to import into
  if [%2] == [] (
    echo No repository name specified to import into.
    pause
    goto :eof
  )
  rem Strip sorrounding quotes
  set repo_name=%2
  set repo_name=!repo_name:"=!

  set raw_repo="%srcbox_repos%\!repo_name!"
  set git_repo="%srcbox_repos%\!repo_name!.git"
  set hg_repo="%srcbox_repos%\!repo_name!.hg"

  if not exist !git_repo! (
    if not exist !hg_repo! (
      rem Source the correct library and import the repository
      call %srcbox_libs%\!vcs!.bat :import !raw_repo!
      goto :eof
    )
  )
  echo A repository named "!repo_name!" is already tracked by SrcBox.
  pause
  goto :eof
)
echo Unknown SrcBox command.
echo.
echo Gitbox command list:
echo   list   [group]       Lists all the git repositories tracked by SrcBox. The
echo                        optional group lists only a subgroup of the maintained
echo                        repos.
echo   create ^<repo^> ^<vcs^>  Creates a new empty git repository of type ^<vcs^> (git or
echo                        hg) called ^<repo^> inside the SrcBox repository database.
echo   clone  ^<repo^>        Clones a git repository called ^<repo^> from the SrcBox
echo                        collection into the current folder (with the remote
echo                        called srcbox).
echo   import ^<repo^>        Imports an existing git repository into SrcBox (remote
echo                        called srcbox).
pause

rem Escape clause
:end