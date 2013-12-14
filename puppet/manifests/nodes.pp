node basenode {
  class { 'timezone':
    timezone => 'US/Pacific',
  } 

#  class { "ssh":       
#    sshd_config_use_dns => false,
#    permit_root_login   => 'no',
#    sshd_client_alive_interval  => '15',
#  }

  class { 'ntp': }

  $sysadmin_tools = [ 'man', 'screen', 'nc', 'mtr', 'iotop', 'openssh-clients', 'git' ]
  package { $sysadmin_tools: ensure => "installed" }

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
    #service_enabled => True,
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