# token variable
variable "token" {
  description = "packet token"
}

# project id variable
variable "projectid" {
  description = "packet project id"
}

# prefix variable
variable "prefix" {
  default     = "alvaro"
  description = "prefix for names"
}

# Configure the Packet Provider
provider "packet" {
  auth_token = "${var.token}"
}

resource "packet_device" "vmonpacket" {
  hostname         = "${var.prefix}1"
  plan             = "baremetal_0"
  facility         = "ams1"
  operating_system = "ubuntu_16_04"
  billing_cycle    = "hourly"
  project_id       = "${var.projectid}"

  user_data = <<SCRIPT
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install git -y
git clone https://github.com/kikitux/nomad-in-a-box /root/nomad-in-a-box
cd /root/nomad-in-a-box
bash scripts/before.sh
SCRIPT
}

#output "root_pw" {
#  value = "${data.packet_device.vmonpacket.root_passsword}"
#}
