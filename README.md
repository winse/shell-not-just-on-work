# shell-not-just-on-work

用于整理工作和平时的脚本。每天更新(暂定连续更新30天)。
 
# 详情
 
* A 运维
* B 业务
 
## 列表 
 
* A-001 SSH批量无密钥登录Expect脚本
  # 用for，不要用while
  for h in `cat /etc/hosts | grep -v '^#' | grep slaver | grep -E '\.36\.|\.37\.' | awk '{print $2}' ` ; do 
    ./ssh-copy-id.expect $h 'PASSWD';
  done
* A-002 新机器初始化配置脚本
* B-003 使用SparkSQL结合多种数据来源导出数据
* A-004 批量修改bond的模式
* A-005 使用Puppet批量修改用户密码
