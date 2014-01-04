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

node 'centos-server.boxnet' inherits basenode {
  # Placeholder

}


node 'centos-mariadb-server.boxnet' inherits basenode {
  yumrepo { "mariadb":
    baseurl => "http://yum.mariadb.org/5.5/centos6-amd64",
    descr => "MariaDB",
    enabled => 1,
    gpgcheck => 1,
    gpgkey => "https://yum.mariadb.org/RPM-GPG-KEY-MariaDB",
    sslverify => True,
  }

  class { '::mysql::client':
    package_ensure => 'installed',
    package_name => 'MariaDB-client',
    require => Yumrepo['mariadb'],
  }

  class { '::mysql::server':
    package_name => 'MariaDB-server',
    require => Class['::mysql::client'],
    root_password    => 'a09f32lja09d9-X',
    restart => True,
    service_name => 'mysql',
    override_options => { 'mysqld' => 
      { 
      'max_connections'                 => '1024',
      'max_connections'                 => '1024',
      'innodb_buffer_pool_size'         => '128M',
      'innodb_additional_mem_pool_size' => '20M',
      'bind-address'                    => '127.0.0.1',
      'tmp_table_size'                  => '64M',
      'max_heap_table_size'             => '64M',
      'key_buffer_size'                 => '16M',
      'table_cache'                     => '2000',
      'thread_cache'                    => '20',
      'table_definition_cache'          => '4096',
      'table_open_cache'                => '1024',
      'query_cache_type'                => '1',
      'query_cache_size'                => '64M',
      'innodb_flush_method'             => 'O_DIRECT',
      'innodb_flush_log_at_trx_commit'  => '1',
      'innodb_file_per_table'           => '1',
      'long_query_time'                 => '5',
      'max-allowed-packet'              => '16M',
      'max-connect-errors'              => '1000000',
      }
    }
  }

  # This is the equivalent of running mysql_secure_installation
  class { '::mysql::server::account_security': 
    require => Class['::mysql::server'],
  }
}

node 'ubuntu-12-server' inherits basenode {
  # Nothing here yet. This node exists as a template.
}

node 'ubuntu-12-webserver' inherits basenode {
  class { 'apache':
    default_mods        => false,
    default_confd_files => false,
    mpm_module => 'prefork',
  }

  include apache::mod::php
  include apache::mod::rewrite
  include apache::mod::deflate
  include apache::mod::status
  include apache::mod::ssl

  apache::vhost { 'example.com':
    port    => '80',
    docroot => '/var/www/example.com',
      serveraliases => [
        'www.example.com',
        'blog.example.com',
        'ubuntu-12-webserver.boxnet',
      ],
    require => Class['apache'],
    ssl => true,
  }

  file {'index.php':
    path    => '/var/www/example.com/index.php',
    ensure  => present,
    mode    => 0644,
    content => '<?php phpinfo(); ?>',
    require => Apache::Vhost['example.com'],
  }

  class { 'php': }

  # CentOS and Ubuntu ship with different default PHP modules
  # Added distro switch to make this more portable
  case $operatingsystem {
    'RedHat', 'CentOS': {
      php::module { "pdo": }
      php::module { "gd": }
      php::module { "mbstring": }
      php::module { "mysql": }
      php::module { "xml": }
       }
    /^(Debian|Ubuntu)$/:{ 
      php::module { "mysql": }
      php::module { "mysqlnd": }
      php::module { "gd": }
    }
  }

}
