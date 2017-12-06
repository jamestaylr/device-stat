#!/usr/bin/env python
import os_client_config
import requests
import json
import logging
from collections import namedtuple


Node = namedtuple('Node', 'hostname value')
UPPER_THRESHOLD = 0.8
LOWER_THRESHOLD = 0.5


def get_dstat():
    r = requests.get('http://localhost:2180')
    return json.loads(r.content)


def random_evict(src, dest):
    s = None
    nova = os_client_config.make_client('compute', cloud='devstack-admin')
    for server in nova.servers.list():
        dd = server.to_dict()
        if dd['OS-EXT-SRV-ATTR:host'] == src:
            s = server
            break
    if s == None:
        logging.error('No instance to move on {}'.format(src))
        return
    logging.info('Migrating {} to {}'.format(s.human_id, dest))
    s.live_migrate(host=dest, block_migration=True)


def calculate_pressure(data):
    for host, metrics in data.items():
        for metric, h in metrics.items():
            data[host][metric]['pressure'] = h['expected'] / h['constant']
            logging.info('[{}] Metric {} at {} threshold'.format(
                host,
                metric,
                data[host][metric]['pressure']
            ))
    return data


def should_evict(unhealthy, healthy):
    return unhealthy.value > UPPER_THRESHOLD and \
        healthy.value < LOWER_THRESHOLD


def main():
    data = calculate_pressure(get_dstat())
    cpu_list = [Node(v, k['cpu']['pressure']) for v, k in data.items()]
    healthy = min(cpu_list, key=lambda x: x.value)
    unhealthy = max(cpu_list, key=lambda x: x.value)

    if should_evict(unhealthy, healthy):
        random_evict(unhealthy.hostname, healthy.hostname)


if __name__ == "__main__":
    logging.basicConfig(format='%(asctime)s %(message)s', level=logging.DEBUG)
    main()
