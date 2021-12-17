# Ansible-EXP

## 目录说明

### Ansible概念

基础知识与概念，方法技巧积累

### Ansible使用手册

在centos7.0上，从零开始的入门手册

### Ansible复现

从环境搭建到实验经过的过程记录

### LAN-3.pkt

实验拓扑图

### test

测试目录

### example-file，images

示例文件，图片

### 其他

各个实验目录



## 应用步骤

1. 进入实验文件夹，修改host文件和group_vars/host_vars文件夹下的变量文件
2. `ansible-playbook -i hosts.yml playbook.yml`