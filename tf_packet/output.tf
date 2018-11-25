output "info consul1" {
  value = "${format("http://consul1.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "info consul2" {
  value = "${format("http://consul2.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "info consul3" {
  value = "${format("http://consul3.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "info vault1" {
  value = "${format("http://vault1.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "info nomad1" {
  value = "${format("http://nomad1.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "info nomad2" {
  value = "${format("http://nomad2.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "info nomad3" {
  value = "${format("http://nomad3.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "public_ip" {
  value = "${packet_device.vmonpacket.access_public_ipv4}"
}

output "where_to_ssh" {
  value = "${format("ssh root@%s", packet_device.vmonpacket.access_public_ipv4)}"
}
