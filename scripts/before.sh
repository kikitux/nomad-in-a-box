#!/usr/bin/env bash

[ -d /vagrant/ ] && cd /vagrant
# kernel parameters
cp conf/security_limits.conf /etc/security/limits.d/lxd.conf
cp conf/sysctl.conf /etc/sysctl.conf
sysctl -p

echo reboot before proceeding
