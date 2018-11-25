output "public_ip" {
  value = "${packet_device.vmonpacket.access_public_ipv4}"
}

output "where_to_curl" {
  value = "${format("http://%s:8500", packet_device.vmonpacket.access_public_ipv4)}"
}

output "where_to_ssh" {
  value = "${format("ssh root@%s", packet_device.vmonpacket.access_public_ipv4)}"
}
