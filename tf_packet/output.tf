output "public_ip" {
  value = "${packet_device.vmonpacket.access_public_ipv4}"
}

output "consul1" {
  value = "${format("http://consul1.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "consul2" {
  value = "${format("http://consul2.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "consul3" {
  value = "${format("http://consul3.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "vault1" {
  value = "${format("http://vault1.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "nomad1" {
  value = "${format("http://nomad1.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "nomad2" {
  value = "${format("http://nomad2.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "nomad3" {
  value = "${format("http://nomad3.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}

output "where_to_ssh" {
  value = "${format("ssh root@%s", packet_device.vmonpacket.access_public_ipv4)}"
}
