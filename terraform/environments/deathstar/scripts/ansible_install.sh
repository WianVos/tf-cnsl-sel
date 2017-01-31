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
curl https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/consul_io.py -o consul_io.py
chmod +x /opt/ansible/consul_io.py

curl https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/consul.ini -o consul.ini

#install the ansible terraform integration
curl https://github.com/jonmorehouse/terraform-provisioner-ansible/releases/download/0.0.2/terraform-provisioner-ansible
# curl https://github.com/jonmorehouse/terraform-provisioner-ansible/releases/download/0.0.1-terraform-provisioner-ansible.tar.gz -o /opt/terraform/terraform-provisioner-ansible.tar.gz
#
# tar -xvf /opt/terraform/terraform-provisioner-ansible.tar.gz /opt/terraform/
#
# cat << EOF > ~/.terraformrc
#   ansible = "/opt/terraform/terraform-provisioner-ansible"
# EOF
