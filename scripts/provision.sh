#!/usr/bin/env bash

# versions
CONSUL=1.4.0
VAULT=0.11.5
NOMAD=0.8.6
HTTPECHO=0.2.3

# if we are in a vagrant box, lets cd into /vagrant
[ -d /vagrant ] && pushd /vagrant

# check lxd, if not present
# install and configure lxd
which lxd &>/dev/null || {
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  cat conf/selection.conf | debconf-set-selections
  apt-get install --no-install-recommends -y vim lxd
  DEBCONF_DB_OVERRIDE='File {conf/config.dat}' dpkg-reconfigure -fnoninteractive -pmedium lxd
  cp conf/lxd-bridge /etc/default/lxd-bridge
  cp conf/dns.conf /etc/default/dns.conf
  service lxd restart
  service lxd-bridge restart
}

# vars for join
consul="10.170.13.11 10.170.13.12 10.170.13.13"
vault="10.170.13.21"
nomad="10.170.13.31 10.170.13.32 10.170.13.33"

# create base container
lxc info base &>/dev/null || {
  lxc launch ubuntu:16.04 base -c security.nesting=true
  echo sleeping so base get an IP
  sleep 10
  lxc list
    # create dir and copy server.hcl for consul
  mkdir -p /var/lib/lxd/containers/base/rootfs/etc/dpkg/dpkg.cfg.d/
  cp conf/01_nodoc /var/lib/lxd/containers/base/rootfs/etc/dpkg/dpkg.cfg.d/01_nodoc
  lxc exec base -- apt-get update
  lxc exec base -- apt-get install --no-install-recommends -y wget unzip 
  lxc exec base -- apt-get clean

  # /tmp cleans on each boot
  lxc exec base -- wget -O /tmp/consul.zip https://releases.hashicorp.com/consul/${CONSUL}/consul_${CONSUL}_linux_amd64.zip
  lxc exec base -- unzip -d /usr/local/bin /tmp/consul.zip

  lxc exec base -- wget -O /tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT}/vault_${VAULT}_linux_amd64.zip
  lxc exec base -- unzip -d /usr/local/bin /tmp/vault.zip

  lxc exec base -- wget -O /tmp/nomad.zip https://releases.hashicorp.com/nomad/${NOMAD}/nomad_${NOMAD}_linux_amd64.zip
  lxc exec base -- unzip -d /usr/local/bin /tmp/nomad.zip

  lxc exec base -- wget -O /tmp/http-echo.zip https://github.com/hashicorp/http-echo/releases/download/v${HTTPECHO}/http-echo_${HTTPECHO}_linux_amd64.zip
  lxc exec base -- unzip -d /usr/local/bin /tmp/http-echo.zip

  lxc stop base
  lxc config set base security.privileged true
}

