#!/bin/bash
# Must install postgresql-client package

PSQL_USER="capstone0";
PSQL_IP="192.168.0.219";
export PGPASSWORD='password';

psql stats -U $PSQL_USER -h $PSQL_IP << EOH
    INSERT INTO constants (type, value, hostname)
    VALUES ('cpu', $(nproc), '$(hostname)');
EOH

psql stats -U $PSQL_USER -h $PSQL_IP << EOH
    INSERT INTO constants (type, value, hostname)
    VALUES (
        'memory',
        $(cat /proc/meminfo | grep 'MemTotal' | awk '{print $2}'),
        '$(hostname)'
    );
EOH

psql stats -U $PSQL_USER -h $PSQL_IP << EOH
    INSERT INTO constants (type, value, hostname)
    VALUES (
        'disk',
        $(df / --output=size | tail -n 1),
        '$(hostname)'
    );
EOH
