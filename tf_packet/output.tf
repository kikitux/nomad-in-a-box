output "public_ip" {
  value = "${packet_device.vmonpacket.access_public_ipv4}"
}

output "consul1" {
  value = "${format("http://consul1.%s..xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "consul2" {
  value = "${format("http://consul2.%s..xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "consul3" {
  value = "${format("http://consul3.%s..xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "where_to_ssh" {
  value = "${format("ssh root@%s", packet_device.vmonpacket.access_public_ipv4)}"
}
