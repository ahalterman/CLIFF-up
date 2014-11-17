# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    vb.cpus = 2
end
  config.vm.box = "hashicorp/precise64"
  config.vm.network "forwarded_port", guest: 8080, host: 8999
  config.vm.provision :shell, :path => "bootstrap.sh"
end
