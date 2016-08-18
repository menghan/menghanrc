#!/bin/bash

set -e

echo 'Acquire::ForceIPv4 "true";' | tee /etc/apt/apt.conf.d/99force-ipv4
apt-get update
apt-get install -y ansible git

git clone https://github.com/menghan/menghanrc /var/menghanrc || (cd /var/menghanrc; git pull)
ansible-playbook -c local -i localhost, /var/menghanrc/ansible/setup_docker.yml
