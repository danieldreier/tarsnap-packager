# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  
  box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210-nocm.box'
  box_name = 'centos-64-x64-vbox4210-nocm'

  config.vm.define :webserver do |node|
    node.vm.box = box_name
    node.vm.hostname = 'webserver.boxnet'

    #config.vm.network :forwarded_port, guest: 80, host: 80
    #config.vm.network :forwarded_port, guest: 443, host: 443

    config.vm.network :private_network, ip: "192.168.33.10"

    config.ssh.forward_agent = true

    config.vm.provider :virtualbox do |vb|
       vb.customize ["modifyvm", :id, "--memory", "512", "--cpus", "4", "--ioapic", "on"]
    end

    config.vm.provision "shell", path: "tools/pre_setup.sh"
  end


end
