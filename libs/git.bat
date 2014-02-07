@echo off
call %*
goto :eof

rem Creates a new empty git repository with a single README commited.
:create
  rem Extract and quote the parameters
  set repo_name=%~1
  set repo_path="%~2.git"

  rem Create a new empty repository
  echo Creating empty git repository...
  md !repo_path!
  git init --quiet --bare !repo_path!

  rem Initialize the repository with a README file
  echo Initializing new git repository...
  set checkout="%TEMP%\!repo_name!"
  md !checkout!
  git clone --quiet file://!repo_path! !checkout!

  echo Enjoy your SrcBox repository > !checkout!\README
  set pwd="%CD%"
  cd /d !checkout!
  git add README
  git config user.name "SrcBox"
  git config user.email "srcbox@karalabe.com"
  git commit --quiet -m "Created the repository"
  git push --quiet origin master
  cd /d !pwd!

  rmdir /s /q !checkout!
  echo Git repository successfully created.

  goto :eof

rem Clones a git repository and sets srcbox as the origin.
:clone
  rem Extract and quote the parameters
  set repo_name=%~1
  set repo_path="%~2.git"

  echo Cloning git repository...
  git clone --quiet --origin srcbox file://!repo_path!
  if errorlevel 1 (
    echo Failed to clone git repository.
  ) else (
    echo Git repository successfully cloned.
  )
  goto :eof

rem Imports an external git repository into srcbox.
:import
  rem Extract and quote the parameters
  set repo_path="%~1.git"

  rem Create a new empty repository
  echo Creating empty git repository...
  md !repo_path!
  git init --quiet --bare !repo_path!

  rem Add an entry to the list of remote repositories and push to it
  echo Importing data into new git repository...
  git remote add srcbox file://!repo_path!
  git push --quiet srcbox master 1>nul

  echo Git repository successfully imported.
  goto :eof
