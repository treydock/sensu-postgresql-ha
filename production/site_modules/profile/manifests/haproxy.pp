class profile::haproxy {
  file { '/etc/rsyslog.d/haproxy.conf':
    content => join([
      '$ModLoad imudp',
      '$UDPServerAddress 127.0.0.1',
      '$UDPServerRun 514',
      'local0.* /var/log/haproxy.log',
      '',
    ], "\n"),
    notify  => Exec['rsyslog-restart'],
  }
  exec { 'rsyslog-restart':
    command     => '/bin/systemctl restart rsyslog',
    refreshonly => true,
  }

  class { 'haproxy':
    global_options => {
      maxconn => 100,
      log     => '127.0.0.1:514 local0',
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

  concat { '/etc/haproxy/haproxy.pem':
   owner          => 'root',
   group          => 'root',
   mode           => '0600',
   ensure_newline => true,
   require        => Package['haproxy'],
   notify         => Service['haproxy'],
  }
  concat::fragment { 'haproxy-ssl-cert':
    target => '/etc/haproxy/haproxy.pem',
    source => '/vagrant/ssl/haproxy.pem',
    order  => '01',
  }
  concat::fragment { 'haproxy-ssl-key':
    target => '/etc/haproxy/haproxy.pem',
    source => '/vagrant/ssl/haproxy-key.pem',
    order  => '02',
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
    ipaddresses       => 'psql1',
    ports             => '5432',
    options           => 'maxconn 100 check port 8008 check-ssl ca-file /vagrant/ssl/ca.pem crt /etc/haproxy/haproxy.pem',
  }
  haproxy::balancermember { 'psql2':
    listening_service => 'postgresql',
    server_names      => 'psql2',
    ipaddresses       => 'psql2',
    ports             => '5432',
    options           => 'maxconn 100 check port 8008 check-ssl ca-file /vagrant/ssl/ca.pem crt /etc/haproxy/haproxy.pem',
  }
  haproxy::balancermember { 'psql3':
    listening_service => 'postgresql',
    server_names      => 'psql3',
    ipaddresses       => 'psql3',
    ports             => '5432',
    options           => 'maxconn 100 check port 8008 check-ssl ca-file /vagrant/ssl/ca.pem crt /etc/haproxy/haproxy.pem',

  }
}
