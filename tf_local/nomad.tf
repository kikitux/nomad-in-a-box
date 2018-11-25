# Configure the Nomad provider
provider "nomad" {
  address = "http://localhost:4646"
  region  = "global"
}

resource "nomad_job" "hello-world" {
  jobspec = "${file("${path.module}/../nomad_jobs/hello-world.hcl")}"
}

resource "nomad_job" "bye-world" {
  jobspec = "${file("${path.module}/../nomad_jobs/bye-world.hcl")}"
}

resource "random_pet" "mypet" {
  keepers = {
    timestamp = "${timestamp()}"
  }

  separator = " "
}

data "template_file" "greeting" {
  template = "${file("${path.module}/../nomad_jobs/greeting.tpl")}"

  vars {
    greeting = "Hello from terraform!, my pet name is ${random_pet.mypet.id}"
  }
}

resource "nomad_job" "greeting" {
  jobspec = "${data.template_file.greeting.rendered}"
}

output "sample http-echo" {
  value = "http://http-echo.127.0.0.1.xip.io:8080"
}
