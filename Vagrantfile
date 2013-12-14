    # -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  

  config.vm.define :centos_server do |node|
    #node.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210-nocm.box'
    #node.box_name = 'centos-64-x64-vbox4210-nocm'

    node.vm.box = 'centos-64-x64-vbox4210-nocm'
    node.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210-nocm.box'
    node.vm.hostname = 'centos-server.boxnet'

    # Cache yum update files using vagrant-cachier
    config.cache.auto_detect = true

    #config.vm.network :forwarded_port, guest: 80, host: 80
    #config.vm.network :forwarded_port, guest: 443, host: 443
    #config.vm.network :forwarded_port, guest: 21, host: 21

    config.vm.network :private_network, ip: "192.168.33.10"

    #config.ssh.forward_agent = true

    #config.vm.synced_folder "../www/vhosts", "/var/www/vhosts"
    #config.vm.synced_folder "./", "/opt/puppet"

    config.vm.provider :virtualbox do |vb|
       vb.customize ["modifyvm", :id, "--memory", "512", "--cpus", "4", "--ioapic", "on"]
    end

    config.vm.provision "shell", path: "tools/pre_setup.sh"
  end

  config.vm.define :centos_mariadb_server do |node|
    node.vm.box = 'centos-64-x64-vbox4210-nocm'
    node.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210-nocm.box'
    node.vm.hostname = 'centos-mariadb-server.boxnet'

    # Cache yum update files using vagrant-cachier
    config.cache.auto_detect = true

    config.vm.network :forwarded_port, guest: 3306, host: 3306
    config.vm.network :private_network, ip: "192.168.33.12"

    config.vm.provider :virtualbox do |vb|
       vb.customize ["modifyvm", :id, "--memory", "512", "--cpus", "4", "--ioapic", "on"]
    end

    config.vm.provision "shell", path: "tools/pre_setup.sh"
  end

  config.vm.define :ubuntu_12_server do |node|
    node.vm.box = "ubuntu-server-12042-x64-vbox4210-nocm"
    node.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-12042-x64-vbox4210-nocm.box'
    node.vm.hostname = 'ubuntu-12-server.boxnet'

    # Cache yum/apt update files using vagrant-cachier
    config.cache.auto_detect = true

    config.vm.network :private_network, ip: "192.168.33.11"

    config.vm.provider :virtualbox do |vb|
       vb.customize ["modifyvm", :id, "--memory", "512", "--cpus", "4", "--ioapic", "on"]
    end

    config.vm.provision "shell", path: "tools/pre_setup.sh"
  end
  
end
