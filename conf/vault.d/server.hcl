{
  "ui": true,
  "backend": {
    "consul": {
      "address": "http://localhost:8500",
      "path": "vault/"
    }
  },
  "default_lease_ttl": "168h",
  "max_lease_ttl": "720h",
  "plugin_directory": "/usr/local/vault/plugins",
  "disable_mlock": true
}
