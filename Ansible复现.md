# Ansible复现

> 官方文档：https://docs.ansible.com/ansible/latest/

## 环境搭建

### 拓扑(HOST-ONLY网卡)

 ![image-20211208005537034](C:\Users\h3wyf\AppData\Roaming\Typora\typora-user-images\image-20211208005537034.png)



### 前提的前提

- Ansible版本 2.12+

- 控制节点：Python 3.8
- 被管理节点：Python 2 (version 2.6 or later) or Python 3 (version 3.5 or later)
- 管理云中的机器，选用该云中的机器作为控制节点更合适
- ubuntu安装ssh

```bash
#!/bin/bash

# 修改root密码
sudo passwd root
> ubuntu-control

# 安装配置ssh
sudo apt update && sudo apt install openssh-sftp-server ncurses-term ssh-import-id openssh-client
sudo vi /etc/ssh/ssh_config
# 去注释 PasswordAuthentication yes
sudo vi /etc/ssh/sshd_config
# 去注释 PermitRootLogin yes
sudo /etc/init.d/ssh restart

```

- debian配置网卡 <https://www.debian.org/doc/manuals/debian-handbook/sect.network-config.zh-cn.html>

```bash
# 默认无sudo
su root

vi /etc/network/interfaces
# NAT网卡配置
# auto enp0s3
# iface enp0s3 inet dhcp
# HOST-ONLY网卡配置
# auto enp0s8
# iface enp0s8 inet dhcp

/etc/init.d/networking restart
```



### 控制节点的先决条件(ubuntu-control)

```bash
#!/bin/bash

# 安装pip（确保是最新版）
sudo apt update && sudo apt install python3-pip -y

# 安装连接模块
# 全局安装：`sudo ...`
# 除非完全了解修改系统上全局文件的含义，否则建议with `--user` 参数
pip install paramiko --user 

```



### 控制节点安装Ansible

#### 在 Ubuntu 上安装 Ansible

Ubuntu 构建在 [PPA](https://launchpad.net/~ansible/+archive/ubuntu/ansible) 中可用（官方推荐）。

要配置 PPA 并安装 Ansible，运行以下命令：

```bash
$ sudo apt update
$ sudo apt install software-properties-common
$ sudo add-apt-repository --yes --update ppa:ansible/ansible
$ sudo apt install ansible
```

***在较旧的 Ubuntu 发行版中，“software-properties-common”被称为“python-software-properties”，旧版本中使用`apt-get`而不是`apt`。只有较新的发行版（即 18.04、18.10 等）才有`-u`or`--update`标志***



#### 在Debian上安装Ansible

Debian 用户可以使用与 Ubuntu PPA 相同的源代码（使用下表）。

| Debian            |      | Ubuntu                 |
| ----------------- | ---- | ---------------------- |
| Debian 11（靶心） | ->   | Ubuntu 20.04（焦点）   |
| Debian 10（克星） | ->   | Ubuntu 18.04（仿生）   |
| Debian 9（扩展）  | ->   | Ubuntu 16.04 (Xenial)  |
| Debian 8 (杰西)   | ->   | Ubuntu 14.04（可信赖） |

***从 Ansible 4.0.0 开始，只会为 Ubuntu 18.04 (Bionic) 或更高版本生成新版本。***

将以下行添加到`/etc/apt/sources.list`or `/etc/apt/sources.list.d/ansible.list`：

```
deb http://ppa.launchpad.net/ansible/ansible/ubuntu MATCHING_UBUNTU_CODENAME_HERE main
```

Debian 11 示例（靶心）

```
deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main
```

然后运行这些命令：

```bash
$ sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
$ sudo apt update
$ sudo apt install ansible
```



#### 在RHEL、CentOS或Fedora上安装Ansible

在 Fedora 上：

```bash
$ sudo dnf install ansible
```

在 RHEL 上：

```bash
$ sudo yum install ansible
```

在 CentOS 上：

```bash
$ sudo yum install epel-release
$ sudo yum install ansible
```



## 实现

### 配置文件

Changes can be made and used in a configuration file which will be searched for in the following order:

> - `ANSIBLE_CONFIG` (environment variable if set)
> - `ansible.cfg` (in the current directory)
> - `~/.ansible.cfg` (in the home directory)
> - `/etc/ansible/ansible.cfg`

Ansible will process the above list and use the first file found, all others are ignored.



