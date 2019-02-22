#!/usr/bin/env bash

## BEGIN of customization

# versions
CONSUL=1.4.2
CONSUL_TEMPLATE=0.20.0
NOMAD=0.8.7
VAULT=1.0.3

## END of customization

# if we are in a vagrant box, lets cd into /vagrant
[ -d /vagrant ] && pushd /vagrant

# arch
if [[ "`uname -m`" =~ "arm" ]]; then
  ARCH=arm
else
  ARCH=amd64
fi

# install and configure lxd
which lxd &>/dev/null || {
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -t xenial-backports -y lxd
  lxd init --preseed < conf/lxd_init.yml
}

# create base container
s=base
lxc info ${s} &>/dev/null || {
  lxc launch ubuntu:16.04 ${s} -c security.nesting=true
  echo sleeping so ${s} can boot properly
  sleep 8
  mkdir -p /var/lib/lxd/containers/${s}/rootfs/etc/dpkg/dpkg.cfg.d/
  cp conf/01_nodoc /var/lib/lxd/containers/${s}/rootfs/etc/dpkg/dpkg.cfg.d/01_nodoc
  lxc exec ${s} -- apt-get update
  lxc exec --env DEBIAN_FRONTEND=noninteractive ${s} -- apt-get install --no-install-recommends -y wget unzip dnsmasq
  lxc exec ${s} -- apt-get clean

  # dnsmasq to use consul dns
  cp conf/dnsmasq.d/consul /var/lib/lxd/containers/${s}/rootfs/etc/dnsmasq.d/10-consul

  # /tmp cleans on each boot
  lxc exec ${s} -- wget -O /tmp/consul.zip https://releases.hashicorp.com/consul/${CONSUL}/consul_${CONSUL}_linux_${ARCH}.zip
  lxc exec ${s} -- unzip -d /usr/local/bin /tmp/consul.zip

  lxc exec ${s} -- wget -O /tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT}/vault_${VAULT}_linux_${ARCH}.zip
  lxc exec ${s} -- unzip -d /usr/local/bin /tmp/vault.zip

  lxc exec ${s} -- wget -O /tmp/nomad.zip https://releases.hashicorp.com/nomad/${NOMAD}/nomad_${NOMAD}_linux_${ARCH}.zip
  lxc exec ${s} -- unzip -d /usr/local/bin /tmp/nomad.zip

  lxc stop ${s}
  lxc config set ${s} security.privileged true
}

