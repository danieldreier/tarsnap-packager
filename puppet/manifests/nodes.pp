# This is for a system where we'll be building CentOS 6 RPMs

node basenode {
  class { '::ntp':
    servers        => [ '0.north-america.pool.ntp.org',
                        '0.centos.pool.ntp.org',
                        'time.nist.gov',
                        'nist1-la.ustiming.org' ],
    restrict       => ['127.0.0.1'],
    service_ensure => 'running',
    service_enable => true,
  }

  # Install the basic sysadmin tools we often need
  $sysadmin_tools = [ 'man', 'screen', 'nc', 'mtr', 'iotop', 'git' ]
  package { $sysadmin_tools:
    ensure  => 'installed',
    require => Yumrepo['epel'],
  }

}

node default inherits basenode {
  class { 'yum':
    extrarepo => [ 'epel' , 'puppetlabs' ],
  }
  class { 'lsb': }

  $rpm_tools = [ 'rpm-build', 'redhat-rpm-config', 'ruby-devel.x86_64', 'rubygems', 'ruby' ]
  package { $rpm_tools:
    ensure  => 'installed',
    require => Class['yum'],
  }
  $compile_tools = [ 'make', 'gcc' ]
  package { $compile_tools: ensure => 'installed' }

  $tarsnap_dependencies = [ 'openssl-devel', 'zlib-devel', 'e2fsprogs-devel']
  package { $tarsnap_dependencies: ensure => 'installed' }

  # Tool for building packages
  package { 'fpm':
    ensure   => 'installed',
    provider => 'gem',
    require  => [ Package['ruby-devel.x86_64'], Package['rubygems'], Package['ruby'] ],
  }

}
