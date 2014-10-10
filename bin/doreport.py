#!/usr/bin/env python
# coding=utf-8

import re
import time
from collections import defaultdict

import sh
import requests

index = 'http://ipv4.speedtest-sgp1.digitalocean.com/'


def test_speed(addr):
    report = sh.mtr(addr, '--report')
    for line in reversed(map(unicode.strip, report.splitlines())):
        if line:
            break
    loss, worst = float(line.split()[-7].rstrip('%')), float(line.split()[-2])
    before_dl = time.time()
    requests.get('http://%s/10mb.test' % addr).text
    dl = time.time() - before_dl
    return loss, worst, dl


def report(result):
    best = sorted(sum(result.values(), []))[0]
    for addr, addr_results in result.iteritems():
        if best in addr_results:
            loss, worst_ping, dl_speed = int(best[0]), best[1], 10/best[2]
            print 'Best address: %s: Loss %d%% Worst Ping %.2fms Download Speed %.2fMB/s' % (addr, loss, worst_ping, dl_speed)
            if loss > 10 or worst_ping > 100:
                print 'Still worse than linode.'
            else:
                print 'Better than linode!'


def main():
    result = defaultdict(list)
    for i in xrange(3):
        for addr in re.findall(ur'ipv4.speedtest-[^.]*.digitalocean.com',
                               requests.get(index).text):
            result[addr].append(test_speed(addr))
    report(result)


if __name__ == '__main__':
    main()
