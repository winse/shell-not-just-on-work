#!/bin/sh

if [ ! $# -eq 2 ] ; then
  echo "USAGE: $0 table output"
  echo "       $0 t_dta_activeresources_domain20170503 20170503"
  exit 1
fi

TABLE=$1
OUTPUT=$2

# xlsx2csv isp.xlsx --all | grep '^,' | awk -F','  '{print $2" "$5" "$6}' > ip-filter.csv

export JAVA_HOME=/usr/local/jdk1.8.0_92/
export PATH=$JAVA_HOME/bin:$PATH

OPTIONS+=" --master local[10]"
OPTIONS+=" --driver-class-path /home/hadoop/hive/lib/mysql-connector-java-5.1.21-bin.jar,/home/hadoop/hive/lib/postgresql-9.1-901-1.jdbc4.jar"
OPTIONS+=" --jars  /home/hadoop/hive/lib/mysql-connector-java-5.1.21-bin.jar,/home/hadoop/hive/lib/postgresql-9.1-901-1.jdbc4.jar"

~/spark-2.0.0-bin-2.6.3/bin/spark-shell $OPTIONS <<EOF

val table="$TABLE"
val dbuser="XXX"
val dbpasswd="XXX"
val output="$OUTPUT"

def ipToLong(ipAddress: String): Long = {
ipAddress.split("\\\\.").reverse.zipWithIndex.map(a=>a._1.toInt*math.pow(256,a._2).toLong).sum
}
def longToIP(long: Long): String = {
(0 until 4).map(a=>long / math.pow(256, a).floor.toInt % 256).reverse.mkString(".")
}
spark.udf.register("INET_NTOA", longToIP _)
spark.udf.register("INET_ATON", ipToLong _)

spark.read.csv("ip-filter.csv").
    map(f => (f(0).toString, ipToLong(f(1).toString), ipToLong(f(2).toString))).
    toDF("user","startIp","endIp").
    createOrReplaceTempView("filter")

spark.read.format("jdbc").
    option("driver", "org.postgresql.Driver").
    option("url", "jdbc:postgresql://hadoop-master1/dpi").
    option("dbtable", table).
    option("user",dbuser).
    option("password",dbpasswd).
    load().
    createOrReplaceTempView("data")

spark.sql("""
select * from (
    select ip, domain, topdomain, sum(cast(visitscount as bigint)) visitscount
    from data
    where topdomain != ''
    group by ip, domain, topdomain
) t
order by visitscount desc
""").
    map(f=>(ipToLong(f(0).toString),f(1).toString,f(2).toString,f(3).toString)).
    toDF("ip","domain","topdomain","count").
    createOrReplaceTempView("v_data")

spark.read.format("jdbc").
    option("driver", "com.mysql.jdbc.Driver").
    option("url", "jdbc:mysql://192.168.31.201/dpi").
    option("dbtable", "t_ipseg_info").
    option("user",dbuser).
    option("password",dbpasswd).
    load().
    createOrReplaceTempView("user")

spark.sql("""
select t.usr,INET_ATON(t.startip) startip,INET_ATON(t.endip) endip
from user t
where t.type=0
""").
    createOrReplaceTempView("v_user")

spark.sql("""
select d.ip, d.topdomain, sum(d.count) count
from v_data d
where not exists ( select 1 from filter f where d.ip between f.startIp and f.endIp )
group by d.ip,d.topdomain
""").
    createOrReplaceTempView("v_domain")

spark.conf.set("spark.sql.crossJoin.enabled", true)

spark.sql("""
select inet_ntoa(d.ip) ip, d.topdomain, cast(d.count as string) count, u.usr
from v_domain d left join v_user u on d.ip between u.startip and u.endip
order by d.count desc
""").
    repartition(1).
    write.format("csv").
    option("header", true).
    save(output)

EOF
