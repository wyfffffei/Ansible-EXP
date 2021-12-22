# flying科学小实验

## 环境
centos 7.0/8.0

## 实现
进入 `group_vars` 目录，在 `flyingserver.yml` 文件添加服务器信息；

回到根目录
```bash
# 分别执行
vi 0_environment_init.sh
vi 1_deploy_the_flying.sh

# 分别修改
:set ff=unix
:wq
```

运行
```bash
bash 0_environment_init.sh
bash 1_deploy_the_flying.sh
```

建议centos 8.0
