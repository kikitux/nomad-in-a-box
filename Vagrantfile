# -*- mode: ruby -*-
# vi: set ft=ruby :

info = <<-'EOF'


Vault root token is changeme

Then you can reach the services at

consul http://localhost:8500
nomad http://localhost:4646
vault http://localhost:8200

Or you can also use:

consul http://consul.127.0.0.1.xip.io:8000
nomad http://nomad.127.0.0.1.xip.io:8000
vault http://vault.127.0.0.1.xip.io:8000

EOF

Vagrant.configure("2") do |config|
  config.vm.box = "alvaro/bionic64"
  config.vm.hostname = "bionic64"

  config.vm.network "forwarded_port", guest: 8000, host: 8000
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 4646, host: 4646
  config.vm.network "forwarded_port", guest: 8200, host: 8200
  config.vm.network "forwarded_port", guest: 8500, host: 8500

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.memory = 4096
    v.cpus = 2
  end

  config.vm.provision "shell", path: "scripts/provision.sh" 
  puts info if ARGV[0] == "status"

end
