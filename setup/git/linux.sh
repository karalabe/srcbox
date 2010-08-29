#!/bin/bash

# SuSE distribution
if [ -f /etc/SuSE-release ]; then
    dist=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/\(.*//`
    ver=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
    if [ `echo $dist | cut -d ' ' -f 1` == 'openSUSE' ]; then
        echo "OpenSuSE v$ver found."
        if [ `type -P zypper` != '' ]; then
            echo "Installing git with sudo zypper..."
            sudo zypper --non-interactive install git
            exit
        fi
    else
        echo "Unsupported SuSE distribution."
        echo "Please install git manually."
        exit 1
    fi
# Ubuntu distribution
elif [ -f /etc/lsb-release ]; then
    dist=`cat /etc/lsb-release | grep _ID | tr -d "\n" | sed s/.*=//`
    ver=`cat /etc/lsb-release | grep _REL | tr -d "\n" | sed s/.*=//`
    echo "$dist $ver"
    if [ "$dist" == 'Ubuntu' ]; then
        echo "Ubuntu v$ver found."
        echo "Installing git with sudo apt-get..."
        sudo apt-get --assume-yes install git-core
        exit
    fi
#Unknown distribution    
else
    echo "Unsupported Linux distribution."
    echo "Please install git manually."
    exit 1
fi