# copy scripts to all existing nodes
for d in /var/lib/lxd/containers/*/rootfs/var/tmp; do
  cp scripts/consul.sh ${d}
  cp scripts/vault.sh ${d}
  cp scripts/nomad.sh ${d}
done

# create consul
for s in consul{1..3}; do
  lxc info ${s} &>/dev/null || {
    echo "copying base into ${s}"
    lxc copy base ${s}
    lxc start ${s}
    echo sleeping so ${s} get an IP
    sleep 8

    # create dir and copy server.hcl for consul
    mkdir -p /var/lib/lxd/containers/${s}/rootfs/etc/consul.d
    cp conf/consul.d/server.hcl /var/lib/lxd/containers/${s}/rootfs/etc/consul.d
    cp conf/consul.service /var/lib/lxd/containers/${s}/rootfs/etc/systemd/system
    lxc exec ${s} -- bash /var/tmp/consul.sh
  }

done

# create vault1 - in dev mode, just one
s=vault1
lxc info ${s} &>/dev/null || {
  echo "copying base into ${s}"
  lxc copy base ${s}
  lxc start ${s}
  echo sleeping so ${s} get an IP
  sleep 8

  # create dir and copy client.hcl for consul
  mkdir -p /var/lib/lxd/containers/${s}/rootfs/etc/consul.d
  cp conf/consul.d/client.hcl /var/lib/lxd/containers/${s}/rootfs/etc/consul.d
  cp conf/consul.service /var/lib/lxd/containers/${s}/rootfs/etc/systemd/system
  lxc exec ${s} -- bash /var/tmp/consul.sh

  # create dir and copy server.hcl for vault
  mkdir -p /var/lib/lxd/containers/${s}/rootfs/etc/vault.d
  cp conf/vault.d/server.hcl /var/lib/lxd/containers/${s}/rootfs/etc/vault.d
  cp conf/vault.service /var/lib/lxd/containers/${s}/rootfs/etc/systemd/system
  lxc exec ${s} -- bash /var/tmp/vault.sh
}

# consul1 to join consul2 and consul3
echo consul consul1 to join other servers
lxc exec consul1 -- consul join ${consul}

#vault is a consul client, join servers
echo ${s} joining consul servers
lxc exec ${s} -- consul join ${consul}

# create nomad
for s in nomad{1..3}; do
  lxc info ${s} &>/dev/null || {
    echo "copying base into ${s}"
    lxc copy base ${s}
    lxc start ${s}
    echo sleeping so ${s} get an IP
    sleep 8

    # create dir and copy client.hcl for consul
    mkdir -p /var/lib/lxd/containers/${s}/rootfs/etc/consul.d
    cp conf/consul.d/client.hcl /var/lib/lxd/containers/${s}/rootfs/etc/consul.d
    cp conf/consul.service /var/lib/lxd/containers/${s}/rootfs/etc/systemd/system

    # create dir and copy server.hcl for nomad
    mkdir -p /var/lib/lxd/containers/${s}/rootfs/etc/nomad.d
    cp conf/nomad.d/server.hcl /var/lib/lxd/containers/${s}/rootfs/etc/nomad.d
    cp conf/nomad.service /var/lib/lxd/containers/${s}/rootfs/etc/systemd/system

    lxc exec ${s} -- bash /var/tmp/consul.sh
    lxc exec ${s} -- bash /var/tmp/nomad.sh
  }

  #nomad is a consul client, join servers
  echo ${s} joining consul servers
  lxc exec ${s} -- consul join ${consul}
done

# nomad1 to join nomad2 and nomad3
echo nomad nomad1 to join other servers
lxc exec nomad1 -- nomad server join ${nomad}

# clients
for s in client{1..3}; do
  lxc info ${s} &>/dev/null || {
    echo "copying base into ${s}"
    lxc copy base ${s}
    lxc start ${s}
    echo sleeping so ${s} get an IP
    sleep 8
    lxc list ${s}
    lxc exec ${s} -- apt-get update
    lxc exec ${s} -- apt-get install --no-install-recommends -y docker.io
    lxc exec ${s} -- apt-get install --no-install-recommends -y default-jre
    lxc exec ${s} -- apt-get clean
    lxc exec ${s} -- docker run hello-world &>/dev/null && echo docker hell-world works

    # create dir and copy client.hcl for consul
    mkdir -p /var/lib/lxd/containers/${s}/rootfs/etc/consul.d
    cp conf/consul.d/client.hcl /var/lib/lxd/containers/${s}/rootfs/etc/consul.d
    cp conf/consul.service /var/lib/lxd/containers/${s}/rootfs/etc/systemd/system
       
    # create dir and copy client.hcl for nomad
    mkdir -p /var/lib/lxd/containers/${s}/rootfs/etc/nomad.d
    cp conf/nomad.d/client.hcl /var/lib/lxd/containers/${s}/rootfs/etc/nomad.d
    cp conf/nomad.service /var/lib/lxd/containers/${s}/rootfs/etc/systemd/system

    lxc exec ${s} -- bash /var/tmp/consul.sh
    lxc exec ${s} -- bash /var/tmp/nomad.sh
    echo sleeping so nomad starts, and scan the drivers
    sleep 5
  }
  
  #clients join servers
  echo ${s} joining consul servers
  lxc exec ${s} -- consul join ${consul}

  #clients join servers
  echo ${s} joining nomad servers
  lxc exec ${s} -- nomad node config -update-servers ${nomad}

done

# configure nginx to expose UI
which nginx &>/dev/null || {
  apt-get update
  apt-get install --no-install-recommends -y nginx
}

[ -f /etc/nginx/sites-enabled/default ] && rm /etc/nginx/sites-enabled/default
cp conf/nginx.conf /etc/nginx/sites-enabled/default

service nginx restart
