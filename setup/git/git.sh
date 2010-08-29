#!/bin/bash

# Define some global variables
git_root=`dirname $0`
git_linux="$git_root/linux.sh"

# Check for supported operating systems and run specific installers
if [ `uname -s` == "Linux" ]; then
    echo "Linux operating system found."
    bash $git_linux
    exit
elif [ `uname -s` == "SunOS" ]; then
    echo "Solaris operating system found."
    echo "GitBox doesn't support git installation on Solaris yet."
    echo "Please install git manually."
    exit 1
else
    echo "Unknown operating system found."
    echo "Please install git manually."
    exit 1
fi

