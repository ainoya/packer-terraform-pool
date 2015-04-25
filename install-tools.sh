#!/bin/sh


sudo sh <<'SCRIPT'

cd /tmp

# install terraform

TF="terraform_0.3.7_linux_amd64"

wget -q https://dl.bintray.com/mitchellh/terraform/${TF}.zip
unzip -o ${TF}.zip -d /usr/local/bin

# install jq

wget -q http://stedolan.github.io/jq/download/linux64/jq
chmod +x ./jq
cp ./jq /usr/local/bin/

# installpacker

PACKER="packer_0.7.5_linux_amd64"

wget -q https://dl.bintray.com/mitchellh/packer/${PACKER}.zip
unzip -o ${PACKER}.zip -d /usr/local/bin/

SCRIPT
