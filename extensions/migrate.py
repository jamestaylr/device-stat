import os_client_config
import requests
import json
import logging


THRESHOLD = 0.8


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


def main():
    eviction_target = None
    healthy_target = {
            'name': None,
            'health': 1,
        }

    for host, state in get_dstat().items():
        health = []
        for metric, values in state.items():
            pressure = values['expected'] / values['constant']
            health.append(pressure)
            logging.info('Metric {} at {} threshold'.format(metric, pressure))
        avg = sum(health) / len(health)
        if avg > THRESHOLD:
            eviction_target = host

        if avg < healthy_target['health']:
            healthy_target['name'] = host
            healthy_target['health'] = avg

    if eviction_target is not None:
        random_evict(eviction_target, healthy_target['name'])


if __name__ == "__main__":
    logging.basicConfig(format='%(asctime)s %(message)s', level=logging.DEBUG)
    main()
