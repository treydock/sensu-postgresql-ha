class profile::sensu_backend {
  class { 'sensu':
    api_host => 'sensu-backend.example.com',
  }
  class { 'sensu::agent':
    backends => ['sensu-backend.example.com:8081'],
  }
  class { 'sensu::backend':
    datastore                  => 'postgresql',
    manage_postgresql_db       => false,
    postgresql_host            => 'haproxy.example.com',
    postgresql_port            => 5000,
    postgresql_dbname          => 'sensu_events',
    postgresql_user            => 'sensu',
    postgresql_password        => 'sensu',
    postgresql_ssl_ca_source   => $sensu::ssl_ca_source,
    postgresql_ssl_cert_source => $facts['puppet_hostcert'],
    postgresql_ssl_key_source  => $facts['puppet_hostprivkey'],
  }
}
