#!/usr/bin/env bash

#install git
sudo apt-get install -y git

# if that is succesfull lets clone some repos

git clone http://github.com/wianvos/ansible-selenium-server.git /opt/ansible/roles/selenium
git clone https://github.com/WianVos/tf_basic.git /opt/terraform/environments/basic
