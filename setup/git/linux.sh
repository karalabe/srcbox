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
# Ubuntu and derivative distributions
elif [ -f /etc/lsb-release ]; then
  dist=`cat /etc/lsb-release | grep _ID | tr -d "\n" | sed s/.*=//`
  ver=`cat /etc/lsb-release | grep _REL | tr -d "\n" | sed s/.*=//`
  if [ "$dist" == 'Ubuntu' ]; then
    echo "Ubuntu v$ver found."
    echo "Installing git with sudo apt-get..."
    sudo apt-get --assume-yes install git-core
    exit
  elif [ "$dist" == 'LinuxMint' ]; then
    echo "Linut Mint v$ver found."
    echo "Installing git with sudo apt-get..."
    sudo apt-get --assume-yes install git-core
    exit
	fi
# Fedora distribution
elif [ -f /etc/fedora-release ]; then
  dist=`cat /etc/fedora-release | tr "\n" ' ' | sed s/\ release.*//`
  ver=`cat /etc/fedora-release | tr "\n" ' ' | sed s/.*release\ // | sed s/\ .*//`
  if [ `echo $dist | cut -d ' ' -f 1` == 'Fedora' ]; then
    echo "Fedora v$ver found."
    echo "Checking for sudo access to yum..."
    sudo -l yum
    if [ $? -eq 0 ]; then
      echo "Installing git with sudo yum..."
      sudo yum --assumeyes install git-core
      exit
    else
      echo "Installing git with root privileges..."
      su root -c "yum --assumeyes install git-core"
      exit
    fi
  else
    echo "Unsupported Fedora distribution."
    echo "Please install git manually."
    exit 1
  fi
# Unknown distribution
else
  echo "Unsupported Linux distribution."
  echo "Please install git manually."
  exit 1
fi
