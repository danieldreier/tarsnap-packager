# This is for a system where we'll be building CentOS 6 RPMs

node basenode {
  class { 'timezone':
    timezone => 'US/Pacific',
  }

  class { '::ntp':
    # Using 4 sources for NTP to allow 3 sources during DNS failure on one of
    # these providers 3 sources needed to sanity-check time by majority vote,
    # in case of bad ntp server
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
  package { $sysadmin_tools: ensure => 'installed' }

}

node default inherits basenode {
  # Placeholder
  #exec { 'yum Group Install':
  #  unless  => '/usr/bin/yum grouplist "Development tools" | /bin/grep "^Installed Groups"',
  #  command => '/usr/bin/yum -y groupinstall "Development tools"',
  #}

  $rpm_tools = [ 'rpm-build', 'redhat-rpm-config', 'redhat-lsb-core' ]
  package { $rpm_tools: ensure => 'installed' }
  $compile_tools = [ 'make', 'gcc' ]
  package { $compile_tools: ensure => 'installed' }

  $tarsnap_dependencies = [ 'openssl-devel', 'zlib-devel', 'e2fsprogs-devel']
  package { $tarsnap_dependencies: ensure => 'installed' }

  # Tool for building packages
  package { 'fpm':
    ensure   => 'installed',
    provider => 'gem',
    require  => Package['rubygems'],
  }

}
