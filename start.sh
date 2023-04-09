#!/bin/bash

#https://kafka.apache.org/quickstart


mp launch -n kafka -d 20G -m 2G
cat <<'EOF' | mp exec kafka bash -
sudo apt-get -y update
sudo apt-get -y dist-upgrade
sudo apt-get -y install sudo git vim curl tmux
sudo apt-get -y install openjdk-17-jdk-headless
sudo useradd -s /bin/bash -m om
echo 'om ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/om
EOF
