#!/bin/bash

# Figure out which distribution we're using
if [ -f /etc/SuSE-release ]; then
    dist=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/\(.*//`
    ver=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
    if [ `echo $dist | cut -d ' ' -f 1` == 'openSUSE' ]; then
        echo "OpenSuSE v$ver found"
        if [ `type -P zypper` != '' ]; then
            echo "Installing git with sudo..."
            sudo zypper --non-interactive install git
            exit $?
        fi
    else
        echo "Unsupported SuSE distribution."
        echo "Please install git manually."
        exit -1
    fi
else
    echo "Unsupported Linux distribution."
    echo "Please install git manually."
    exit -1
fi