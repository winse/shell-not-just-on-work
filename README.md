# shell-not-just-on-work

用于整理工作和平时的脚本。每天更新(暂定连续更新30天)。
 
# 详情
 
* A 运维
* B 业务
 
## 列表 
 
* A-001 SSH批量无密钥登录Expect脚本 - [ssh-copy-id.expect](ssh-copy-id.expect)

```
# 用for，不要用while
HOSTS=`cat /etc/hosts | grep -v '^#' | grep slaver | grep -E '\.36\.|\.37\.' | awk '{print $2}' `
for h in $HOSTS ; do 
  ./ssh-copy-id.expect $h 'PASSWD';
done
```
  
* A-002 新机器初始化配置脚本 - [new-datanode-init.sh](new-datanode-init.sh)

```
# 首先修改新机器的密码和PUPPETSERVER的地址
# 执行命令，脚本做了如下事情：
#  1 SSH无密钥登录；
#  2 拷贝yum repo；
#  3 安装puppet-agent、mcollective；
#  4 修正hostname；
#  5 配置启动mcollective。
./new-datanode-init.sh hadoop-slaver{200..300}
```
  
* B-003 使用SparkSQL结合多种数据来源导出数据 - [extract-activeresource-domain.sh](extract-activeresource-domain.sh)
* A-004 批量修改bond的模式
* A-005 使用Puppet批量修改用户密码
* A-006 XML转CSV
