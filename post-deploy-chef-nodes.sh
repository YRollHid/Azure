#!/bin/sh

echo "Running yum update..."
sudo yum update -y > /tmp/yum_update

echo "Adding Azure_DevOps User..."
sudo adduser --quiet --disabled-password --shell /bin/bash --home /home/azure_devops --gecos "Azure Agent DevOps" azure_devops
echo "Adding Azure_DevOps user to sudoers..."
sudo echo -e 'azure_devops\tALL=(ALL)\tNOPASSWD:\tALL' > /etc/sudoers.d/azure_devops

sudo mkdir /home/azure_devops/.ssh
sudo chown azure_devops.azure_devops /home/azure_devops/.ssh
sudo chmod 700 /home/azure_devops/.ssh

PUBKEY=$1
sudo echo ${PUBKEY} > /home/azure_devops/.ssh/authorized_keys
sudo chown azure_devops.azure_devops /home/azure_devops/.ssh/authorized_keys
sudo chmod 644 /home/azure_devops/.ssh/authorized_keys

## add a swap file in Linux Azure virtual machines ##
sudo sed -i 's/ResourceDisk.Format=n/ResourceDisk.Format=y/g' /etc/waagent.conf
sudo sed -i 's/ResourceDisk.EnableSwap=n/ResourceDisk.EnableSwap=y/g' /etc/waagent.conf
sudo sed -i 's/ResourceDisk.SwapSizeMB=0/ResourceDisk.SwapSizeMB=2048/g' /etc/waagent.conf
sudo shutdown -r +1
