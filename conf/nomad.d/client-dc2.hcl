datacenter = "dc2"
client {
  enabled = true
  server_join {
    retry_join = [ "10.170.14.31", "10.170.14.32", "10.170.14.33" ]
    retry_max = 5
    retry_interval = "15s"
  }
  options = {
    "driver.raw_exec" = "1"
    "driver.raw_exec.enable" = "1"
  }
}

bind_addr = "0.0.0.0"
data_dir = "/var/lib/nomad"

advertise {
  # This should be the IP of THIS MACHINE and must be routable by every node
  # in your cluster
  rpc = "{{ GetInterfaceIP \"eth0\" }}"
}
