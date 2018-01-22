# shell-not-just-on-work

用于整理工作和平时的脚本。每天更新(暂定连续更新30天)。
 
# 详情
 
* A 运维
* B 业务
* D 开发
* :yum: 自我觉得不错
 
## 列表 
 
#### A-001 :yum: SSH批量无密钥登录Expect脚本 - [ssh-copy-id.expect](ssh-copy-id.expect)

搞几台测试的机器:

```
docker run -d cu.eshore.cn/library/java:jdk8 /usr/sbin/sshd -D
docker run -d cu.eshore.cn/library/java:jdk8 /usr/sbin/sshd -D
docker run -d cu.eshore.cn/library/java:jdk8 /usr/sbin/sshd -D
```

结合for使用:

```
$ HOSTS=` docker ps | head -4 | grep -v IMAGE | awk '{print $1}' | xargs -I{} docker exec {} ifconfig | grep '10.' | awk -F' |:' '{print $(NF-6)}' `
$ for h in $HOSTS ; do 
  ./ssh-copy-id.expect $h 'root';
done
```

结合while使用:

```
$ docker ps | head -4 | grep -v IMAGE | awk '{print $1}' | xargs -I{} docker exec {} ifconfig | grep '10.' | awk -F' |:' '{print $(NF-6)}' | while read h ; do  
  ./ssh-copy-id.expect $h 'root' </dev/null ; 
done 
```

#### A-002 新机器初始化配置脚本 - [new-datanode-init.sh](new-datanode-init.sh)

首先新机器的密码PASSWD和Puppet服务器地址PUPPETSERVER两个环境变量；然后执行命令:

```
$ ./new-datanode-init.sh hadoop-slaver{200..300}
```

脚本做了如下事情：

  1. SSH无密钥登录；
  2. 拷贝yum repo；
  3. 安装puppet-agent、mcollective；
  4. 修正hostname；
  5. 配置启动mcollective。
  
#### B-003 使用SparkSQL结合多种数据来源导出数据 - [extract-activeresource-domain.sh](extract-activeresource-domain.sh)
#### A-004 批量修改bond的模式
#### A-005 :yum: [使用Puppet批量修改用户密码](http://www.winseliu.com/blog/2016/09/06/puppet-modify-password/)
#### A-006 :yum: XML转CSV - [format.xslt](format.xslt)

```
$ xsltproc format.xslt hadoop-2.6.3/etc/hadoop/core-site.xml 
```

#### A-007 类似 kubectl exec 的功能 - [pod_bash](pod_bash) 

```
$ pod_bash CONTAIN_NAME NAMESPACE
```

#### A-008 K8S下测试环境集群快速搭建 - [deploy-cluster-on-k8s.sh](deploy-cluster-on-k8s.sh)  [simple-hadoop.yaml](simple-hadoop.yaml)
#### A-009 :yum: 不重启Docker的情况下通过国内加速下载Docker镜像（for centos6） - [docker-download-mirror](docker-download-mirror)
#### A-010 :yum: 突破堡垒机 - [堡垒机LogonScript.vbs](堡垒机LogonScript.vbs), 需要了解本地端口转发、远程端口转发。
#### A-011 Scala生产小测试(生产调用java接口还是挺麻烦的-- :boom: 可以做Sockt5代理，直接运行scala连接接口还是挺方便的)

```
$ scala -cp 'lib/common/*:lib/core/*' 
```

然后结合 ` : paste ` 和 ` CTRL+D ` 以及 ` : load file.scala(不能含package) ` 进行块操作。 根据你的业务写代码，就可以调用接口了。想怎么调用就怎么调用。

#### A-012 Shell并发N执行 - [.bash_multi](.bash_multi) 有很多其他的工具可以控制并发N的执行：xargs, mco puppet, pssh

举个例子：

```
source .bash_multi
WORK_MULTI_THREADS=1
threadpool_start; // 初始化N线程

for line in `cat $WORK_LIST` ;  do
  function handle(){ change it }
  function doit(){ 
    handle "$@" ;  
    threadpool_release ; // 释放
  }
  
  threadpool_require; // 获取一个线程
  
  if [ $WORK_MULTI_THREADS -le 1 ] ; then 
    doit $line
  else 
    doit $line & 
  fi
done

threadpool_destory; // 结束，清理
```

#### B-002 定时（结合crontab）根据情况修改分析数据库配置表 - [dynamic_access_conf.sh](dynamic_access_conf.sh)
#### D-001 :yum: 本地Cygwin命令打开当前路径 - [cygexplorer](cygexplorer)
#### D-002 快速打开Eclipse中选中的文件（夹）所在目录 - [explorer.launch](explorer.launch)
#### A-013 windows本地跑Zookeeper - [win-zkServers.bat](win-zkServers.bat)
#### A-014 :yum: shell实现数组乱序

