#!/bin/bash
apt-get update && apt-get upgrade -y && apt-get autoremove && apt-get autoclean 2>&1
apt-get -y install git 2>&1 
apt-get -y install nodejs 2>&1
apt-get -y install npm 2>&1
cd /root
git clone https://github.com/pranavprem/ReactCalculator.git 2>&1
cd ReactCalculator
npm install 2>&1 
npm run dev 2>&1