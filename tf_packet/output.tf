output "info consul" {
  value = "${format("http://consul.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "info nomad" {
  value = "${format("http://nomad.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "info vault" {
  value = "${format("http://vault.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "info vault root token" {
  value = "changeme"
}


output "public_ip" {
  value = "${packet_device.vmonpacket.access_public_ipv4}"
}

output "where_to_ssh" {
  value = "${format("ssh root@%s", packet_device.vmonpacket.access_public_ipv4)}"
}
