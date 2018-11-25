bind_addr = "0.0.0.0"
data_dir = "/var/lib/nomad"

advertise {
  rpc = "{{ GetInterfaceIP \"eth0\" }}"
}

server {
  enabled = true
  bootstrap_expect = 3
}
