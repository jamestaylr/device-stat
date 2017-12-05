# `dstat` Node Profiler

## Crystal Setup

Install dependencies, which will be resolved into `lib` from `shard.yml`:
```bash
crystal deps
```

## Database Setup
### Creating the Roles and Tables

```bash
sudo su - postgres
psql
```

```psql
CREATE DATABASE stats;
CREATE USER capstone3 WITH PASSWORD 'password';
```

Then, run `psql/schema.psql` to initialize the tables, enumerated types, and indices. The database must also be externally reachable:

  - In `pg_hba.conf`, an entry `host all all 0.0.0.0/0 md5` must be added
  - In `postgresql.conf`, `listen_addresses` must be set to `'*'` to bind to `0.0.0.0` rather than localhost
  - The following modification must be made to `iptables`:
```bash
iptables -A INPUT -s 0/0 -p tcp --dport 5432 -j ACCEPT
```

`telnet` (instead of a `psql` client) can be used to trivially verify the port is open on the host machine.

## Configure Cron

```bash
crontab -e
```

Should be configured to run benchmarking (`dstat -r`) every minute:

```text
* * * * * /usr/local/dstat/dstat -r
```

## SystemD Configuration

Move the service unit file, `dstat.service` into `/etc/systemd/system` (altering the `user` option as appropriate). Then the web service can be interacted with using the expected `service` commands:
```bash
sudo service dstat status
```

If the unit file is changed on disk, run: `systemctl daemon-reload` as `root`.
