# Ansible概念

### 控制节点（Control node）

任何安装了 Ansible 的机器。您可以作为控制节点调用`/usr/bin/ansible`或`/usr/bin/ansible-playbook`命令，以控制节点机器。您可以将任何安装了 Python 的计算机用作控制节点——笔记本电脑、共享台式机和服务器都可以运行 Ansible。但是，您不能将 Windows 机器用作控制节点。另外，控制节点可以有多个。



### 被管理节点（Managed nodes）

您使用 Ansible 管理的网络设备（或服务器），有时也称为“主机”。不需要安装Ansible。



### 库存（Inventory）

受管理节点列表。库存文件可以为每个受管节点指定 IP 地址等信息，还创建和嵌套组以便于扩展。

#### 示例

```yml
--- # [webserver] 192.168.144.17
webserver:
  hosts:
    centos-demo-1:
      ansible_host: 192.168.144.17
      ansible_port: 22
...
```

```yml
--- # [webservers]demo-1-2 [ungrouped]demo-3
all:
  hosts:
    demo-3.example.com:
  children:
    webservers:
      hosts:
        centos-demo-1:
        centos-demo-2:
```

#### 默认组

有两个默认组：`all`和`ungrouped`。`all`组包含每个主机，`ungrouped`组包含所有没被分组的主机。每个主机至少会属于两个组（`all`和`ungrouped` 或 `all`和其他一些组）。虽然`all`并且`ungrouped`始终存在，但它们可以是隐式的，不出现在`group_names`中。



### 集合（Collections）

### 模块（Modules）

### 任务（Tasks）

### 剧本（Playbooks）

#### Jinja2过滤器

> https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html

##### 未定义变量的默认值

```jinja2
{{ some_variable | default(5) }}
{{ some_variable | default("default") }}
```

##### 定义三元函数

```jinja2
# ANS_VER >= 1.9
{{ (status == 'needs_restart') | ternary('restart', 'continue') }}
# ANS_VER >= 2.8
{{ enable | ternary('no shutdown', 'shutdown', omit) }}
```

##### 调试查看数据类型

```jinja2
{{ var | type_debug }}
```

##### 字典列表互相转换

```jinja2
# dict -> list
{{ dict | dict2items }}
# change dict's key and value
{{ files | dict2items(key_name='file', value_name='path') }}

# list -> dict
{{ tags | items2dict }}
{{ tags | items2dict（key_name='xxx', value_name='xxx' }}
```

##### 强制类型转换(ANS_VER >= 1.6)

```yml
when: var | bool
```

##### 格式化输出（YAML和JSON）

```jinja2
{{ var | to_json }} # 默认转换为ASCII
{{ var | to_yaml(ensure_ascii=False) }} # 避免转码，保留Unicode字符（ANS_VER >= 2.7）
{{ var | to_nice_json(width=66) }} # 避免以外换行
{{ var | to_nice_yaml(indent=2) }} # indent: 缩进
{{ some_variable | from_json }} # 已经格式化的数据
{{ some_variable | from_yaml }}

{{ var | from_yaml_all | list }} # 更多解析YAML文件的方式
```

##### 数据结构取值

```jinja2
{{ [0,2] | map('extract', ['x','y','z']) | list }} -> ['x', 'z']
{{ ['x','y'] | map('extract', {'x': 42, 'y': 31}) | list }} -> [42, 31]
```

##### JSON查询

```json
{
    "domain_definition": {
        "domain": {
            "cluster": [
                {
                    "name": "cluster1"
                },
                {
                    "name": "cluster2"
                }
            ],
            "server": [
                {
                    "name": "server11",
                    "cluster": "cluster1",
                    "port": "8080"
                },
                {
                    "name": "server12",
                    "cluster": "cluster1",
                    "port": "8090"
                },
                {
                    "name": "server21",
                    "cluster": "cluster2",
                    "port": "9080"
                },
                {
                    "name": "server22",
                    "cluster": "cluster2",
                    "port": "9090"
                }
            ],
            "library": [
                {
                    "name": "lib1",
                    "target": "cluster1"
                },
                {
                    "name": "lib2",
                    "target": "cluster2"
                }
            ]
        }
    }
}
```

```yml
# 提取集群名
loop: "{{ domain_definition | community.general.json_query('domain.cluster[*].name') }}"

# 从cluster1中提取端口（变量定义过滤方法）
loop: "{{ domain_definition | community.general.json_query(server_name_cluster1_query) }}"
  vars:
    server_name_cluster1_query: "domain.server[?cluster=='cluster1'].port"

# 以逗号分割打印字符串（反引号引用文字，也可以使用{'单引号''转义''单引号'} === {'单引号`转义`单引号'}）
msg: "{{ domain_definition | community.general.json_query('domain.server[?cluster==`cluster1`].port') | join(', ') }}"

# 字符串判断(使用`startwith`和`contains`时，`to_json | from_json`是必须的)
ansible.builtin.debug:
    msg: "{{ domain_definition | to_json | from_json | community.general.json_query(server_name_query) }}"
  vars:
    server_name_query: "domain.server[?starts_with(name,'server1')].port"
    # server_name_query: "domain.server[?contains(name,'server1')].port"
```

