#!/usr/bin/env python
# coding=utf-8

import sys
import re
import time
import logging
from collections import defaultdict

import sh
import requests

using = 'vjp2'
using_loc = 'hnd-jp-ping.vultr.com'
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
re_near = re.compile('(jp|sgp|japan|singapore|tokyo)')


def test_speed(addr):
    report = sh.mtr(addr, '--report')
    for line in reversed(map(unicode.strip, report.splitlines())):
        if line:
            break
    # 18.|-- speedtest.frankfurt.linod  0.0%     9  161.4 184.5 160.0 321.3  52.0
    segs = line.split()
    loss, avg, std, worst = float(segs[-7].rstrip('%')), float(segs[-4]), float(segs[-1]), float(segs[-2])
    return loss, avg, std, worst


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


def get_test_addresses(need_total=False):
    yield using
    for provider, config in providers.iteritems():
        index, reobj = config['index'], config['re']
        for retry in xrange(3):
            try:
                for addr in set(reobj.findall(requests.get(index).text)):
                    if need_total or re_near.search(addr):
                        yield addr
            except Exception as e:
                logging.warn('parse index %s failed: %s', index, e)
            else:
                break


def compare_mtr_result_key(result):
    addr, loss, avg, std, worst = result
    return [loss, (avg * 3 + worst) * std]


def main():
    need_total = '--total' in sys.argv
    results = []
    for i in xrange(3):
        for addr in get_test_addresses(need_total):
            logging.debug('testing %s ...', addr)
            try:
                loss, avg, std, worst = test_speed(addr)
            except Exception as e:
                logging.warn('test %s failed: %s', addr, e)
                continue
            logging.warn('test %s done. loss: %s, avg(std): %s(%s), worst: %s', addr.rjust(35), loss, avg, std, worst)
            results.append((addr, loss, avg, std, worst))
    
    if not results:
        logging.warn('all tests failed')
        return
    results.sort(key=compare_mtr_result_key)
    best_result = results[0]
    best_addr = best_result[0]
    if best_addr in (using, using_loc):
        print 'You\'re using best locations!'
        print '%s(%s): loss: %s, avg(std): %s(%s), worst: %s' % ((using, using_loc) + best_result[1:])
    else:
        print 'You may consider a better location!'
        try:
            curr_result = filter(lambda r: r[0] == using, results)[0]
        except IndexError:
            print 'Your location test failed'
        else:
            print 'Your location %s: loss: %s, avg(std): %s(%s), worst: %s' % ((using.rjust(35),) + curr_result[1:])
        print 'Best location %s: loss: %s, avg(std): %s(%s), worst: %s' % ((best_addr.rjust(35),) + best_result[1:])
        sys.exit(1)


if __name__ == '__main__':
    main()
