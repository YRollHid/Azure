#!/bin/sh

echo "Running apt update..."
sudo apt update > /tmp/apt_update
echo "Runninng apt upgrade..."
sudo apt upgrade -y > /tmp/apt_upgrade

echo "Adding Azure_DevOps User..."
adduser --quiet --disabled-password --shell /bin/bash --home /home/azure_devops --gecos "Azure Agent DevOps" azure_devops
echo "Adding Azure_DevOps user to sudoers..."
echo -e 'azure_devops\tALL=(ALL)\tNOPASSWD:\tALL' > /etc/sudoers.d/azure_devops

PUBKEY=""
echo ${PUBKEY} > /home/azure_devops/.ssh/id_rsa.pub
chown azure_devops.azure_devops /home/azure_devops/.ssh/id_rsa.pub
chmod 644 /home/azure_devops/.ssh/id_rsa.pub
