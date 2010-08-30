#!/bin/bash

# Get the canonical path without readlink -f (OsX doesn't support it)
# The code below is the same as gitbox_path=`readlink -f $0`
dir=`pwd`

cd `dirname $0`
target=`basename $0`
while [ -L "$target" ]; do
    target=`readlink $target`
    cd `dirname $target`
    target=`basename $target`
done

gitbox_path="`pwd -P`/$target"
cd $dir

# Define some global variables (readlink is missing in OsX, thus the hack)
gitbox_repos="`dirname $gitbox_path`/repos"
git_setup="`dirname $gitbox_path`/setup/git/git.sh"

# Make sure git is available and offer to install it otherwise
if [ "`type -P git`" == '' ]; then
    if [ "$git_path" == '' ]; then
        echo "GitBox couldn't locate a valid git installation."
        echo
        echo "If you do have it installed, please set it in your PATH variable,"
        echo "otherwise GitBox can install one for you."
        echo

        read -p "Should GitBox install its own git? (y/n): " choice
        if [ "$choice" != 'y' ] && [ "$choice" != 'Y' ]; then
            echo "Aborting."
            exit
        else
            echo "Installing git..."
            bash $git_setup
            if [ $? -ne 0 ]; then
                echo "GitBox couldn't install git."
                exit 1
            else
                echo "Git successfully installed."
                echo "Please reissue the command in a new terminal to ensure git is accessible."
                exit 0
            fi
        fi
    fi
fi
git_path=`type -P git`

# If git was found, execute any requested operation, or simply start the git shell
if [ "$1" == '' ]; then
    git --version
elif [ "$1" == 'list' ]; then
    # Iterate through all the directories in the repo folder and print them
    echo "List of repositories tracked by GitBox:"
    for repo in `ls $gitbox_repos`; do
        echo " - `echo $repo | cut -d '.' -f 1`"
    done  
elif [ "$1" == 'create' ]; then
    repository="$gitbox_repos/$2.git"
    if [ -d $repository ]; then
        echo "A repository named $2 is already tracked by GitBox."
    else
        # Create a new empty repository
        mkdir -p $repository
        (cd $repository && exec git init --bare)
    
        # Since git doesn't like empty repos, place a README in there are save the user a lof of headaches
        checkout=`mktemp -d`
        git clone -o gitbox file://$repository $checkout
    
        echo Enjoy your GitBox repository > $checkout/README
        cur_dir=`pwd`
        cd $checkout
        git add README
        git commit -m "Created the repository"
        git push gitbox master
        cd $cur_dir

        rm -r -f $checkout
    fi
elif [ "$1" == 'clone' ]; then
    # Clone the specified repository with the gitbox repo as the master
    repository="$gitbox_repos/$2.git"
    if [ -d $repository ]; then
        git clone -o gitbox file://$repository
    else
        echo "GitBox couldn't find the repository named: $2"
    fi
elif [ "$1" == 'import' ]; then
    # Make sure there is actually a repository to import
    git rev-parse 2>nul
    if [ $? -ne 0 ]; then
        echo "In order to import a git repository into GitBox,"
        echo "you need to invoke the command from within the repo."
    else
        # Create a new empty repository
        repository="$gitbox_repos/$2.git"
        if [ -d $repository ]; then
            echo "A repository named $2 is already tracked by GitBox."
        else
            # Create a new empty repository
            mkdir -p $repository
            (cd $repository && exec git init --bare)

            # Add an entry to the list of remote repositories and push to it
            git remote add gitbox file://$repository
            git push gitbox master
        fi
    fi
else
    echo "Unknown GitBox command."
fi
