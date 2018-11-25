Vagrant.configure("2") do |config|
  config.vm.box = "alvaro/xenial64"

  config.vm.network "forwarded_port", guest: 4646, host: 4646
  config.vm.network "forwarded_port", guest: 8200, host: 8200
  config.vm.network "forwarded_port", guest: 8500, host: 8500

  config.vm.provider "virtualbox" do |v|
    v.memory = 10240
    v.cpus = 4
  end

  config.vm.provision "shell", path: "scripts/provision.sh" 

end