##### 数据统计

```jinja2
# 判断
{{ [3, 4, 2] | max }}
{{ [{'val': 1}, {'val': 2}] | min(attribute='val') }}

# 集合
# list1: [1, 2, 5, 1, 3, 4, 10]
{{ list1 | unique }} # -> [1, 2, 5, 3, 4, 10]

{{ list1 | union(list2) }} # 并集
{{ list1 | intersect(list2) }} # 交集
```

##### 网络管理

```jinja2
{{ myvar | ansible.netcommon.ipaddr }}
{{ myvar | ansible.netcommon.ipv4 }}
{{ '192.0.2.1/24' | ansible.netcommon.ipaddr('address') }} # -> 192.168.0.1
```

##### URL解析

```jinja2
{{ 'Trollhättan' | urlencode }} # -> 'Trollh%C3%A4ttan'
{{ "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment" | urlsplit }}
# ->
#   {
#       "fragment": "fragment",
#       "hostname": "www.acme.com",
#		...

{{ "http://user:password@www.acme.com:9000/dir/index.html?query=term#fragment" | urlsplit('↓VALUE↓') }}
```

| VALUE    | OUTPUT                          |
| -------- | ------------------------------- |
| hostname | www.acme.com                    |
| netloc   | user:password@www.acme.com:9000 |
| username | user                            |
| password | password                        |
| path     | /dir/index.html                 |
| port     | 9000                            |
| schema   | http                            |
| query    | query=term                      |
| fragment | fragment                        |

##### 正则

```jinja2
{{ 'ansible' | regex_search('foobar') }} # -> ''
{{ 'ansible' | regex_search('foobar') == none }} # -> True
{{ 'server1/database42' | regex_search('database[0-9]+') }} # -> 'database42'
{{ 'server1/database42' | regex_search('server([0-9]+)/database([0-9]+)', '\\1', '\\2') }} # -> ['1', '42']
```

##### 文件与路径

```jinja2
{{ "/etc/hosts" | basename }} -> "hosts"
{{ path | dirname }}
```

##### 字符串

```yml
ansible.builtin.shell: echo {{ string_value | quote }} # 为字符串添加引号
{{ list | join("") }} # 列表拼接字符串
# 编解码（默认是'utf-8'）
{{ encoded | b64decode(encoding='utf-16-le') }}
{{ decoded | string | b64encode }}
```



#### 调试

```yml
vars:
  url: "https://example.com/users/foo/resources/bar"

tasks:
  - debug:
      msg: "matched pattern 1"
    when: url is match("https://example.com/users/.*/resources")
    
  - debug:
      msg: "matched pattern 2"
    when: url is search("users/.*/resources/.*")
    
  - debug:
      msg: "matched pattern 3"
    when: url is search("users")
    
  - debug:
      msg: "matched pattern 4"
    when: url is regex("example\.com/\w+/foo")
```



#### 查找

##### lookup("file", path_to_file)

```yml
  vars:
    host_file: "{{ lookup('file', '/etc/hosts') }}"
  tasks:
  - name: test
    debug:
      msg: "host file is {{ host_file }}"
# return ↓
# ok: [centos-demo-1] => {
#     "msg": "host file is 127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4\n::1     #     localhost localhost.localdomain localhost6 localhost6.localdomain6"
# }
```

##### lookup("env", "HOME")

```yml
  vars:
    env_HOME: "{{ lookup('env','HOME') }}"
  tasks:
  - name: test
    debug:
      msg: "env:HOME is {{ env_HOME }}"
# return ↓
# ok: [centos-demo-1] => {
#     "msg": "env:HOME is /home/centos-control"
# }
```



#### 模板（Templates）

##### python2和3的差异

```yml
vars:
  hosts:
    testhost1: 127.0.0.2
    testhost2: 127.0.0.3
tasks:
  - debug:
      msg: '{{ item }}'
    # Only works with Python 2
    # loop: "{{ hosts.keys() }}"
    # loop: "{{ hosts.iteritems() }}"
    
    # Works with both Python 2 and Python 3
    loop: "{{ hosts.keys() | list }}"
    loop: "{{ hosts.items() | list }}"
```







### 配置文件

Changes can be made and used in a configuration file which will be searched for in the following order:

> - `ANSIBLE_CONFIG` (environment variable if set)
> - `ansible.cfg` (in the current directory)
> - `~/.ansible.cfg` (in the home directory)
> - `/etc/ansible/ansible.cfg`

Ansible will process the above list and use the first file found, all others are ignored.



