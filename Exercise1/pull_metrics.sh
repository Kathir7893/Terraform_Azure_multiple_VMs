#!/bin/bash
# This script pulls metrics like CPU, Disk, Network stats of VMs created by Terraform

PRIV_KEY=/tmp/priv_key.ppk
more terraform.tfstate | jq -r .outputs.tls_private_key.value > $PRIV_KEY
chmod 600 $PRIV_KEY


for ip in `more terraform.tfstate | jq -r .resources[0].instances[].attributes.public_ip_address`
do
 ssh -q -i $PRIV_KEY -oStrictHostKeyChecking=no azureuser@$ip << EOF
  echo ***** Machine Details *****
  hostname
  hostname -i
  echo && echo ***** CPU USAGE *****
  top -b -n 1
  echo && echo ***** NETWORK STATS *****
  sudo netstat -tulpna
  echo && echo ***** DISK USAGE *****
  df -Th && echo
EOF
done

