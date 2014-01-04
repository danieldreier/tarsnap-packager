# This is for a system where we'll be building CentOS 6 RPMs

node basenode {
  class { 'timezone':
    timezone => 'US/Pacific',
  }

  class { '::ntp':
    # Using 4 sources for NTP to allow 3 sources during DNS failure on one of these providers
    # 3 sources needed to sanity-check time by majority vote, in case of bad ntp server
    servers  => [ '0.north-america.pool.ntp.org', '0.centos.pool.ntp.org', 'time.nist.gov', 'nist1-la.ustiming.org' ],
    restrict => ['127.0.0.1'],
    service_ensure => 'running',
    service_enable => true,
  }

  # Install the basic sysadmin tools we often need
  case $operatingsystem {
    'RedHat', 'CentOS': { $sysadmin_tools = [ 'man', 'screen', 'nc', 'mtr', 'iotop', 'openssh-clients', 'git' ]  }
    /^(Debian|Ubuntu)$/:{ $sysadmin_tools = [ 'man', 'screen', 'netcat6', 'mtr', 'iotop', 'openssh-client', 'git' ] }
  }
  package { $sysadmin_tools: ensure => "installed" }

}

node default inherits basenode {
  # Placeholder
  exec { 'yum Group Install':
    unless  => '/usr/bin/yum grouplist "Development tools" | /bin/grep "^Installed Groups"',
    command => '/usr/bin/yum -y groupinstall "Development tools"',
  }

  package { 'fedora-packager': ensure => 'installed' }
}
