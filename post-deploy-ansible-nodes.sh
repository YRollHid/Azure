#!/bin/sh

echo "Running apt update..."
sudo apt update > /tmp/apt_update
echo "Runninng apt upgrade..."
sudo apt upgrade -y > /tmp/apt_upgrade

echo "Adding Azure_DevOps User..."
adduser --quiet --disabled-password --shell /bin/bash --home /home/azure_devops --gecos "Azure Agent DevOps" azure_devops
echo "Adding Azure_DevOps user to sudoers..."
echo -e 'azure_devops\tALL=(ALL)\tNOPASSWD:\tALL' > /etc/sudoers.d/azure_devops

mkdir /home/azure_devops/.ssh
chown azure_devops.azure_devops /home/azure_devops/.ssh
chmod 700 /home/azure_devops/.ssh

PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDGi6uwgJH9e+sr/bIJlWzDun9u0d8Ir/lHRl8fvS0+FKXqeLtI/Avz/bGI0Uz85FIH+kWN2KdyMocdaTJHSvnTR+xmG+gAiZmHQLZlQopjmNyYDyYLUsRQtO2xwTQ7zMAAwAtY6giwjEHcrciFtsRzdMU2vMRAsN0gEjABRY0KY2ZHFMSeTtfaKVkA28pRxsWCTl3KbO3aA5nrZE30XE6sT/wZA0z7gaRn1cItnx/ZtL4hTeIt6rBbNV59kRVSD56xztxcZWJ8Gy87JYVr5LqPJu6lYvXnS+/xtP7RjLWb7B0qPDHhVarnSX08OZMiuU0abpy6IXxphjxiEWDlDztLchynlrwdWwImag3ysaqc6C/DbmebyTZ4hm78GM+VW6lzRYYBrO1nKaTdGvDZ8s8MG4HKeQqmeHLmOSZivOWOtxsC1p2YnLQbLpr/4e7NtWqTFMkTlLm7zL6VW5W6LVMSirNgJLswV5yld7x6iU2kPifTpfPrHg+kWGL3QtLaL0ZnWlx+BLjn+X+LFpFW+g1vuH515stCyDvioj4vBnwOA69iiNoCJVtnWbYrFApY7Ex/f699lPIFnPsT3c1HKe+TxuDoSQuJtcAjkhp3bK2XndXJ9u1siFTOOza/0eJlySa2sYUxWyvPV4jafBXrU3kxXPOcd8+Gr5cxY/bpa/1K6Q== gitlab"
echo ${PUBKEY} > /home/azure_devops/.ssh/authorized_keys
chown azure_devops.azure_devops /home/azure_devops/.ssh/authorized_keys
chmod 644 /home/azure_devops/.ssh/authorized_keys

## add a swap file in Linux Azure virtual machines ##
sed -i 's/ResourceDisk.Format=n/ResourceDisk.Format=y/g' /etc/waagent.conf
sed -i 's/ResourceDisk.EnableSwap=n/ResourceDisk.EnableSwap=y/g' /etc/waagent.conf
sed -i 's/ResourceDisk.SwapSizeMB=0/ResourceDisk.SwapSizeMB=2048/g' /etc/waagent.conf
reboot
