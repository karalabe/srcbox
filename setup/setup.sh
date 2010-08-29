#!/bin/bash

# Define some global variables
setup_path=`readlink -f $0`
gitbox_path="`dirname $setup_path`/../gitbox.sh"

# Set execute permissions and link into user's bin folder
chmod +x $gitbox_path

if [ ! -d $HOME/bin ]; then
    mkdir -p $HOME/bin
    echo "Created a bin folder in your home directory."
    echo "Please re-login to update your path accordingly."
    echo
fi
(cd $HOME/bin && exec ln -s -f $gitbox_path gitbox)

echo "GitBox was successfully configured."

