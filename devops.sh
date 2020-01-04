#!/bin/sh

echo "Running apt update..."
apt update
echo "Runninng apt upgrade..."
apt upgrade -y
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
echo "extracted"
./bin/installdependencies.sh
echo "dependencies installed"
sudo -u azure_devops ./config.sh --unattended --url $1 --auth pat --token $2 --pool $3 --agent $4 --acceptTeeEula --work ./_work --runAsService
echo "configuration done"
./svc.sh install
echo "service installed"
./svc.sh start
echo "service started"
echo "config done"
exit 0
