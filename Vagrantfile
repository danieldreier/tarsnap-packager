    # -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.provision "shell", path: "tools/install_puppet.sh"
    config.vm.provision "shell", path: "tools/bootstrap_puppet.sh"
    config.vm.provision "shell", path: "tools/run_puppet.sh"
    if defined? VagrantPlugins::Cachier
    # Cache yum update files using vagrant-cachier, if installed
      config.cache.auto_detect = true
    end

  config.vm.define :centos6 do |node|
    node.vm.box = 'centos-64-x64-vbox4210-nocm'
    node.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210-nocm.box'
    node.vm.hostname = 'centos-rpmbuilder.boxnet'

    config.vm.provider :virtualbox do |vb|
       vb.customize ["modifyvm", :id, "--memory", "512", "--cpus", "4", "--ioapic", "on"]
    end

    node.vm.provision "shell", path: "tarsnap-build/tarsnap-rpm-builder.sh"
  end

  config.vm.define :centos5 do |node|
    node.vm.box = 'centos-59-x64-vbox4210-nocm'
    node.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-59-x64-vbox4210-nocm.box'
    node.vm.hostname = 'centos-rpmbuilder.boxnet'

    config.vm.provider :virtualbox do |vb|
       vb.customize ["modifyvm", :id, "--memory", "512", "--cpus", "4", "--ioapic", "on"]
    end

    node.vm.provision "shell", path: "tarsnap-build/tarsnap-rpm-builder.sh"
  end

end
