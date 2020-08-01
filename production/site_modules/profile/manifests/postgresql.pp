class profile::postgresql (
  String $etcd_interface = 'eth1',
  Hash $etcd_cluster_hosts = {
    'psql1' => 'psql1',
    'psql2' => 'psql2',
    'psql3' => 'psql3',
  }
) {
  class { '::postgresql::globals':
    encoding            => 'UTF-8',
    locale              => 'en_US.UTF-8',
    manage_package_repo => true,
    version             => '9.6',
  }
  package { ['postgresql96-server','postgresql96-contrib']:
    ensure => present,
  }

  $etcd_ip = $facts['networking']['interfaces'][$etcd_interface]['ip']
  $etcd_hosts = $etcd_cluster_hosts.map |$name, $hostname| {
    "${name}=http://${hostname}:2380"
  }
  class { 'etcd':
    config => {
      'data-dir'                    => '/var/lib/etcd',
      'name'                        => $facts['networking']['hostname'],
      'initial-advertise-peer-urls' => "http://${etcd_ip}:2380",
      'listen-peer-urls'            => 'http://0.0.0.0:2380',
      'listen-client-urls'          => 'http://0.0.0.0:2379',
      'advertise-client-urls'       => "http://${etcd_ip}:2379",
      'initial-cluster-token'       => 'etcd-cluster-1',
      'initial-cluster'             => join($etcd_hosts, ','),
      'initial-cluster-state'       => 'new',
      'enable-v2'                   => true,
    },
  }

  yum::install { 'patroni':
    source => 'https://github.com/cybertec-postgresql/patroni-packaging/releases/download/1.6.5-1/patroni-1.6.5-1.rhel7.x86_64.rpm',
    before => Class['patroni'],
  }
  class { 'patroni':
    scope                   => 'cluster',
    use_etcd                => true,
    pgsql_connect_address   => "${facts['networking']['fqdn']}:5432",
    restapi_connect_address => "${facts['networking']['fqdn']}:8008",
    pgsql_bin_dir           => '/usr/pgsql-9.6/bin',
    pgsql_data_dir          => '/var/lib/pgsql/9.6/data',
    pgsql_pgpass_path       => '/var/lib/pgsql/pgpass',
    pgsql_parameters        => {
      'max_connections' => 5000,
    },
    pgsql_pg_hba            => [
      'host all all 0.0.0.0/0 md5',
      'host replication repl 0.0.0.0/0 md5',
    ],
    superuser_username      => 'postgres',
    superuser_password      => 'postgrespassword',
    replication_username    => 'repl',
    replication_password    => 'replpassword',
  }
  File[$patroni::config_path] ~> Service[$patroni::servicename]
}
