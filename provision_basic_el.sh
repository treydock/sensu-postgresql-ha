#!/bin/bash

setenforce 0
sed -r -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

# using this instead of "rpm -Uvh" to resolve dependencies
function rpm_install() {
    package=$(echo $1 | awk -F "/" '{print $NF}')
    wget --quiet $1
    yum install -y ./$package
    rm -f $package
}

release=$(awk -F \: '{print $5}' /etc/system-release-cpe)

rpm --import http://download-ib01.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-${release}
rpm --import http://yum.puppetlabs.com/RPM-GPG-KEY-puppet
rpm --import http://vault.centos.org/RPM-GPG-KEY-CentOS-${release}

yum install -y wget

# install and configure puppet
rpm -qa | grep -q puppet
if [ $? -ne 0 ]
then
    rpm_install http://yum.puppetlabs.com/puppet5-release-el-${release}.noarch.rpm
    yum -y install puppet-agent
    ln -s /opt/puppetlabs/puppet/bin/puppet /usr/bin/puppet
fi

if [ -d /etc/puppetlabs/code/environments/production ]; then
  rm -rf /etc/puppetlabs/code/environments/production
fi
puppet resource file /etc/puppetlabs/code/environments/production ensure=link target=/vagrant/production force=true

puppet resource host psql1.example.com ensure=present ip=10.0.0.101 host_aliases=psql1
puppet resource host psql2.example.com ensure=present ip=10.0.0.102 host_aliases=psql2
puppet resource host psql3.example.com ensure=present ip=10.0.0.103 host_aliases=psql3
puppet resource host haproxy.example.com ensure=present ip=10.0.0.104 host_aliases=haproxy
puppet resource host sensu-backend.example.com ensure=present ip=10.0.0.105 host_aliases=sensu-backend

