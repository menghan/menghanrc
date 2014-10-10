#!/usr/bin/env python
# coding=utf-8

import re
import time
from collections import defaultdict

import sh
import requests

providers = {
    'digitalocean': {
        'index': 'http://ipv4.speedtest-sgp1.digitalocean.com/',
        're': re.compile(ur'speedtest-[^.]*.digitalocean.com'),
    },
    'linode': {
        'index': 'https://www.linode.com/speedtest',
        're': re.compile(ur'speedtest.[^. ]*.linode.com'),
    },
    'vultr': {
        'index': 'https://www.vultr.com/faq/#downloadspeedtests',
        're': re.compile(ur'[^. ]-ping.vultr.com'),
    },
}


def test_speed(addr):
    report = sh.mtr(addr, '--report')
    for line in reversed(map(unicode.strip, report.splitlines())):
        if line:
            break
    loss, worst = float(line.split()[-7].rstrip('%')), float(line.split()[-2])
    return loss, worst


def report(results):
    for provider, provider_results in results.iteritems():
        best = sorted(sum(provider_results.values(), []))[0]
        for addr, addr_results in provider_results.iteritems():
            if best in addr_results:
                loss, worst_ping = int(best[0]), best[1]
                print '%s Best address: %s: Loss %d%% Worst Ping %.2fms' % (provider.title(), addr, loss, worst_ping)


def main():
    result = defaultdict(lambda : defaultdict(list))
    for i in xrange(3):
        for provider, config in providers.iteritems():
            index, reobj = config['index'], config['re']
            for addr in set(reobj.findall(requests.get(index).text)):
                result[provider][addr].append(test_speed(addr))
    report(result)


if __name__ == '__main__':
    main()
