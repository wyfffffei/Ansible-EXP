#!/bin/bash
# source 1_deploy_the_flying.sh

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i hosts.yml flying.yml