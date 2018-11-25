#!/usr/bin/env bash

# adjust interfce if not named eth0
[ -d /etc/nomad.d/ ] && {
  IFACE=`route -n | awk '$1 ~ "0.0.0.0" {print $8}'`
  sed -i "s/eth0/${IFACE}/g" /etc/nomad.d/*.hcl
}

systemctl enable nomad.service
systemctl start nomad.service
