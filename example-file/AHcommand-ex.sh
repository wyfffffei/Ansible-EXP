## 
#  ad hoc commands examples

#  format: $ ansible [pattern] -m [module] -a "[module options]"

#  @PARAM pattern: group/host  <-> √
#  @PARAM -i: inventroy        <-> √
#  @PARAM -m: module name
#  @PARAM -a: command/options
#  @PARAM -u: connector

# simple examples
# live command
$ ansible all -a "/bin/echo hello"
# using ping module to test all the nodes in the inventory
$ ansible all -m ping
# shell module with variable
$ ansible all -m ansible.builtin.shell -a 'echo $(date)'

# Managing files (copy,file module) | more: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html#file-module>
# copy module
$ ansible all -m ansible.builtin.copy -a "src=/etc/hosts dest=/tmp/hosts"
# file module to copy (same options ↑)
$ ansible webservers -m ansible.builtin.file -a "dest=/srv/foo/b.txt mode=600 owner=mdehaan group=mdehaan"
# file module run `mkdir -p`
$ ansible webservers -m ansible.builtin.file -a "dest=/path/to/c mode=755 owner=mdehaan group=mdehaan state=directory"
# file module to delete files
$ ansible webservers -m ansible.builtin.file -a "dest=/path/to/c state=absent"

# Managing packages (yum module)
# To ensure a package is installed without updating it
$ ansible webservers -m ansible.builtin.yum -a "name=acme state=present"
# ensure a specific version is installed
$ ansible webservers -m ansible.builtin.yum -a "name=acme-1.5 state=present"
# ensure version is at a latest version
$ ansible webservers -m ansible.builtin.yum -a "name=acme state=latest"
# ensure version is absent
$ ansible webservers -m ansible.builtin.yum -a "name=acme state=absent"

# Manageing users and groups | more: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html#user-module>
$ ansible all -m ansible.builtin.user -a "name=foo password=<xxxxx>"
$ ansible all -m ansible.builtin.user -a "name=foo state=absent"

# Managing services
# service state changing ('state': {'started', 'restarted', 'stopped'})
$ ansible webservers -m ansible.builtin.service -a "name=httpd state=started"

# Gathering facts (information about the remote systems)
$ ansible all -m ansible.builtin.setup

# privilege escalation (like sudo)
$ ansible all -m ping -u bruce --become --become-user root


# templates
# template module | more: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html#template-module>
$ ansible all -m ansible.builtin.template -a "src=/templates/file.j2 dest=/log/file.conf"


# playbooks | more: <https://docs.ansible.com/ansible/latest/user_guide/playbooks.html>
# run the playbook
$ ansible-playbook -i iventory.yml playbook.yml
