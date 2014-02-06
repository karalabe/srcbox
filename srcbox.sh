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
    git_repo="$srcbox_repos/$2.git"
    hg_repo="$srcbox_repos/$2.hg"

    if [ -d "$git_repo" ] || [ -d "$hg_repo" ]; then
        echo "A repository named $2 is already tracked by SrcBox."
    else
        if [ "$3" != "git" ] && [ "$3" != "hg" ]; then
            echo "Unsupported or no version control system given: '$3'."
        else
            # If git is the versioning system, create a bare repo and inject a readme
            if [ "$3" == "git" ]; then
                # Create a new empty repository
                echo "Creating empty git repository..."
                mkdir -p "$git_repo"
                (cd "$git_repo" && exec git init --quiet --bare)

                # Since git doesn't like empty repos, place a README in there and save the user a lof of headaches
                echo "Initializing new git repository..."
                checkout=`mktemp -d srcbox.XXXXXXXX`
                git clone --quiet "file://$git_repo" $checkout
            
                echo "Enjoy your SrcBox repository" > $checkout/README
                cur_dir=`pwd`
                cd "$checkout"
                git add README
                git commit --quiet --author="SrcBox <srcbox@karalabe.com>" -m "Created the repository"
                git push origin master 1>/dev/null
                cd "$cur_dir"

                rm -r -f "$checkout"
                echo "Git repository successfully created."

            # If mercurial is the versioning system, create the temporary repo and import into srcbox
            elif [ "$3" == "hg" ]; then
                # Initialize the repository with the sole readme
                echo "Initializing new mercurial repository..."
                checkout=`mktemp -d srcbox.XXXXXXXX`
                (cd "$checkout" && exec hg init --quiet)

                echo "Enjoy your SrcBox repository" > $checkout/README
                cur_dir=`pwd`
                cd "$checkout"
                hg add README
                hg commit --quiet -u "SrcBox <srcbox@karalabe.com>" -m "Created the repository"
                cd "$cur_dir"

                # Import it into the srcbox repository database
                mkdir -p "$hg_repo"
                hg clone "$checkout" "$hg_repo" --noupdate

                rm -r -f "$checkout"
                echo "Mercurial repository successfully created."
            fi        
        fi
    fi
elif [ "$1" == 'clone' ]; then
    # Make sure there's a repo to clone
    if [ "$2" == "" ]; then
        echo "No repository name specified to clone."
        exit 1
    fi
    git_repo="$srcbox_repos/$2.git"
    hg_repo="$srcbox_repos/$2.hg"

    if [ -d "$git_repo" ]; then
        # Clone the specified git repository with the srcbox repo as the master
        echo "Cloning git repository..."
        git clone --quiet --origin srcbox "file://$git_repo"
        if [ $? -ne 0 ]; then
            echo "Failed to clone git repository."
        else
            echo "Git repository successfully cloned."
        fi
    elif [ -d "$hg_repo" ]; then
        # Clone the specified mercurial repository
        echo "Cloning mercurial repository..."
        hg clone --quiet "file://$hg_repo" "$2"
        if [ $? -ne 0 ]; then
            echo "Failed to clone mercurial repository."
        else
            echo "Mercurial repository successfully cloned."
        fi
    else
        echo "SrcBox couldn't find the repository named: $2"
    fi
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
    git_repo="$srcbox_repos/$2.git"
    hg_repo="$srcbox_repos/$2.hg"

    if [ -d "$git_repo" ] || [ -d "$hg_repo" ]; then
        echo "A repository named $2 is already tracked by SrcBox."
    else 
        if [ "$vcs" == "git" ]; then
            # Create a new empty repository
            echo "Creating empty git repository..."
            mkdir -p "$git_repo"
            (cd "$git_repo" && exec git init --quiet --bare)

            # Add an entry to the list of remote repositories and push to it
            echo "Importing data into new git repository..."
            git remote add srcbox "file://$git_repo"
            git push srcbox master 1>/dev/null

            echo "Git repository successfully imported."
        elif [ "$vcs" == "hg" ]; then
            # Import the repository
            echo "Importing repository into SrcBox..."
            mkdir -p "$hg_repo"
            hg clone . "$hg_repo" --noupdate

            # Add an entry to the list of remote repositories
            sed "s@\[paths\]@[paths]\nsrcbox = $hg_repo@g" ./.hg/hgrc > ./.hg/hgrc.new
            mv -f ./.hg/hgrc.new ./.hg/hgrc

            echo "Mercurial repository successfully imported."
        fi
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
