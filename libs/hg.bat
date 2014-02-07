@echo off
call %*
goto :eof

rem Creates a new empty mercurial repository with a single README commited.
:create
  rem Extract and quote the parameters
  set repo_name=%~1
  set repo_path="%~2.hg"

  rem Initialize the repository with a README file
  echo Initializing new mercurial repository...
  set checkout="%TEMP%\!repo_name!"
  md !checkout!

  set pwd="%CD%"
  cd /d !checkout!
  hg init --quiet

  echo Enjoy your SrcBox repository > !checkout!\README
  hg add README
  hg commit --quiet -u "SrcBox <srcbox@karalabe.com>" -m "Created the repository"
  cd /d !pwd!

  rem Import it into the srcbox repository database
  md !repo_path!
  hg clone --quiet !checkout! !repo_path! --noupdate

  rmdir /s /q !checkout!
  echo Mercurial repository successfully created.

  goto :eof

rem Clones a mercurial repository and sets srcbox as the origin.
:clone
  rem Extract and quote the parameters
  set repo_name="%~1"
  set repo_path="%~2.hg"

  echo Cloning mercurial repository...
  hg clone --quiet !repo_path! !repo_name!
  if errorlevel 1 (
    echo Failed to clone mercurial repository.
  ) else (
    echo Mercurial repository successfully cloned.
  )
  goto :eof

rem Imports an external mercurial repository into srcbox.
:import
  rem Extract and quote the parameters
  set repo_path="%~1.hg"

  rem Create a new empty repository
  echo Importing repository into SrcBox...
  md !repo_path!
  hg clone --quiet . !repo_path! --noupdate

  rem Add an entry to the list of remote repositories
  for /F "usebackq delims=" %%A in (".\.hg\hgrc") do (
    if "%%A" == "[paths]" (
      echo %%A >> ".\.hg\hgrc.new" && echo srcbox = %~1.hg\ >> ".\.hg\hgrc.new"
    ) else (
      echo %%A >> ".\.hg\hgrc.new"
    )
  )
  move .\.hg\hgrc.new .\.hg\hgrc 1>nil

  echo Mercurial repository successfully imported.
  goto :eof
