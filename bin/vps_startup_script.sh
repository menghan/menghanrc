#!/bin/bash

set -e

apt-get update
apt-get install -y ansible git

git clone https://github.com/menghan/menghanrc /var/menghanrc
ansible-playbook -c local -i localhost, /var/menghanrc/ansible/setup_docker.yml
