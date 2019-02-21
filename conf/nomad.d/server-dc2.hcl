datacenter = "dc2"
bind_addr = "0.0.0.0"
data_dir = "/var/lib/nomad"

advertise {
  rpc = "{{ GetInterfaceIP \"eth0\" }}"
}

server {
  enabled = true
  server_join {
    retry_join = [ "10.170.13.31", "10.170.13.32", "10.170.13.33", "10.170.14.31", "10.170.14.32", "10.170.14.33" ]
    retry_max = 5
    retry_interval = "15s"
  }
}
