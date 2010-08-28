  GitBox - Git repository hosting inside a Dropbox folder
===========================================================

GitBox is a cross platform tool to host personal private git repositories inside
Dropbox folders that get automatically synchronized between operating systems,
machines and backed up on the internet.

Although everything the tool does can be done manually, the goal was to make
things simple and user friendly without having to remember a long list of git
commands and paths.


  Features
------------

 - Listing the repositories tracked by GitBox
 - Creating a new git repository inside GitBox
 - Cloning a git repository from GitBox
 - Imporint an existing git repository into GitBox


  Installation
----------------

The project Wiki is uner construction, in the mean time please check the
[User Manual](http://github.com/downloads/karalabe/gitbox/GitBox-0.1.0-UserManual.pdf) available at the download section.


  Sample Usage
----------------

From computer A:
    $ gitbox create myapp
    $ gitbox clone myapp

    // Do some work
    $ git add <some files>
    $ git commit -m "Commit message"
    $ git push gitbox

From computer B:
    $ gitbox clone myapp
    // Do some work and push as previously

From computer A:
    $ git pull gitbox master
    // Do some work
    // .....

Until the project Wiki will be completed, for a full list of supported commands,
check the [User Manual](http://github.com/downloads/karalabe/gitbox/GitBox-0.1.0-UserManual.pdf) included both in the installation package and also
downloadable from the project's download page.


  Supported Platforms
-----------------------

Fully supported:
 - OpenSuSE 11.1+
 - Windows XP SP2+, Vista, Win 7
 
Partially supported:
 - Linux and *nix - Theoretically works. Requires manual git installation.
 - Windows before XP SP2 - Check installation details in the user manual.
 
I'd be grateful for testing on other distros and feedback on them. Also
implementing automatic installation of git would be fantastic.
