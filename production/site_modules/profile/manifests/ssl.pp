class profile::ssl {
  file { '/etc/ssl':
    ensure => 'directory',
  }
  $psql_ssl = {
    'ensure' => 'file',
    'owner'  => 'postgres',
    'group'  => 'postgres',
  }
  file { '/etc/ssl/psql.pem':
    mode   => '0644',
    source => '/vagrant/ssl/psql.pem',
    *      => $psql_ssl,
  }
  file { '/etc/ssl/psql-key.pem':
    mode   => '0600',
    source => '/vagrant/ssl/psql-key.pem',
    *      => $psql_ssl,
  }
}
