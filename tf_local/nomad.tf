# Configure the Nomad provider
provider "nomad" {
  address = "http://localhost:4646"
  region  = "global"
}

resource "nomad_job" "nginx" {
  jobspec = "${file("${path.module}/../nomad_jobs/nginx.hcl")}"
}

output "sample nginx" {
  value = "http://nginx.127.0.0.1.xip.io:8080"
}
