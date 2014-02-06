#!bin/bash

# Creates a new empty mercurial repository with a single README commited.
function create {
  repository="$1.hg"

  # Initialize the repository with a README file
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
  mkdir -p "$repository"
  hg clone --quiet "$checkout" "$repository" --noupdate

  rm -r -f "$checkout"
  echo "Mercurial repository successfully created."
}

# Clones a mercurial repository and sets srcbox as the origin.
function clone {
  repository="$1.hg"
  name=`basename $1`

  echo "Cloning mercurial repository..."
  hg clone --quiet "file://$repository" "$name"
  if [ $? -ne 0 ]; then
      echo "Failed to clone mercurial repository."
  else
      echo "Mercurial repository successfully cloned."
  fi
}

# Imports an external mercurial repository into srcbox.
function import {
  repository="$1.hg"

  # Import the repository
  echo "Importing repository into SrcBox..."
  mkdir -p "$repository"
  hg clone --quiet . "$repository" --noupdate

  # Add an entry to the list of remote repositories
  sed "s@\[paths\]@[paths]\nsrcbox = $repository@g" ./.hg/hgrc > ./.hg/hgrc.new
  mv -f ./.hg/hgrc.new ./.hg/hgrc

  echo "Mercurial repository successfully imported."
}