```
cat ABC | shuf
cat ABC | sort -R
```

#### D-003 RMI远程调试

1. 首先用SecureCRT连接到生产环境做个Socks5代理（RMI单纯本地端口转发是不行的）。
2. 本地Java配置代理：`-DsocksProxyHost=127.0.0.1 -DsocksProxyPort=5555`, 然后本地代码RMI的地址指定为生产对应服务的地址。

#### A-015 内容实现 A - B

首先把A、B的内容保存到两个文件，然后使用diff来处理：

```
diff -u A B | grep '^-' | grep '\\lib' | sed 's/^-/-libraryjars /' 
```

做项目jar混淆处理时，injars和libraryjars不能重。挺方便的一种方式，尽管不是很严谨，初步筛选出来，再执行报错一个个的处理就好了。

#### A-016 :yum: 使用SSH Multiplexing加速SSH

启用SSH Multiplexing：

```
$ vi .ssh/config
Host *
    ControlMaster auto
    ControlPath /tmp/%r@%h:%p
    ControlPersist 10m

```

效果：

```
[hadoop@hadoop-master1 ~]$ time ssh hadoop-master2 hostname
hadoop-master2

real    0m0.176s
user    0m0.022s
sys     0m0.005s
[hadoop@hadoop-master1 ~]$ time ssh hadoop-master2 hostname
hadoop-master2

real    0m0.030s
user    0m0.002s
sys     0m0.004s
[hadoop@hadoop-master1 ~]$ ssh -O check hadoop-master2
Master running (pid=26923)
[hadoop@hadoop-master1 ~]$ ps 26923
  PID TTY      STAT   TIME COMMAND
26923 ?        SNs    0:00 ssh: /tmp/hadoop@hadoop-master2:22 [mux]
[hadoop@hadoop-master1 ~]$ ssh -O exit hadoop-master2
```

#### A-017 Shell数值运算
#### A-018 Test常见用法
#### A-019 优化git-log输出

```
$ git log --pretty='format:%h %ar%x09%s' -4
357ce9d 2 weeks ago     format code
d58845d 2 weeks ago     fix wrong email
5ba6be9 2 weeks ago     instance alert config dao
db3ad71 2 weeks ago     fix wrong log
```

#### D-004 Maven脚手架生成加速

mvn archetype:generate命令时，加上-DarchetypeCatalog=local

#### A-020 下载远程服务器上的GIT项目

```
# 设置SOCKS5代理
$ cat ~/.ssh/config
Host hadoop-*
  User hadoop
  ProxyCommand nc -v -x 127.0.0.1:5555 %h %p

# 无密钥登录
$ chmod 600 ~/.ssh/config
$ ssh-copy-id hadoop@hadoop-slaver388

# CLONE
$ git clone hadoop@hadoop-slaver388:~/playbook
```

#### A-021 tomcat远程调试

修改startup.sh的最后一行(JDPA的环境变量用默认的也行)启动，然后本地启动eclipse/idea启动远程调试连接对应的服务器端口就行了：

```
set JPDA_TRANSPORT=dt_socket
set JPDA_ADDRESS=8000
set JPDA_SUSPEND=y

call "%EXECUTABLE%" jpda start %CMD_LINE_ARGS%
```

#### A-022 SSH端口转发

```
ssh -L
ssh -D
ssh -R

supervisor + autossh
```

#### A-023 格式化/处理JSON

```
curl xxxx|python -m json.tool

curl xxxx|jq .
```

#### A-024 大文件拆分

```
split -b 512m nexus-0906.tar.gz nexus-0906-split 
```

#### A-025 Less跳到第N行

If the file is open you can type:

	* 100g to go to the 100th line.
	* 50p to go to 50% into the file.
	* 100P to go to the line containing 100th byte.

You can use these from terminal by adding + in front of them: less +100g bigfile.txt

you can type $ to go to the last line

#### D-005 抓取数据的一些片段

* https://github.com/winse/spark-best-practice/blob/master/sparksql/crawler.js
* https://github.com/winse/exportblog-node/blob/master/blog.js

#### D-0006 scala启动程序

* https://github.com/winse/spark-examples/blob/master/src/main/scala/com/github/winse/spark/HelloMetrics.scala

#### A-026 Windows-Ubuntu explorer

```
#!/bin/sh

WHERE=$( readlink -f $PWD | sed -e 's#/mnt/\([a-zA-Z0-9]*\)#\1:#' -e 's#/#\\#g' )

explorer.exe "$WHERE"

```

then on the shell windows, execute command explorer.

```
winse@DESKTOP-ADH7K1Q:~/git/pinpoint$ explorer
```

#### A-027 虚拟机磁盘整理

设置 - 硬盘 - (右边的选项)磁盘整理|压缩



