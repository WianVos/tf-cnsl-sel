#!/usr/bin/env bash
set -e

echo "Installing dependencies..."
if [ -x "$(command -v apt-get)" ]; then
  sudo apt-get update -y
  sudo apt-get install -y unzip
else
  sudo yum update -y
  sudo yum install -y unzip wget
fi

echo "Fetching Terraform..."
TERRAFORM_VERSION=0.8.4
cd /tmp
curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip

echo "Installing Terraform..."
unzip terraform.zip > /dev/null
chmod +x terraform
sudo mkdir /opt/terraform
sudo chown ubuntu /opt/terraform
sudo chmod 0664 /opt/terraform
sudo mv terraform /opt/terraform

echo "initializing the consul state backend"
cd /opt/terraform
./terraform remote config \
    -backend=consul \
    -backend-config="path=tf/state"
