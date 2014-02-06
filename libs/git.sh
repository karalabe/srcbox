#!bin/bash

# Creates a new empty git repository with a single README commited.
function create {
	repository="$1.git"

  # Create a new empty repository
  echo "Creating empty git repository..."
  mkdir -p "$repository"
  (cd "$repository" && exec git init --quiet --bare)

  # Initialize the repository with a README file
  echo "Initializing new git repository..."
  checkout=`mktemp -d srcbox.XXXXXXXX`
  git clone --quiet "file://$repository" $checkout

  echo "Enjoy your SrcBox repository" > $checkout/README
  cur_dir=`pwd`
  cd "$checkout"
  git add README
  git commit --quiet --author="SrcBox <srcbox@karalabe.com>" -m "Created the repository"
  git push --quiet origin master 1>/dev/null
  cd "$cur_dir"

  # Cleanup the temporary repository
  rm -r -f "$checkout"
  echo "Git repository successfully created."
}

# Clones a git repository and sets srcbox as the origin.
function clone {
	repository="$1.git"

  echo "Cloning git repository..."
  git clone --quiet --origin srcbox "file://$repository"
  if [ $? -ne 0 ]; then
    echo "Failed to clone git repository."
  else
    echo "Git repository successfully cloned."
  fi
}

# Imports an external git repository into srcbox.
function import {
	repository="$1.git"

  # Create a new empty repository
  echo "Creating empty git repository..."
  mkdir -p "$repository"
  (cd "$repository" && exec git init --quiet --bare)

  # Add an entry to the list of remote repositories and push to it
  echo "Importing data into new git repository..."
  git remote add srcbox "file://$repository"
  git push --quiet srcbox master 1>/dev/null

  echo "Git repository successfully imported."
}
