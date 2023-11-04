#!/bin/bash

set -e 
cd "$(dirname "$0")"

if [ -d secrets ]
then
  echo ""
  echo "\`secrets/\` directory is present, refusing to proceed."
  echo ""
  echo "If you wish this script to generate secrets, delete the existing"
  echo "\`secrets/\` directory, and re-run it."
  exit 1
fi

mkdir secrets

echo "-------------------------------------------"
echo "Generating short term token signing keypair" 
echo "-------------------------------------------"
openssl genrsa 4096 > secrets/auth_root_of_trust.pem
openssl rsa -pubout < secrets/auth_root_of_trust.pem > secrets/auth_root_of_trust.pub

echo "------------------------------------------"
echo "Generating long term token signing keypair" 
echo "------------------------------------------"
openssl genrsa 4096 > secrets/auth_root_of_trust_lt.pem
openssl rsa -pubout < secrets/auth_root_of_trust_lt.pem > secrets/auth_root_of_trust_lt.pub

echo "-----------------------------------------------"
echo "Generating discovery service registration token" 
echo "-----------------------------------------------"
dd if=/dev/urandom bs=1 count=128 |  xxd -plain -c 256 > svc_reg_token_tmp
# xxd's output adds a newline - 257th char - to the output. 
# using DD here to remove it.
dd if=svc_reg_token_tmp of=secrets/svc_reg_token bs=1 count=256
rm svc_reg_token_tmp

echo "------------------------"
echo "Generating password salt"
echo "------------------------"
dd if=/dev/urandom bs=1 count=4 |  xxd -plain -c 256 > pwd_salt_tmp
# xxd's output adds a newline - 9th char - to the output. 
# using DD here to remove it.
dd if=pwd_salt_tmp of=secrets/pwd_salt bs=1 count=8
rm pwd_salt_tmp



