#!/bin/sh

echo "Running yum update..."
sudo yum update -y > /tmp/yum_update

echo "Adding Azure_DevOps User..."
adduser --quiet --disabled-password --shell /bin/bash --home /home/azure_devops --gecos "Azure Agent DevOps" azure_devops
echo "Adding Azure_DevOps user to sudoers..."
echo -e 'azure_devops\tALL=(ALL)\tNOPASSWD:\tALL' > /etc/sudoers.d/azure_devops

mkdir /home/azure_devops/.ssh
chown azure_devops.azure_devops /home/azure_devops/.ssh
chmod 700 /home/azure_devops/.ssh

PUBKEY=$1
echo ${PUBKEY} > /home/azure_devops/.ssh/authorized_keys
chown azure_devops.azure_devops /home/azure_devops/.ssh/authorized_keys
chmod 644 /home/azure_devops/.ssh/authorized_keys

## add a swap file in Linux Azure virtual machines ##
sed -i 's/ResourceDisk.Format=n/ResourceDisk.Format=y/g' /etc/waagent.conf
sed -i 's/ResourceDisk.EnableSwap=n/ResourceDisk.EnableSwap=y/g' /etc/waagent.conf
sed -i 's/ResourceDisk.SwapSizeMB=0/ResourceDisk.SwapSizeMB=2048/g' /etc/waagent.conf
shutdown -r +1
