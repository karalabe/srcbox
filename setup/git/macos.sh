#!/bin/bash

# Define some global variables
git_root=`dirname $0`
git_macos="$git_root/git.pkg"

# Install the git package
echo "Installing git with sudo..."
sudo installer -pkg $git_macos -target /
