job "bye-world" {
  datacenters = ["dc1"]

  group "echo" {
    count = 1
    task "server" {
      driver = "docker"

      config {
        image = "hashicorp/http-echo:latest"
        args  = [
          "-listen", ":8080",
          "-text", "Bye World",
        ]
      }

      resources {
        network {
          mbits = 10
          port "http" {
            static = 8080
          }
        }
      }

      service {
        name = "http-echo"
        port = "http"

        tags = [
          "http-echo",
        ]

        check {
          type     = "http"
          path     = "/health"
          interval = "5s"
          timeout  = "5s"
        }
      }
    }
  }
}