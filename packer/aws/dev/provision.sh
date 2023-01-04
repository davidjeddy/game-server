#!/bin/bash -e

# exec > >(sudo tee /var/log/packer.log | sudo logger -t user-data -s 2> /dev/console) 2>&1

# -----
# Server wide configurations
# -----

echo "INFO: Starting..."

echo "INFO: Configure journal log limiting"
echo "[Journal]
/RuntimeMaxUse=4G
SystemMaxUse=4G" > sudo /etc/systemd/journald.conf

# -----
# Server wide packages install and configuration
# -----

echo "INFO: Install system packages"
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
sudo apt-add-repository 'deb https://download.mono-project.com/repo/ubuntu stable-focal main'

sudo apt-get update -y
sudo apt-get install -y \
    apt-transport-https \
    awscli \
    ca-certificates \
    dirmngr \
    gnupg \
    iotop \
    jq \
    software-properties-common
sudo apt-get autoremove -y

echo "INFO: System package location and versions"
aws --version
jq --version
which aws
which jq

# -----
# Service system package requirements
# -----

echo "INFO: Install Golang language and runtime"
echo steam steam/question select "I AGREE" | sudo -u root debconf-set-selections
echo steam steam/license note "" | sudo -u root debconf-set-selections
sudo dpkg --add-architecture i386

sudo apt-get update -y
sudo apt-get install -y \
    golang \
    mono-complete \
    steamcmd
sudo apt-get autoremove -y

## KSP Needs

echo "INFO: KSP system packages"
go version
mono --version
which go
which mono

## PA:Titans Needs

echo "INFO: Planetary Annihilation : Titans system packages"
sudo apt-get update -y
sudo apt-get install -y \
    libgl1-mesa-glx \
    libsdl2-dev \
    libsm6 \
    libxext6
sudo apt-get autoremove -y

## Satisfactory Needs

echo "INFO: Install Satisfactory system packages" 
sudo apt-get update -y
sudo apt-get install -y \
    lib32gcc1 \
    libsdl2-2.0-0
sudo apt-get autoremove -y
