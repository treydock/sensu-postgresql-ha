class profile::sensu_backend {
  class { 'sensu':
    api_host => 'sensu-backend',
    use_ssl  => false,
  }
  class { 'sensu::agent':
    backends => ['sensu-backend:8081'],
  }
  class { 'sensu::backend':
    datastore            => 'postgresql',
    manage_postgresql_db => false,
    postgresql_host      => 'haproxy',
    postgresql_port      => 5000,
    postgresql_dbname    => 'sensu_events',
    postgresql_user      => 'sensu',
    postgresql_password  => 'sensu',
  }

  $dsn = "${sensu::backend::datastore::postgresql::dsn}?sslmode=disable"
  Sensu_postgres_config <| title == $sensu::backend::postgresql_name |> {
    dsn => $dsn,
  }
}
