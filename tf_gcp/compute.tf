variable compute_name {
  description = "Compute VM name"
  default     = "nomad-aio"
}

variable disk_size_compute_boot {
  description = "The size of data disk, in GB."
  default     = 60
}

resource "google_compute_instance" "compute" {
  name         = "${var.compute_name}"
  machine_type = "n1-standard-4"
  zone         = "${var.zone}"

  boot_disk {
    initialize_params {
      type  = "pd-ssd"
      image = "ubuntu-os-cloud/ubuntu-1604-lts"
      size  = "${var.disk_size_compute_boot}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata_startup_script = <<SCRIPT
echo processing metadata_startup_script

# installing dependencies
apt-get update
apt-get dist-upgrade -y                               # update OS
apt-get install -y git
apt-get install -y language-pack-en sysstat vim htop  # some nice tools

# install the Stackdriver monitoring agent:
curl -sS https://dl.google.com/cloudagents/install-monitoring-agent.sh | bash

# install the Stackdriver logging agent:
curl -sS https://dl.google.com/cloudagents/install-logging-agent.sh | bash

# certbot
cat > /root/certbot.sh <<EOF
which certbot || {
  apt-get update
  apt-get install -y software-properties-common
  add-apt-repository -y ppa:certbot/certbot
  apt-get update
  apt-get install -y certbot 
}

echo "now run:"
echo "sudo certbot certonly --standalone -d ${var.compute_name}.${data.google_dns_managed_zone.dns_zone.dns_name}"

echo "certs will be in:"
echo "/etc/letsencrypt/live/"

echo "type:"
echo "find /etc/letsencrypt/live/*/{cert.pem,fullchain.pem}"

echo "later, to renew the certificates you can run:"
echo "sudo certbot renew"
EOF
SCRIPT
}

resource "google_dns_record_set" "dns_compute" {
  name = "${var.compute_name}.${data.google_dns_managed_zone.dns_zone.dns_name}"
  type = "A"
  ttl  = 60

  managed_zone = "${data.google_dns_managed_zone.dns_zone.name}"

  rrdatas = ["${google_compute_instance.compute.network_interface.0.access_config.0.nat_ip}"]
}

output "compute_instance_address" {
  value = "${var.compute_name}.${data.google_dns_managed_zone.dns_zone.dns_name}"
}

output "stackdriver_compute" {
  value = "https://app.google.stackdriver.com/instances/${google_compute_instance.compute.instance_id}?project=alvaro-space"
}
