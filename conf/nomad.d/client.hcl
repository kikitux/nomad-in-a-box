client {
  enabled = true
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
