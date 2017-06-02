# shell-not-just-on-work

用于整理工作和平时的脚本。每天更新(暂定连续更新30天)。
 
# 详情
 
* A 运维
* B 业务
* D 开发
 
## 列表 
 
* A-001 SSH批量无密钥登录Expect脚本 - [ssh-copy-id.expect](ssh-copy-id.expect)

```
# 用for，不要用while
$ HOSTS=`cat /etc/hosts | grep -v '^#' | grep slaver | grep -E '\.36\.|\.37\.' | awk '{print $2}' `
$ for h in $HOSTS ; do 
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
$ ./new-datanode-init.sh hadoop-slaver{200..300}
```
  
* B-003 使用SparkSQL结合多种数据来源导出数据 - [extract-activeresource-domain.sh](extract-activeresource-domain.sh)
* A-004 批量修改bond的模式
* A-005 使用Puppet批量修改用户密码
* A-006 XML转CSV - [format.xslt](format.xslt)

```
$ xsltproc format.xslt hadoop-2.6.3/etc/hadoop/core-site.xml 
```

* A-007 类似 kubectl exec 功能 - [pod_bash](pod_bash) 

```
$ pod_bash CONTAIN_NAME NAMESPACE
```

* A-008 K8S下测试集群快速搭建 - [deploy-cluster-on-k8s.sh](deploy-cluster-on-k8s.sh) [simple-hadoop.yaml](simple-hadoop.yaml)
* A-009 不重启Docker的情况下通过国内加速下载Docker镜像（for centos6） - [docker-download-mirror](docker-download-mirror)
* A-010 突破堡垒机 - [堡垒机LogonScript.vbs](堡垒机LogonScript.vbs) 
* A-011 Scala生产小测试(本地连接生产，层层阻隔，任意的调用java接口还是挺麻烦的，使用scala直接连接口还是挺方便的)

```
$ /data/bigdata/scala-2.11.8/bin/scala -cp '/home/hadoop/query-3.0/lib/common/*:/home/hadoop/query-3.0/lib/core/*' 
: paste

..

CTRL+D

: load file.scala(不能含package)

// 然后根据你的业务写代码，就可以调用接口了

```

* A-012 Shell并发N执行 - [.bash_multi](.bash_multi) 有很多其他的工具可以控制并发N的执行：xargs, mco puppet, pssh

```
source .bash_multi

WORK_MULTI_THREADS=1

threadpool_start;

# don't use while pipeline: [... | while read line ...]  !
for line in `cat $WORK_LIST` ;  do
  function handle(){
  }
  function doit(){
    handle "$@" ; 
    threadpool_release ;
  }
  
  threadpool_require;
  
  if [ $WORK_MULTI_THREADS -le 1 ] ; then 
    doit $line
  else 
    doit $line & 
  fi
done

threadpool_destory;

```

* B-002 定时（结合crontab）根据情况修改分析数据库配置表 - [dynamic_access_conf.sh](dynamic_access_conf.sh)
* D-001 本地Cygwin命令打开当前路径 - [cygexplorer](cygexplorer)
* D-002 快速打开Eclipse中选中的文件（夹）所在目录 - [explorer.launch](explorer.launch)
* A-013 windows本地跑Zookeeper - [win-zkServers.bat](win-zkServers.bat)
