# Configure the Nomad provider
provider "nomad" {
  address = "http://localhost:4646"
  region  = "global"
}

resource "nomad_job" "hello" {
  jobspec = "${file("${path.module}/../nomad_jobs/hello.hcl")}"
}

output "sample_hello" {
  value = "http://hello.127.0.0.1.xip.io:8080"
}
