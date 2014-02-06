#!/bin/bash

# Define some global variables
hg_root=`dirname $0`
hg_linux="$hg_root/linux.sh"
hg_macos="$hg_root/macos.sh"

# Check for supported operating systems and run specific installers
if [ `uname -s` == "Linux" ]; then
  echo "Linux operating system found."
  bash $hg_linux
  exit
elif [ `uname -s` == "Darwin" ]; then
  echo "Mac operating system found."
  bash $hg_macos
  exit
else
  echo "Unknown operating system found."
  echo "Please install mercurial manually."
  exit 1
fi
