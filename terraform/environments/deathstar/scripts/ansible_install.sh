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

# create an ansible directory
sudo mkdir /opt/ansible

sudo mkdir /opt/ansible/modules
sudo mkdir /opt/ansible/roles
sudo mkdir /opt/ansible/logs
sudo mkdir /opt/ansible/keys


sudo chown -R ubuntu /opt/ansible
sudo chmod -R 0777 /opt/ansible

cd /opt/ansible
wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/consul_io.py -O consul_io.py
wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/consul.ini -O consul.ini
