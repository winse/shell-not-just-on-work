#!/bin/sh

# must be hostname!!
HOSTS="$@"
PASSWD=${PASSWD:-'root'}
PUPPETSERVER=${PUPPETSERVER:-"hadoop-master1"}

for h in $HOSTS ; do ./ssh-copy-id.expect $h "$PASSWD" ; done

for h in $HOSTS ; do
scp /etc/hosts $h:/etc ;
scp /etc/yum.repos.d/puppet.repo $h:/etc/yum.repos.d/ ;
scp /etc/cron.daily/ntp.cron $h:/etc/cron.daily/ ;

ssh $h '
#ntpdate cu-omc1 #着重注意
rm -rf /etc/yum.repos.d/CentOS-*
yum install mcollective-plugins-simple -y
' ;

scp /etc/puppetlabs/mcollective/server.cfg $h:/etc/puppetlabs/mcollective/
ssh $h "
sed -i '/HOSTNAME/ {
i \
HOSTNAME=$h
d
} ' /etc/sysconfig/network
hostname $h

echo -e '\n\n[agent]\nserver = $PUPPETSERVER\ncertname=$h' > /etc/puppetlabs/puppet/puppet.conf
chkconfig mcollective on
service mcollective start
"

done
