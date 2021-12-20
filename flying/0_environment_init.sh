#!/bin/bash
# env: centos
# run as a root

yum update -y && yum install epel-release -y
yum install ansible -y

pyv=$(python3 -V 2>&1 | grep -Po '(?<=Python )(.+)')
echo $pyv
if [[ -z "$pyv" ]]
then
    yum install python3 -y
fi

python3 -m pip install --user paramiko -y
# pip install --user -i https://pypi.tuna.tsinghua.edu.cn/simple paramiko -y
sudo yum install sshpass -y
