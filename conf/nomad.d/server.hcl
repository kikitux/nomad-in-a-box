bind_addr = "0.0.0.0"
data_dir = "/var/lib/nomad"

advertise {
  rpc = "{{ GetInterfaceIP \"eth0\" }}"
}

server {
  enabled = true
  bootstrap_expect = 3
  server_join {
    retry_join = [ "10.170.13.31", "10.170.13.32", "10.170.13.33" ]
    retry_max = 5
    retry_interval = "15s"
  }
}
