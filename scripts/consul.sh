#!/usr/bin/env bash

# adjust interfce if not named eth0
[ -f /etc/consul.d/client.hcl ] && {
  IFACE=`route -n | awk '$1 ~ "0.0.0.0" {print $8}'`
  sed -i "s/eth0/${IFACE}/g" /etc/consul.d/client.hcl
}

systemctl enable consul.service
systemctl start consul.service
