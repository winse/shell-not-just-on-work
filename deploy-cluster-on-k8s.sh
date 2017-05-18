#!/bin/sh

if [[ $# > 1 ]] ; then
  OP=$1
  if [ "$OP" == "delete" ] ; then
    shift
    kubectl delete namespace "$@"
    exit $?
  fi
fi

K8S_CONFIG_DIR=$(pwd)/kubenetes
K8S_NAMESPACE_PATH=$K8S_CONFIG_DIR/ns.yaml
NAMESPACE=${1:-"test"}
HOSTS=
HOSTS_NAME=
MASTER_NAME="hadoop-master2.$NAMESPACE"
LEVEL=${LEVEL:-999}

## K8S

function createContainers() {
  cat > $K8S_NAMESPACE_PATH <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: $NAMESPACE
EOF
  
  kubectl apply -f $K8S_NAMESPACE_PATH
  kubectl apply -f $K8S_CONFIG_DIR/simple-hadoop.yaml -n $NAMESPACE
    
  rm -rf $K8S_NAMESPACE_PATH
}

function getContainersHost() {
  local answer1=""
  while [ ! "$answer1" = "yes" ] ; do 
    kubectl get pods -o wide -n $NAMESPACE
    sleep 1
    echo -n "Continue(yes/other): " ; read answer1
  done
  
  HOSTS="$( kubectl get pods -o wide --all-namespaces --show-labels=true | grep "cluster=dta" | grep "^$NAMESPACE" | awk '{print $7" "$2" "$2"."$1}' )"
  HOSTS_NAME="$( echo "$HOSTS" | awk '{print $NF}' )"
}


## modify hosted hosts

function adjustHostedHosts() {

  if [ ! "$NAMESPACE" = "test" ] ; then
  HOSTED_HOSTS="$( echo "$HOSTS" | awk '{print $1" "$3}' )"
  else
  HOSTED_HOSTS="$HOSTS"
  fi

  sed -i "/# $NAMESPACE HADOOP/,/# @$NAMESPACE HADOOP/d" /etc/hosts
  cat >>/etc/hosts <<EOF
# $NAMESPACE HADOOP
$HOSTED_HOSTS
# @$NAMESPACE HADOOP
EOF

  echo "Updated local /etc/hosts"
}

## Cluster Applications and Config

function hostedKeyLessLogin() {
for h in $HOSTS_NAME ; do 
  ./ssh-copy-id.expect hadoop@$h 'hadoop'
  ./ssh-copy-id.expect root@$h 'root'
done
}

function rsyncApplications() {
for h in $HOSTS_NAME ; do 
  rsync -rltz --exclude='*.log' \
    /data/dev/build/java/hadoop-2.6.5-src/hadoop-dist/target/hadoop-2.6.5 \
    /data/kubernetes/kube-deploy/hadoop/build/hbase-1.3.1 \
    /data/kubernetes/kube-deploy/hadoop/build/zookeeper-3.4.6 \
    hadoop@${h}:/opt/
done
}

function updateConfig() {
for h in $HOSTS_NAME ; do 

  ssh root@${h} "
echo '
127.0.0.1       localhost
$HOSTS
' > /etc/hosts
"
  
  # 环境变量
  echo '
export JAVA_HOME=/opt/jdk1.8.0_121
export HADOOP_HOME=/opt/hadoop-2.6.5

export PATH=$HADOOP_HOME/bin:$JAVA_HOME/bin:$PATH 
' | ssh root@${h}  ' cat > /etc/profile.d/hadoop.sh '

  # 配置同步到集群的机器
  rsync -rltz /data/kubernetes/kube-deploy/hadoop/config/hadoop/ hadoop@${h}:/opt/hadoop-2.6.5/etc/hadoop/
  rsync -rltz /data/kubernetes/kube-deploy/hadoop/config/hbase/ hadoop@${h}:/opt/hbase-1.3.1/conf/

  ssh hadoop@${h} "
echo '$(cat /data/kubernetes/kube-deploy/hadoop/config/hadoop.cfg)' >>/opt/hadoop-2.6.5/etc/hadoop/hadoop-env.sh
echo '$(cat /data/kubernetes/kube-deploy/hadoop/config/hadoop.cfg)' >>/opt/hbase-1.3.1/conf/hbase-env.sh

echo '$HOSTS_NAME' | grep slaver > /opt/hadoop-2.6.5/etc/hadoop/slaves
echo '$HOSTS_NAME' | grep slaver > /opt/hbase-1.3.1/conf/regionservers

mkdir -p /data/bigdata/hadoop
chmod 700 /data/bigdata /data/bigdata/hadoop
"

done
}

function rsyncMasterApplications() {
  rsync -rltz --exclude='*.log' /data/bigdata/redis /data/bigdata/apache-hive-1.2.1-bin ssh-copy-id.expect hadoop@${MASTER_NAME}:/opt/
}

function masterKeyLessLogin() {
  ssh root@${MASTER_NAME} ' ! which expect && yum install -y expect '
  ssh hadoop@${MASTER_NAME} '
[ ! -f ~/.ssh/id_rsa ] && ssh-keygen -P "" -t rsa -f ~/.ssh/id_rsa 
mkdir -p /data/bigdata/zookeeper /data/redis 
for h in ` grep hadoop /etc/hosts | awk "{print \$2}" ` ; do 
  /opt/ssh-copy-id.expect $h hadoop
done
'
}


(( $LEVEL <= 0 )) && createContainers
getContainersHost
adjustHostedHosts
(( $LEVEL <= 1 )) && hostedKeyLessLogin
(( $LEVEL <= 10 )) && rsyncApplications
(( $LEVEL <= 20 )) && updateConfig
(( $LEVEL <= 10 )) && rsyncMasterApplications
(( $LEVEL <= 15 )) && masterKeyLessLogin

