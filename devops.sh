#!/bin/sh

echo "Running apt update..."
sudo apt update > /tmp/apt_update
echo "Runninng apt upgrade..."
sudo apt upgrade -y > /tmp/apt_upgrade
echo "Installing python3-pip..."
sudo apt install -y python3-pip > /tmp/apt_install_python3_pip
echo "Installing Ansible by python3-pip..."
sudo -H pip3 install ansible > /tmp/pip_install_ansible

echo "Adding Azure_DevOps User..."
adduser --quiet --disabled-password --shell /bin/bash --home /home/azure_devops --gecos "Azure Agent DevOps" azure_devops
echo "Adding Azure_DevOps user to sudoers..."
echo -e 'azure_devops\tALL=(ALL)\tNOPASSWD:\tALL' > /etc/sudoers.d/azure_devops

echo $@
echo "start"
cd /home/azure_devops
mkdir agent
cd agent


AGENTRELEASE="$(curl -s https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest | grep -oP '"tag_name": "v\K(.*)(?=")')"
AGENTURL="https://vstsagentpackage.azureedge.net/agent/${AGENTRELEASE}/vsts-agent-linux-x64-${AGENTRELEASE}.tar.gz"
echo "Release "${AGENTRELEASE}" appears to be latest" 
echo "Downloading..."
wget -O agent.tar.gz ${AGENTURL} 
tar zxvf agent.tar.gz
chmod -R 777 .
chown -R azure_devops.azure_devops .
echo "extracted"
./bin/installdependencies.sh
echo "dependencies installed"
sudo -u azure_devops ./config.sh --unattended --deploymentgroup --deploymentgroupname $1 --url $2 --auth pat --token $3 --agent $4 --projectname $5 --addDeploymentGroupTags --deploymentGroupTags $6 --acceptTeeEula --work ./_work --runAsService
echo "configuration done"
sudo ./svc.sh install
echo "service installed"
sudo ./svc.sh start
echo "service started"
echo "config done"
exit 0
