#!/usr/bin/env bash

for x in base base-client client{1..3} consul{1..3} nomad{1..3} vault1 ; do
  lxc delete ${x} --force
done

service lxd-bridge stop
service lxd stop
umount /var/lib/lxd/shmounts
umount /var/lib/lxd/devlxd
rm -fr /var/lib/lxd/containers
mountpoint /var/lib/lxd && umount /var/lib/lxd

apt-get remove -y '*lxd*' '*lxc*'
apt autoremove -y
