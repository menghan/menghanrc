#!/bin/bash

set -e

apt-get update -o Acquire::ForceIPv4=true
apt-get install -y -o Acquire::ForceIPv4=true ansible git

git clone https://github.com/menghan/menghanrc /var/menghanrc
ansible-playbook -c local -i localhost, /var/menghanrc/ansible/setup_docker.yml
