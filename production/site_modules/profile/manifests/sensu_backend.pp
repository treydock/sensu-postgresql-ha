class profile::sensu_backend {
  class { 'sensu':
    api_host      => 'sensu-backend',
    ssl_ca_source => '/vagrant/ssl/ca.pem',
  }
  class { 'sensu::agent':
    backends => ['sensu-backend:8081'],
  }
  class { 'sensu::backend':
    ssl_cert_source      => '/vagrant/ssl/sensu-backend.pem',
    ssl_key_source       => '/vagrant/ssl/sensu-backend-key.pem',
    datastore            => 'postgresql',
    manage_postgresql_db => false,
    postgresql_host      => 'haproxy',
    postgresql_port      => 5000,
    postgresql_dbname    => 'sensu_events',
    postgresql_user      => 'sensu',
    postgresql_password  => 'sensu',
  }

  file { '/var/lib/sensu/.postgresql':
    ensure  => 'directory',
    owner   => 'sensu',
    group   => 'sensu',
    mode    => '0755',
    require => Package['sensu-go-backend'],
    notify  => Service['sensu-backend'],
  }

  file { '/var/lib/sensu/.postgresql/root.crt':
    ensure => 'file',
    source => $sensu::ssl_ca_source,
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0644',
    notify => Service['sensu-backend'],
  }

  file { '/var/lib/sensu/.postgresql/postgresql.crt':
    ensure => 'file',
    source => $sensu::backend::ssl_cert_source,
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0644',
    notify => Service['sensu-backend'],
  }

  file { '/var/lib/sensu/.postgresql/postgresql.key':
    ensure => 'file',
    source => $sensu::backend::ssl_key_source,
    owner  => 'sensu',
    group  => 'sensu',
    mode   => '0600',
    notify => Service['sensu-backend'],
  }
}
