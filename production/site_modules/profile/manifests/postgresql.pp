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
    },
  }
}
