#!/bin/bash

# update repositories
sudo apt update -y

# install ansible
sudo apt install ansible -y

curl -sL https://deb.nodesource.com/setup_10.x | bash

sudo apt install nodejs npm -y