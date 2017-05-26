#!/bin/sh

bin=`dirname "${BASH_SOURCE-$0}"`
bin=`cd "$bin"; pwd`

HADOOP_HOME=~/hadoop

function hdfs() {
  $HADOOP_HOME/bin/hdfs dfs "$@"
}

function mysql() {
  $bin/mysql -hHOST -uUSER -pPASSWD -DDB -PPORT -r -s -N "$@" 
}

hdfs_num=` hdfs -ls /user/hadoop/dta/t_ods_access_log/ | wc -l `
conf_num=` mysql -e "select map_num from t_analyse_task_conf where task_name = 'AccessLogOnlyHiveJob' " `

remain_num=$(( $hdfs_num - $conf_num ))

if (( $remain_num > conf_num )) ; then
  change=true
else 
  percent=` $HADOOP_HOME/bin/yarn application -list -appStates RUNNING | grep AccessLogOnlyHiveJob | awk '{printf("%d\n", $8)}' `
  [[ $percent > 80 ]] && change=true
fi 

if $change ; then
  if (( $remain_num < XXX )) ; then
    map_num=XXX;
    reduce_num=XXX;
  elif (( $remain_num < XXX )) ; then
    map_num=XXX;
    reduce_num=XXX;
  else 
    map_num=XXX;
    reduce_num=XXX;
  fi

  if (( $map_num != $conf_num )) ; then
    mysql -e "update t_analyse_task_conf set map_num=$map_num , reduce_num=$reduce_num where task_name = 'AccessLogOnlyHiveJob' "
  fi 
fi

date
