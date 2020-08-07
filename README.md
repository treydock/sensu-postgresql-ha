

# Commands

Query etcd cluster:

```
etcdctl member list \
--endpoints=https://psql1.example.com:2379 \
--cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem \
--cert /etc/ssl/etcd.pem \
--key /etc/ssl/etcd-key.pem
```

Query Patroni cluster on psql1:

```
curl \
--cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem \
--cert /var/lib/pgsql/cert.pem \
--key /var/lib/pgsql/key.pem \
https://psql1.example.com:8008/cluster | jq .
```
