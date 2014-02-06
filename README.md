  Warning
-----------

GitBox is currently being transitioned to SrcBox, adding support for additional
versioning systems (mercurial for starters). Until the transition is complete, the
source tree should be considered unstable.

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

 - Automatic git installation and configuration
 - Creating a new git repository inside GitBox
 - Listing the repositories tracked by GitBox
 - Cloning a git repository from GitBox
 - Importing an existing git repository into GitBox

  Planned Features
--------------------

 - Repository backup creation
 - Repository merging

  Installation and Usage
--------------------------

The [project's wiki](http://github.com/karalabe/gitbox/wiki) contains a
detailed [installation](http://github.com/karalabe/gitbox/wiki/Installing-GitBox),
page, a full [command reference](http://github.com/karalabe/gitbox/wiki/Command-Reference)
and a list of [samples and tutorials](http://github.com/karalabe/gitbox/wiki/Samples-and-Tutorials)
to get you started right away.

All of these can also be found in the project's user manual available at the
[download](http://github.com/karalabe/gitbox/downloads) section.

  Very Basic Sample Usage
---------------------------

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

For more, please see the [samples and tutorials](http://github.com/karalabe/gitbox/wiki/Samples-and-Tutorials)
section in the wiki pages.

  Supported Platforms
-----------------------

Fully supported:

 - Fedora
 - Linux Mint
 - Mac OS X
 - OpenSuSE 11.1+
 - Ubuntu
 - Windows XP SP2+, Vista, Win 7
 
Partially supported:

 - Linux and *nix - Theoretically works. Requires manual git installation.
 - Windows before XP SP2 - Requires manual configuration.

  Contributions
-----------------
 
Since I have only a limited number of distros at my disposal, I'd be grateful
for testing GitBox on others and providing feedback.

Also the partially supported platforms need some work to be fully supported.
In the case of linux distributions that should be only 3-5 lines of code to
enable automatic git installation.

If you'd like to lend a hand, simply fork [my repository](http://github.com/karalabe/gitbox), hack away and contact
me when you'd like to merge something upstream.
