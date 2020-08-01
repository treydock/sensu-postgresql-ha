class profile::haproxy {
  class { 'haproxy':
    global_options => {
      maxconn => 100,
    },
    defaults_options => {
      log     => 'global',
      mode    => 'tcp',
      retries => 2,
      timeout => [
        'client 30m',
        'connect 4s',
        'server 30m',
        'check 5s',
      ],
    },
  }

  haproxy::listen { 'stats':
    collect_exported => false,
    ipaddress        => '*',
    ports            => '7000',
    options          => [
      { 'stats' => 'enable' },
      { 'stats' => 'uri /' },
    ],
  }
  haproxy::listen { 'postgresql':
    collect_exported  => false,
    ipaddress         => '*',
    ports             => '5000',
    options           => {
      'option'  => ['httpchk'],
      'http-check'  => 'expect status 200',
      'default-server'  => 'inter 3s fall 3 rise 2 on-marked-down shutdown-sessions',
    },
  }
  haproxy::balancermember { 'psql1':
    listening_service => 'postgresql',
    server_names      => 'psql1',
    ipaddresses       => '10.0.0.101',
    ports             => '5432',
    options           => 'maxconn 100 check port 8008',
  }
  haproxy::balancermember { 'psql2':
    listening_service => 'postgresql',
    server_names      => 'psql2',
    ipaddresses       => '10.0.0.102',
    ports             => '5432',
    options           => 'maxconn 100 check port 8008',
  }
  haproxy::balancermember { 'psql3':
    listening_service => 'postgresql',
    server_names      => 'psql3',
    ipaddresses       => '10.0.0.103',
    ports             => '5432',
    options           => 'maxconn 100 check port 8008',
  }
}
