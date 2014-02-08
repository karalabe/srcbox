  Warning
-----------

GitBox is currently being transitioned to SrcBox, adding support for additional
versioning systems (mercurial for starters). Until the transition is complete, the
source tree should be considered unstable.

  SrcBox - Source code inside Dropbox
===========================================================

SrcBox is a cross platform tool to host personal private source repositories
inside Dropbox folders that get automatically synchronized between operating
systems, machines and backed up on the internet.

Although everything the tool does can be done manually, the goal was to make
things simple and user friendly without having to remember a long list of DSVC
commands and paths.

  Features
------------

 - Automatic SVC (git/hg) installation and configuration
 - Creating a new source repository inside SrcBox
 - Listing the repositories tracked by SrcBox
 - Cloning a repository from SrcBox
 - Importing an existing repository into SrcBox

  Installation and Usage
--------------------------

The [project's wiki](http://github.com/karalabe/srcbox/wiki) contains a
detailed [installation](http://github.com/karalabe/srcbox/wiki/Installing-SrcBox),
page, a full [command reference](http://github.com/karalabe/srcbox/wiki/Command-Reference)
and a list of [samples and tutorials](http://github.com/karalabe/srcbox/wiki/Samples-and-Tutorials)
to get you started right away.

All of these can also be found in the project's user manual available at the
[download](http://github.com/karalabe/srcbox/downloads) section.

  Very Basic Sample Usage
---------------------------

From computer A:

    $ srcbox create myapp git
    $ srcbox clone myapp

    // Do some work
    $ git add <some files>
    $ git commit -m "Commit message"
    $ git push srcbox

From computer B:

    $ srcbox clone myapp
    // Do some work and push as previously

From computer A:

    $ git pull srcbox master
    // Do some work
    // .....

For more, please see the [samples and tutorials](http://github.com/karalabe/srcbox/wiki/Samples-and-Tutorials)
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
for testing SrcBox on others and providing feedback.

Also the partially supported platforms need some work to be fully supported.
In the case of Linux distributions that should be only 3-5 lines of code to
enable automatic git installation.

If you'd like to lend a hand, simply fork [my repository](http://github.com/karalabe/srcbox), hack away and contact
me when you'd like to merge something upstream.
