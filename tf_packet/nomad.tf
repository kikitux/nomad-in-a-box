# Configure the Nomad provider
provider "nomad" {
  address = "http://${packet_device.vmonpacket.access_public_ipv4}:4646"
  region  = "global"
}

resource "nomad_job" "hello-world" {
  jobspec =  "${file("${path.module}/../nomad_jobs/hello-world.hcl")}"
}

resource "nomad_job" "bye-world" {
  jobspec =  "${file("${path.module}/../nomad_jobs/bye-world.hcl")}"
}

data "template_file" "greeting" {
    template = "${file("${path.module}/../nomad_jobs/greeting.tpl")}"
    vars {
        greeting = "Hello from terraform!" 
    }
}

resource "nomad_job" "greeting" {
  jobspec =  "${data.template_file.greeting.rendered}"
}

output "sample http-echo" {
  value = "${format("http://http-echo.%s.xip.io", packet_device.vmonpacket.access_public_ipv4)}"
}
