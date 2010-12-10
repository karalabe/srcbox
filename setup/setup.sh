#!/bin/bash

# Define some global variables
setup_path=`dirname $0`
gitbox_path="`pwd`/$setup_path/../gitbox.sh"

# Set execute permissions
chmod +x $gitbox_path

# Create a symlink to the gitbox script
mkdir -p $HOME/bin
(cd $HOME/bin && exec ln -s -f $gitbox_path gitbox)

# Make sure the symlink is in the user's path
if [ "`type -P gitbox`" == '' ]; then
    if [ ! -f $HOME/.profile ]; then
        echo 'PATH=$PATH:$HOME/bin' > $HOME/.profile
        echo >> $HOME/.profile
    else
        setter=`cat $HOME/.profile | grep '$HOME/bin'`
        if [ "$setter" == '' ]; then
            echo >> $HOME/.profile
            echo 'PATH=$PATH:$HOME/bin' >> $HOME/.profile
            echo >> $HOME/.profile
        fi
    fi
    echo "Please re-login to finalize GitBox configuration."
    echo
fi

echo "GitBox was successfully configured."
