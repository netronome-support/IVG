#!/bin/bash

# Synchronize package index files
#yum -y update --exclude=kernel*
yum clean all

# Install and enable Multicast DNS
yum -y install epel-release
yum -y install nss-mdns
yum -y install numactl-devel
systemctl enable avahi-daemon
systemctl start avahi-daemon

# Install required packages
# CentOS 7.3 - 3.10.0-514.26.1
#yum -y install ftp://fr2.rpmfind.net/linux/centos/7.3.1611/updates/x86_64/Packages/kernel-devel-3.10.0-514.26.1.el7.x86_64.rpm
# CentOS 7.4

pkglist=()
pkglist+=( "kernel-devel-$(uname -r)" )
pkglist+=( make gcc gcc-c++ libxml2 glibc )
pkglist+=( libpcap-devel wget pciutils )
pkglist+=( python python-pip )
pkglist+=( numpy )
pkglist+=( git )

yum -y install ${pkglist[@]} \
    || exit -1

pip install numpy
pip install plotly

# Disable SElinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

exit 0
