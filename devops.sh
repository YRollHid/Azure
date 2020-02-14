#!/bin/sh

echo "Running apt update..."
sudo apt update > /tmp/apt_update
echo "Runninng apt upgrade..."
sudo apt upgrade -y > /tmp/apt_upgrade
echo "Installing python3-pip..."
sudo apt install -y python3-pip > /tmp/apt_install_python3_pip
echo "Installing Ansible by python3-pip..."
sudo -H pip3 install ansible > /tmp/pip_install_ansible
echo "Installing Atop for Monitoring..."
sudo apt install -y atop
# Add the Cloud SDK distribution URI as a package source
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud Platform public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Update the package list and install the Cloud SDK
sudo apt update && sudo apt install -y google-cloud-sdk > /tmp/apt_install_google-cloud-sdk 

echo "Adding Azure_DevOps User..."
adduser --quiet --disabled-password --shell /bin/bash --home /home/azure_devops --gecos "Azure Agent DevOps" azure_devops
echo "Adding Azure_DevOps user to sudoers..."
echo -e 'azure_devops\tALL=(ALL)\tNOPASSWD:\tALL' > /etc/sudoers.d/azure_devops

mkdir /home/azure_devops/.ssh
chown azure_devops.azure_devops /home/azure_devops/.ssh
chmod 700 /home/azure_devops/.ssh

PRIKEY=$1
echo ${PRIKEY} > /home/azure_devops/.ssh/id_rsa.raw

sed -e "s/-----BEGIN RSA PRIVATE KEY-----/&\n/"\
    -e "s/-----END RSA PRIVATE KEY-----/\n&/"\
    -e "s/\S\{64\}/&\n/g"\
    /home/azure_devops/.ssh/id_rsa.raw > /home/azure_devops/.ssh/id_rsa

rm -f /home/azure_devops/.ssh/id_rsa.raw

chown azure_devops.azure_devops /home/azure_devops/.ssh/id_rsa
chmod 600 /home/azure_devops/.ssh/id_rsa

PUBKEY=$2
echo ${PUBKEY} > /home/azure_devops/.ssh/id_rsa.pub
chown azure_devops.azure_devops /home/azure_devops/.ssh/id_rsa.pub
chmod 644 /home/azure_devops/.ssh/id_rsa.pub

echo $@
echo "start"
cd /home/azure_devops
mkdir agent
chown -R azure_devops.azure_devops agent
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
sudo -u azure_devops ./config.sh --unattended --deploymentgroup --deploymentgroupname $3 --url $4 --auth pat --token $5 --agent $6 --projectname $7 --addDeploymentGroupTags --deploymentGroupTags $8 --acceptTeeEula --work ./_work --runAsService --replace
echo "configuration done"
sudo -u azure_devops sudo ./svc.sh install
echo "service installed"
sudo -u azure_devops sudo ./svc.sh start
echo "service started"
echo "config done"
exit 0
