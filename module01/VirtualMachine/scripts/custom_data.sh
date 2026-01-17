#!/bin/sh
# THIS IS THE CUSTOM DATA SCRIPT THAT INSTALLS ONCE VIRTUAL MACHINE IS DEPLOYED
# cat /var/log/cloud-init-output.log
# IT TAKES A FEW MINUTES AFTER DEPLOYMENT TO INSTALL ALL TOOLS
# variables are substituted with the dollar curly syntax
sudo apt update
sudo apt upgrade -y
userHomeDir=${user_home_dir}
if ! [ "$userHomeDir" ]; then 
	echo "ERROR: userHomeDir must be defined"
	exit 1
fi
cd $userHomeDir
echo "STARTING IN THE $(pwd)"

#====================== INSTALL TERRAFORM ======================================
# GET TERRAFORM DEPENDENCY
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
# INSTALL HASHICORP GPG KEY
wget -O- https://apt.releases.hashicorp.com/gpg | \
	gpg --dearmor | \
	sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
	# VERIFY FINGERPRINT
gpg --no-default-keyring \ 
	--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
	--fingerprint
# Add Hashicorp Repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
	https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
	sudo tee /etc/apt/sources.list.d/hashicorp.list
# EXECUTE DOWNLOAD PACKAGE INFORMATION
sudo apt update
# INSTALL TERRAFORM ON MACHINE
sudo apt-get install -y terraform
# VERIFY TERRAFORM EXISTS
terraform version

#====================== INSTALL AZURE CLI ======================================
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

#====================== INSTALL FUNC CLI =======================================
# VALIDATE PACKAGE
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
#INSTALL
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs 2>/dev/null)-prod $(lsb_release -cs 2>/dev/null) main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-get update
sudo apt-get install -y azure-functions-core-tools-4

#========================= Install Python 3.10 ===================================
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.10
sudo apt install -y python3.10-venv python3.10-distutils
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

#======================= Install Docker ==========================================
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


#======================= Install Helm ==========================================
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm

# #======================Install Kubectl ===========================================
# # download
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#Install
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
#validate
kubectl version --client
# cleanup files
rm -f kubectl

# =====================Install NVM and Node=================================================
# Does not activate from user dir, .nvm is loaded in /.nvm from the shell script
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

NVM_DIR="/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
echo "export NVM_DIR=$NVM_DIR" >> .bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm' >> .bashrc

# Download and install Node.js v22:
nvm install 22
# Verify the Node.js version:
node -v # Should print "v22.13.0".
nvm current # Should print "v22.13.0".
# Verify npm version:
npm -v # Should print "10.9.2".

echo "I AM WORKING IN THE $(pwd) directory"