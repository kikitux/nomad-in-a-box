job "nginx" {
  datacenters = ["dc1"]
  type = "service"
  group "cache" {
    count = 3
    task "nginx" {
      driver = "docker"
      config {
        image = "nginx:latest"
	volumes = [
                    "new/default.conf:/etc/nginx/conf.d/default.conf",
                    "new/index.html:/usr/share/nginx/html/index.html"
                  ]
	network_mode = "host"
      }

      template {
        destination   = "new/index.html"
        change_mode   = "restart"
        data = <<EOH
<p>
Hello!

We are running on<br>

datacenter:    {{ env "node.datacenter" }}<br>
hostname:    {{ env "attr.unique.hostname" }}<br>
port:    {{ env "NOMAD_PORT_nginx" }}<br>
</p>
EOH
      }

      artifact {
        source = "https://raw.githubusercontent.com/kikitux/nomad-in-a-box/master/nomad_jobs/nginx.tpl"
      }

      template {
        source        = "local/nginx.tpl"
        destination   = "new/default.conf"
        change_mode   = "restart"
      }

      resources {
        network {
          mbits = 10
          port "nginx" {
            static = 8080
          }
        }
      }

      service {
        name = "nginx"
        port = "nginx"

        tags = [
          "nginx",
        ]
      }

    }
  }
}
