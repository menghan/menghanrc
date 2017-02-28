#!/usr/bin/env python
# coding=utf-8

import re
import time
import logging
from collections import defaultdict

import sh
import requests

providers = {
    'linode': {
        'index': 'https://www.linode.com/speedtest',
        're': re.compile(ur'speedtest.[-\w]*.linode.com'),
    },
    'vultr': {
        'index': 'https://www.vultr.com/faq/#downloadspeedtests',
        're': re.compile(ur'[-\w]*-ping.vultr.com'),
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
        total = sum(provider_results.values(), [])
        total = filter(lambda _, worst: worst != 0, total)
        if not total:
            print '%s mtr failed' % provider.title()
            continue
        best = sorted(total)[0]
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
                logging.warn('testing %s from provider %s...', addr, provider)
                loss, worst = test_speed(addr)
                logging.warn('test %s from provider %s done. loss: %s, worst: %s', addr, provider, loss, worst)
                result[provider][addr].append(test_speed(addr))
        break
    report(result)


if __name__ == '__main__':
    main()