# copy scripts to all existing nodes
for d in /var/lib/lxd/containers/*/rootfs/var/tmp; do
  cp scripts/consul.sh ${d}
  cp scripts/nomad.sh ${d}
  cp scripts/vault.sh ${d}
done

# base-client
s=base-client
lxc info ${s} &>/dev/null || {
  echo "copying base into ${s}"
  lxc copy base ${s}
  lxc start ${s}
  echo sleeping so ${s} can boot properly
  sleep 8
  lxc exec ${s} -- apt-get update
  lxc exec --env DEBIAN_FRONTEND=noninteractive ${s} -- apt-get install --no-install-recommends -y docker.io
  lxc exec --env DEBIAN_FRONTEND=noninteractive ${s} -- apt-get install --no-install-recommends -y default-jre
  lxc exec ${s} -- apt-get clean
  lxc exec ${s} -- docker run hello-world &>/dev/null && echo docker hello-world works
  lxc stop base-client
} & #background

# ip range
declare -A IP
IP[consul1-dc1]=10.170.13.11
IP[consul2-dc1]=10.170.13.12
IP[consul3-dc1]=10.170.13.13
IP[vault1-dc1]=10.170.13.21
IP[nomad1-dc1]=10.170.13.31
IP[nomad2-dc1]=10.170.13.32
IP[nomad3-dc1]=10.170.13.33
IP[client1-dc1]=10.170.13.41
IP[client2-dc1]=10.170.13.42
IP[client3-dc1]=10.170.13.43
IP[client4-dc1]=10.170.13.44
IP[client5-dc1]=10.170.13.45
IP[consul1-dc2]=10.170.14.11
IP[consul2-dc2]=10.170.14.12
IP[consul3-dc2]=10.170.14.13
IP[nomad1-dc2]=10.170.14.31
IP[nomad2-dc2]=10.170.14.32
IP[nomad3-dc2]=10.170.14.33
IP[client1-dc2]=10.170.14.41
IP[client2-dc2]=10.170.14.42
IP[client3-dc2]=10.170.14.43
IP[client4-dc2]=10.170.14.44
IP[client5-dc2]=10.170.14.45

# create consul
# dc1 and dc2
for dc in dc{1..2}; do
  # for nodes in each dc
  for s in consul{1..3}-${dc}; do
    lxc info ${s} &>/dev/null || {
      echo "copying base into ${s}"
      lxc copy base ${s}
      lxc network attach lxdbr0 ${s} eth0 eth0
      lxc config device set ${s} eth0 ipv4.address ${IP[${s}]}
      lxc start ${s}
      echo sleeping so ${s} can boot properly
      sleep 4

      # create dir and copy server.hcl for consul
      mkdir -p /var/lib/lxd/containers/${s}/rootfs/etc/consul.d
      cp conf/consul.d/server-${dc}.hcl /var/lib/lxd/containers/${s}/rootfs/etc/consul.d/server.hcl
      cp conf/consul.service /var/lib/lxd/containers/${s}/rootfs/etc/systemd/system
      lxc exec ${s} -- bash /var/tmp/consul.sh
    } & # background
  done # end nodes
done # end dc

consul_client(){
  # create dir and copy client.hcl for consul
  mkdir -p /var/lib/lxd/containers/${s}/rootfs/etc/consul.d
  cp conf/consul.d/client-${dc}.hcl /var/lib/lxd/containers/${s}/rootfs/etc/consul.d/client.hcl
  cp conf/consul.service /var/lib/lxd/containers/${s}/rootfs/etc/systemd/system
  lxc exec ${s} -- bash /var/tmp/consul.sh
}

# create vault1 - in dev mode, just one
s=vault1-dc1
lxc info ${s} &>/dev/null || {
  echo "copying base into ${s}"
  lxc copy base ${s}
  lxc network attach lxdbr0 ${s} eth0 eth0
  lxc config device set ${s} eth0 ipv4.address ${IP[${s}]}
  lxc start ${s}
  echo sleeping so ${s} can boot properly
  sleep 4

  dc=dc1       # vault OSS doesn't do replication, so just 1 dc
  consul_client
  unset dc

  # create dir and copy server.hcl for vault
  mkdir -p /var/lib/lxd/containers/${s}/rootfs/etc/vault.d
  cp conf/vault.d/server.hcl /var/lib/lxd/containers/${s}/rootfs/etc/vault.d
  cp conf/vault.service /var/lib/lxd/containers/${s}/rootfs/etc/systemd/system
  lxc exec ${s} -- bash /var/tmp/vault.sh
} & # background

# create nomad
# dc1 and dc2
for dc in dc{1..2}; do
  # for nodes in each dc
  for s in nomad{1..3}-${dc}; do
    lxc info ${s} &>/dev/null || {
      echo "copying base into ${s}"
      lxc copy base ${s}
      lxc network attach lxdbr0 ${s} eth0 eth0
      lxc config device set ${s} eth0 ipv4.address ${IP[${s}]}
      lxc start ${s}
      echo sleeping so ${s} can boot properly
      sleep 4

      consul_client

      # create dir and copy server.hcl for nomad
      mkdir -p /var/lib/lxd/containers/${s}/rootfs/etc/nomad.d
      cp conf/nomad.d/server-${dc}.hcl /var/lib/lxd/containers/${s}/rootfs/etc/nomad.d/server.hcl
      cp conf/nomad.service /var/lib/lxd/containers/${s}/rootfs/etc/systemd/system

      lxc exec ${s} -- bash /var/tmp/nomad.sh
    } & # background
  done
done

# install packages needed on the host
which haproxy nginx unzip wget &>/dev/null || {
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install --no-install-recommends -y haproxy nginx unzip wget
}

# configure nginx to expose services
[ -f /etc/nginx/sites-enabled/default ] && rm /etc/nginx/sites-enabled/default
service nginx restart

# configure haproxy to expose ui
cp conf/haproxy.cfg /etc/haproxy/haproxy.cfg
service haproxy restart

[ -f /usr/local/bin/consul-template ] || {
  wget -O /tmp/consul-template.zip https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE}/consul-template_${CONSUL_TEMPLATE}_linux_${ARCH}.zip
  unzip -d /usr/local/bin /tmp/consul-template.zip
}

cp -ap conf/consul-template /etc/
cp conf/consul-template.service /etc/systemd/system/consul-template.service
systemctl enable consul-template.service
systemctl restart consul-template.service

wait  # wait for background processes to finish

# clients
# dc1 and dc2
for dc in dc{1..2}; do
  # for nodes in each dc
  for s in client{1..2}-${dc}; do
    lxc info ${s} &>/dev/null || {
      echo "copying base-client into ${s}"
      lxc copy base-client ${s}
      lxc network attach lxdbr0 ${s} eth0 eth0
      lxc config device set ${s} eth0 ipv4.address ${IP[${s}]}
      lxc start ${s}
      echo sleeping so ${s} can boot properly
      sleep 4

      consul_client
       
      # create dir and copy client.hcl for nomad
      mkdir -p /var/lib/lxd/containers/${s}/rootfs/etc/nomad.d
      cp conf/nomad.d/client-${dc}.hcl /var/lib/lxd/containers/${s}/rootfs/etc/nomad.d/client.hcl
      cp conf/nomad.service /var/lib/lxd/containers/${s}/rootfs/etc/systemd/system

      lxc exec ${s} -- bash /var/tmp/nomad.sh
    } & # background
  done
done
wait  # wait for background processes to finish
