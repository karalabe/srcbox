#!/bin/bash

# Define some global variables
hg_root=`dirname $0`
hg_macos="$hg_root/hg.mpkg"

# Install the hg package
echo "Installing hg with sudo..."
sudo installer -pkg $hg_macos -target /
