#!/bin/bash

# Define some global variables
setup_path=`dirname $0`
srcbox_path="`pwd`/$setup_path/../srcbox.sh"

# Set execute permissions
chmod +x $srcbox_path

# Create a symlink to the srcbox script
mkdir -p $HOME/bin
(cd $HOME/bin && exec ln -s -f $srcbox_path srcbox)

# Make sure the symlink is in the user's path
if [ "`type -P srcbox`" == '' ]; then
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
    echo "Please re-login to finalize SrcBox configuration."
    echo
fi

echo "SrcBox was successfully configured."
