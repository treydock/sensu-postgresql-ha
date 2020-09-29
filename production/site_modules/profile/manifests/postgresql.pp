class profile::postgresql (
  Hash $etcd_cluster_hosts = {
    'psql1' => 'psql1.example.com',
    'psql2' => 'psql2.example.com',
    'psql3' => 'psql3.example.com',
  },
) {
  file { '/etc/ssl':
    ensure => 'directory',
  }
  $etcd_hosts = $etcd_cluster_hosts.map |$name, $hostname| {
    "${name}=https://${hostname}:2380"
  }
  class { 'etcd':
    config => {
      'data-dir'                    => '/var/lib/etcd',
      'name'                        => $facts['networking']['hostname'],
      'initial-advertise-peer-urls' => "https://${facts['networking']['fqdn']}:2380",
      'listen-peer-urls'            => 'https://0.0.0.0:2380',
      'listen-client-urls'          => 'https://0.0.0.0:2379',
      'advertise-client-urls'       => "https://${facts['networking']['fqdn']}:2379",
      'initial-cluster-token'       => 'etcd-cluster-1',
      'initial-cluster'             => join($etcd_hosts, ','),
      'initial-cluster-state'       => 'new',
      'enable-v2'                   => true,
      'client-transport-security'   => {
        'cert-file'       => '/etc/ssl/etcd.pem',
        'key-file'        => '/etc/ssl/etcd-key.pem',
        'trusted-ca-file' => $facts['puppet_localcacert'],
      },
      'peer-transport-security'     => {
        'cert-file'       => '/etc/ssl/etcd.pem',
        'key-file'        => '/etc/ssl/etcd-key.pem',
        'trusted-ca-file' => $facts['puppet_localcacert'],
      },
    },
  }
  file { '/etc/ssl/etcd.pem':
    ensure => 'file',
    owner  => $etcd::user,
    group  => $etcd::group,
    mode   => '0644',
    source => $facts['puppet_hostcert'],
    before => Service['etcd'],
  }
  file { '/etc/ssl/etcd-key.pem':
    ensure => 'file',
    owner  => $etcd::user,
    group  => $etcd::group,
    mode   => '0644',
    source => $facts['puppet_hostprivkey'],
    before => Service['etcd'],
  }

  $postgres_ssl_config = {
    'ssl'           => 'true',
    'ssl_cert_file' => '/var/lib/pgsql/cert.pem',
    'ssl_key_file'  => '/var/lib/pgsql/key.pem',
    'ssl_ca_file'   => $facts['puppet_localcacert'],
  }
  class { 'patroni':
    scope                   => 'cluster',
    use_etcd                => true,
    etcd_host               => $facts['networking']['fqdn'],
    etcd_protocol           => 'https',
    etcd_cacert             => $facts['puppet_localcacert'],
    etcd_cert               => '/var/lib/pgsql/cert.pem',
    etcd_key                => '/var/lib/pgsql/key.pem',
    pgsql_connect_address   => "${facts['networking']['fqdn']}:5432",
    restapi_connect_address => "${facts['networking']['fqdn']}:8008",
    pgsql_bin_dir           => '/usr/pgsql-9.6/bin',
    pgsql_data_dir          => '/var/lib/pgsql/9.6/data',
    pgsql_pgpass_path       => '/var/lib/pgsql/pgpass',
    pgsql_parameters        => $postgres_ssl_config + {
      'max_connections' => 5000,
    },
    bootstrap_pg_hba        => [
      'local all postgres ident',
      'host all all 0.0.0.0/0 md5',
      'host replication repl 0.0.0.0/0 md5',
    ],
    pgsql_pg_hba            => [
      'local all postgres ident',
      'host all all 0.0.0.0/0 md5',
      'host replication repl 0.0.0.0/0 md5',
      'host sensu_events sensu 0.0.0.0/0 password',
    ],
    superuser_username      => 'postgres',
    superuser_password      => 'postgrespassword',
    replication_username    => 'repl',
    replication_password    => 'replpassword',
    bootstrap_post_bootstrap => '/opt/patroni-bootstrap.sh',
    restapi_certfile         => '/var/lib/pgsql/cert.pem',
    restapi_keyfile          => '/var/lib/pgsql/key.pem',
    restapi_cafile           => $facts['puppet_localcacert'],
    restapi_verify_client    => 'required',
  }
  file { '/var/lib/pgsql/key.pem':
    ensure  => 'file',
    source  => $facts['puppet_hostprivkey'],
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0600',
    require => Package[$patroni::postgresql_package_name],
    before  => Service['patroni'],
  }
  file { '/var/lib/pgsql/cert.pem':
    ensure  => 'file',
    source  => $facts['puppet_hostcert'],
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0600',
    require => Package[$patroni::postgresql_package_name],
    before  => Service['patroni'],
  }
  file { '/opt/patroni-bootstrap.sh':
    ensure  => 'file',
    owner   => 'postgres',
    group   => 'root',
    mode    => '0750',
    content => template('profile/patroni-bootstrap.sh.erb'),
    require => Package[$patroni::postgresql_package_name],
    before  => Service['patroni'],
  }
}
