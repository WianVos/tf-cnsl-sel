#!/usr/bin/env bash
set -e

echo "Installing dependencies..."
if [ -x "$(command -v apt-get)" ]; then
  sudo apt-get update -y
  sudo apt-get install -y python-dev libxml2-dev libxslt1-dev zlib1g-dev libssl-dev
  sudo apt-get -y install python-pip
  sudo apt-get -y install sshpass

  sudo pip install --upgrade pip
  sudo pip install markupsafe
  sudo pip install xmltodict
  sudo pip install pywinrm
  sudo pip install ansible
  sudo pip install python-consul
fi
