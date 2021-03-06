  SrcBox - Assembly Instructions
==================================

Since the project itself is extremely simple, containing only a couple of script
files and some binary installers, there was little point in creating build and
assembly scripts. Rather this document was written containing the needed steps
to create a SrcBox distributable package.

Note, that the program is designed to be run from within Dropbox, which means
that executables and required binaries for **all** platforms should be bundled up,
since the very same "installation" will be used on all platforms.

Should You wish to automate this, you are welcome to do so, but please be aware
that great emphasis was put on operating system interoperability and all scripts
(build ones included) should conform to it. (i.e. if you implement automated
builds in Linux, then make sure it/something works in Windows too :P).

Another thing to take care of is the line endings, since they are different in
*nix and Windows. Please make sure the shell script line endings are *nix specific
and the batch file line endings are Windows specific.

  Distributable Package
-------------------------

SrcBox is distributed as a simple compressed zip file, which should be extracted
directly into a Dropbox folder. For details, see the user manual.

The structure of the distribution package is as follows:

    SrcBox             // The program root
      - docs           // Documentation
        - srcbox.pdf   // User manual pdf file (generated from the .docx)
      - repos          // Empty folder for the git repositories
      - setup          // Folder containing installation and configuration files
        - git          // Setup files for installing git
          - git.exe    // Git for Windows* installer
          - git.pkg    // Git package for Mac OS X**
          - git.sh     // Git installer for *nix flavors
          - linux.sh   // Git installer for Linux distributions
          - macos.sh   // Git installer for Mac OS X
        - hg           // Setup files for installing mercurial
          - hg.exe     // Mercurial for Windows*** installer
          - hg.mpkg    // Mercurial package for Mac OS X****
          - hg.sh      // Mercurial installer for *nix flavors
          - linux.sh   // Mercurial installer for Linux distributions
          - macos.sh   // Mercurial installer for Mac OS X
        - setup.bat    // Windows config file to set the path variable
        - setup.sh     // *nix config file to set execute permissions and symlinks
      - srcbox.bat     // Windows implementation of SrcBox
      - srcbox.sh      // *nix implementation of SrcBox

\* Git for Windows: Since installing git on Windows is not as straightforward as
in the case of Linux, a binary installer from the msysGit project should be also
bundled with SrcBox. As of writing, the latest stable Git for Windows installer
can be downloaded from http://code.google.com/p/msysgit/downloads/list . If you
bundle a newer version of Git for Windows than previously done, please make sure
it actually works. The name of the correct version to download has the form:
Git-a.b.c.d-previewYYYYMMDD.exe

\** Git for Mac OS X: As in the case of Windows, installing git on Mac OS X is
harder that it should be, so a binary package from the git-osx-installer project
http://code.google.com/p/git-osx-installer/downloads/list . Take care, that these
are image files (.dmg), and the package (.pkg) should be extracted first.

\*** Mercurial for Windows: Although installing mercurial is significantly more
straightforward under Windows (stock hg works), it should also be bundled for
the sake of simplicity. Currently http://mercurial.selenic.com/downloads/
contains the mercurial packages. To ensure cross compatibility, the 32 bit kit
should be added to the distributable package.

\**** Mercurial for Mac OS X: Mercurial for OSX should also be bundled into the
SrcBox distributable package. The http://mercurial.selenic.com/downloads/ site
hosts these packets too, being in a zipped meta pagkace (.mpkg) formet. Extract
the package (will probably result in a folder under mortal operating systems)
and insert it among the mercurial kits.
