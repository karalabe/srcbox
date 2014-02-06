#!/bin/bash

# Get the canonical path without readlink -f (OSX doesn't support it)
# The code below is the same as srcbox_path=`readlink -f $0`
dir=`pwd`

cd `dirname $0`
target=`basename $0`
while [ -L "$target" ]; do
    target=`readlink $target`
    cd `dirname $target`
    target=`basename $target`
done

srcbox_path="`pwd -P`/$target"
cd "$dir"

# Define some global variables (readlink is missing in OSX, thus the hack)
srcbox_repos="`dirname $srcbox_path`/repos"
srcbox_libs="`dirname $srcbox_path`/libs"
git_setup="`dirname $srcbox_path`/setup/git/git.sh"
hg_setup="`dirname $srcbox_path`/setup/hg/hg.sh"

# Make sure git and mercurial is available and offer to install them otherwise
function install {
    name=$1
    command=$2
    installer=$3

    if [ "`type -P $command`" == '' ]; then
        echo "SrcBox couldn't locate a valid $name installation."
        echo
        echo "If you do have it installed, please set it in your PATH variable,"
        echo "otherwise SrcBox can install one for you."
        echo

        read -p "Should SrcBox install its own $name? (y/n): " choice
        if [ "$choice" != 'y' ] && [ "$choice" != 'Y' ]; then
            echo "Aborting."
            exit
        else
            echo "Installing $name..."
            bash $installer
            if [ $? -ne 0 ]; then
                echo "SrcBox couldn't install $name."
                exit 1
            else
                echo "Successfully installed $name."
                echo "Please reissue the command in a new terminal to ensure $name is accessible."
                exit 0
            fi
        fi
    fi
}
install "git" "git" "$git_setup"
install "mercurial" "hg" "$hg_setup"

git_path=`type -P git`
hg_path=`type -P hg`

# Execute any requested operation
if [ "$1" == 'list' ]; then
    # Get the group name or the default (all) and indentation (internal)
    group=${2:-"."}
    indent=${3:-" "}
    if [ "$3" == "" ]; then
        echo "List of repositories tracked by SrcBox:"
    fi

    folders=`ls "$srcbox_repos/$group/" | wc -l`
    if [ "$folders" -ne 0 ]; then
        # Iterate through all the groups and print recursively
        for folder in "$srcbox_repos/$group"/*; do
            if [ "$folder" == "${folder%.git}" ] && [ "$folder" == "${folder%.hg}" ]; then
                folder=${folder##*/}
                echo "${indent}+ $folder"
                $0 list "$group/$folder" "$indent  "
            fi
        done

        # Iterate through all the directories in the repo folder and print them
        for repo in "$srcbox_repos/$group"/*; do
            if [ "$repo" != "${repo%.git}" ] || [ "$repo" != "${repo%.hg}" ]; then
                repo=${repo%.*}
                repo=${repo##*/}
                echo "${indent}- $repo"
            fi
        done
    fi
elif [ "$1" == 'create' ]; then
    # Make sure there's a repo to create
    if [ "$2" == "" ]; then
        echo "No repository name specified to create."
        exit 1
    fi
    raw_repo="$srcbox_repos/$2"
    git_repo="$raw_repo.git"
    hg_repo="$raw_repo.hg"

    if [ -d "$git_repo" ] || [ -d "$hg_repo" ]; then
        echo "A repository named $2 is already tracked by SrcBox."
    else
        if [ "$3" != "git" ] && [ "$3" != "hg" ]; then
            echo "Unsupported or no version control system given: '$3'."
        else
            # Source the correct library and create the new repository
            source "$srcbox_libs/$3.sh"
            create "$raw_repo"
        fi
    fi
elif [ "$1" == 'clone' ]; then
    # Make sure there's a repo to clone
    if [ "$2" == "" ]; then
        echo "No repository name specified to clone."
        exit 1
    fi
    raw_repo="$srcbox_repos/$2"
    git_repo="$raw_repo.git"
    hg_repo="$raw_repo.hg"

    # Find the version control system used
    if [ -d "$git_repo" ]; then
        vcs='git'
    elif [ -d "$hg_repo" ]; then
        vcs='hg'
    else
        echo "SrcBox couldn't find the repository named: $2"
        exit 1
    fi
    # Source the correct library and clone the repository
    source "$srcbox_libs/$vcs.sh"
    clone "$raw_repo"

elif [ "$1" == 'import' ]; then
    # Make sure there is actually a repository to import
    git rev-parse 1>&2 2>/dev/null
    if [ $? -ne 0 ]; then
        hg identify 1>&2 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "In order to import a source repository into SrcBox,"
            echo "you need to invoke the command from within the repo."
            exit 1
        else
            vcs='hg'
        fi
    else
        vcs='git'
    fi
    # Ensure repository name doesn't clash with existing ones
    raw_repo="$srcbox_repos/$2"
    git_repo="$raw_repo.git"
    hg_repo="$raw_repo.hg"

    if [ -d "$git_repo" ] || [ -d "$hg_repo" ]; then
        echo "A repository named $2 is already tracked by SrcBox."
    else
        source "$srcbox_libs/$vcs.sh"
        import "$raw_repo"
    fi
else
    echo "Unknown SrcBox command."
    echo
    echo "SrcBox command list:"
    echo "  list   [group]       Lists all the git repositories tracked by SrcBox. The optional group lists only a subgroup of the maintained repos."
    echo "  create <repo> <vcs>  Creates a new <vcs> type (git/hg) empty repository called <repo> inside the SrcBox repository collection."
    echo "  clone  <repo>        Clones a repository called <repo> from the SrcBox collection into the current folder (remote called srcbox)."
    echo "  import <repo>        Imports an existing repository into SrcBox (remote called srcbox)."
fi
