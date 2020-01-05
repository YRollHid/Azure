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

PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxllbjmuj/JH5HvHBjED2QHE+YYJZdwdzqG7gYRa9piwwZ7hogujtymVwaKYuoiBT+58Q9pcJqAqFj51n4zq6clY7nkNsvQkRJu7A6YKYVaIwpXg/F/cHaSK0VHR3tTr7NgGOu9CYjUq7zLwbLYC8WsMxm74qpGPUjf10GUTT6ayahnsx1UKN8+WBxUo6QmmXOn2eBomhVPgpR1XFO6GWqgywH4Btv29GmyvkRnxpuzqLWb5tGXntTwzEMh41NYNlAZ1mxHASaFN9LWzi7keZhqRRJzUyShA2XmITV7jeLxD7AGdWoeVivDq/vYpa1GIDj1OqewvELvIqCChusobZH creating SSH"
echo ${PUBKEY} > /home/azure_devops/.ssh/id_rsa.pub
chown azure_devops.azure_devops /home/azure_devops/.ssh/id_rsa.pub
chmod 644 /home/azure_devops/.ssh/id_rsa.pub
