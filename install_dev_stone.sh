#!/usr/bin/env bash

# DESCRIPTION: install stone basic dependencies
# REQUIREMENTS: sudo
# USAGE: chmod +x install_dev_stone.sh && ./install_dev_stone.sh

# set asdf git url & versions
asdf_git="https://github.com/asdf-vm/asdf.git"
# check latest version here: https://github.com/asdf-vm/asdf/releases/latest
asdf_version="v0.12.0"

echo "Updating system"
sudo apt-get update

# Inlibs to install
echo "Installing libs"
sudo apt install -y curl git docker docker-compose awscli chromium-browser ca-certificates gpg jq apt-transport-https gnupg

# install kubectl
echo "Installing kubctl"
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

sudo apt-get install -y kubectl

# Kubectx and Kubens installation
echo "Installing kubectx and Kubens"
sudo git clone https://github.com/ahmetb/kubectx.git /opt/kubectx

sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx

sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

COMPDIR=$(pkg-config --variable=completionsdir bash-completion)

sudo ln -sf /opt/kubectx/completion/kubens.bash $COMPDIR/kubens

sudo ln -sf /opt/kubectx/completion/kubectx.bash $COMPDIR/kubectx

#Install vault
echo "Installing vault"
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update
sudo apt install vault -y
systemctl start vault

# asdf installation
echo "Installing asdf"
git clone $asdf_git ~/.asdf --branch $asdf_version

# Add configs to bash or zsh
echo "Add configs to bash or zsh"
read -p "What is your shell, Bash or ZSH ? enter [B or Z]: " my_shell
if [[ "$my_shell" = "B"||"b" ]]; then
echo ". $HOME/.asdf/asdf.sh" >> ~/.bashrc
echo ". $HOME/.asdf/completions/asdf.bash" >> ~/.bashrc
echo "export PATH=/opt/kubectx:\$PATH" >> ~/.bashrc
echo "added to bashrc"
else
echo ". $HOME/.asdf/asdf.sh" >> ~/.zshrc
mkdir -p ~/.oh-my-zsh/custom/completions
chmod -R 755 ~/.oh-my-zsh/custom/completions
sudo ln -s /opt/kubectx/completion/_kubectx.zsh ~/.oh-my-zsh/custom/completions/_kubectx.zsh
sudo ln -s /opt/kubectx/completion/_kubens.zsh ~/.oh-my-zsh/custom/completions/_kubens.zsh
echo "fpath=($ZSH/custom/completions $fpath)" >> ~/.zshrc
# autocompletions or use ohmyzsh asdf plugins
fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit
compinit
echo "added to zshrc"
fi

#create .github.token
read -p "Do you want to create the github token? enter [S or N]: " gitTokenCreate
echo "Create github token file"
if [[ "$gitTokenCreate" = "S"||"s" ]]; then
mkdir ~/.github-token
read -p "Enter your hash key:" gitToken
echo "$gitToken" >> ~/.github-token
else 
fi

echo "cleaning up"
sudo apt autoremove
echo "Installation done"
