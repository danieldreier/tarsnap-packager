vagrant-example
===============

Simple Vagrant setup that installs Puppet on a Centos 6.4 system

This sets up a dead-simple one-node puppet system. Here's how you use it:

1. Install Vagrant
2. Clone this repository
3. cd vagrant-example
4. vagrant up
5. (wait)

Now you can play with it. Let's install ntp:

Edit puppet/manifests/nodes.pp so it reads like this:
```
node default {
  class { 'ntp': }
}
```

Now, log in to the running system, install the puppet ntp module, and run the puppet manifest:

```bash
$ vagrant ssh
Last login: Sun Apr 14 22:24:07 2013
Welcome to your Vagrant-built virtual machine.
[vagrant@webserver ~]$ sudo -s
[root@webserver vagrant]# service ntpd status
ntpd is stopped
[root@webserver vagrant]# puppet module list
/etc/puppet/modules (no modules installed)
/usr/share/puppet/modules (no modules installed)
[root@webserver vagrant]# puppet module install puppetlabs/ntp
Notice: Preparing to install into /etc/puppet/modules ...
Notice: Downloading from https://forge.puppetlabs.com ...
Notice: Installing -- do not interrupt ...
/etc/puppet/modules
└─┬ puppetlabs-ntp (v2.0.1)
  └── puppetlabs-stdlib (v4.1.0)
[root@webserver vagrant]# puppet apply /vagrant/puppet/manifests/main.pp
Warning: Config file /etc/puppet/hiera.yaml not found, using Hiera defaults
Notice: Compiled catalog for webserver.boxnet in environment production in 0.60 seconds
Notice: /Stage[main]//File[/usr/local/bin/runpuppet]/ensure: defined content as '{md5}796230865256e4deac14c66312233c81'
Notice: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]/content: content changed '{md5}23775267ed60eb3b50806d7aeaa2a0f1' to '{md5}4b263233a4890fad5349d9e314e65f18'
Notice: /Stage[main]/Ntp::Service/Service[ntp]/ensure: ensure changed 'stopped' to 'running'
Notice: Finished catalog run in 0.31 seconds
[root@webserver vagrant]# service ntpd status
ntpd (pid  7128) is running...
```

Puppethelps makes the system resist changes. Try this:

```bash
[root@webserver vagrant]# yum -y remove ntp
Loaded plugins: fastestmirror, security
[snipped for brevity]
Removed:
  ntp.x86_64 0:4.2.4p8-3.el6.centos

Complete!
[root@webserver vagrant]# service ntpd status
ntpd: unrecognized service
[root@webserver vagrant]# puppet apply /vagrant/puppet/manifests/main.pp
Warning: Config file /etc/puppet/hiera.yaml not found, using Hiera defaults
Notice: Compiled catalog for webserver.boxnet in environment production in 0.59 seconds
Notice: /Stage[main]/Ntp::Install/Package[ntp]/ensure: created
Notice: /Stage[main]/Ntp::Config/File[/etc/ntp.conf]/content: content changed '{md5}23775267ed60eb3b50806d7aeaa2a0f1' to '{md5}4b263233a4890fad5349d9e314e65f18'
Notice: /Stage[main]/Ntp::Service/Service[ntp]/ensure: ensure changed 'stopped' to 'running'
Notice: Finished catalog run in 7.17 seconds
[root@webserver vagrant]# service ntpd status
ntpd (pid  7518) is running...
[root@webserver vagrant]#
```
