node default {
  case $facts['networking']['hostname'] {
    /^psql/: { include role::postgresql }
    /haproxy/: { include role::haproxy }
    /sensu-backend/: { include role::sensu_backend }
  }
}
