#!/usr/bin/env bash

# kernel parameters
cp /vagrant/conf/security_limits.conf /etc/security/limits.d/lxd.conf
cp /vagrant/conf/sysctl.conf /etc/sysctl.conf
sysctl -p

echo reboot before proceeding
