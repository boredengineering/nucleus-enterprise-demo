#!/bin/bash

LATEST_RELEASE=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r .current_version)
CURRENT_RELEASE=$(terraform version -json | jq -r .terraform_version)
if [[ ${LATEST_RELEASE} != $CURRENT_RELEASE ]]; then
   echo "Installing Terraform ${LATEST_RELEASE}..."
   
   FILENAME=terraform_${LATEST_RELEASE}_linux_amd64.zip
   wget https://releases.hashicorp.com/terraform/${LATEST_RELEASE}/$FILENAME
   unzip $FILENAME && rm $FILENAME 
   sudo mv terraform /usr/local/bin
else
   echo "Latest version of Terraform (${LATEST_RELEASE}) already installed."
fi