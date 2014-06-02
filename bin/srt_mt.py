#!/usr/bin/env python
# coding=utf-8

import sys
import re
from datetime import datetime, timedelta


T_RE = re.compile(r'^(\d{2}:\d{2}:\d{2},\d{3})\s*-->\s*(\d{2}:\d{2}:\d{2},\d{3})$')
D = datetime(2000, 1, 1, 0, 0, 0)


class InvalidTime(Exception):
    '''invalid converted time'''


def from_subtitle_time(time):
    '''
    >>> from_subtitle_time('00:00:00,000')
    datetime.datetime(2000, 1, 1, 0, 0)
    >>> from_subtitle_time('01:02:03,456')
    datetime.datetime(2000, 1, 1, 1, 2, 3, 456000)
    '''
    s, ms = time.split(',', 1)
    return datetime.strptime('2000-01-01 ' + s, '%Y-%m-%d %H:%M:%S') + timedelta(0, 0, int(ms[:3]) * 1000)


def to_subtitle_time(time):
    '''
    >>> to_subtitle_time(datetime(2000, 1, 1, 0, 0, 0))
    '00:00:00,000'
    >>> to_subtitle_time(datetime(2000, 1, 1, 1, 2, 3, 456789))
    '01:02:03,456'
    >>> to_subtitle_time(datetime(1999, 1, 1, 0, 0, 0))
    Traceback (most recent call last):
    InvalidTime
    '''
    if time < D:
        raise InvalidTime
    return time.strftime('%H:%M:%S,') + ('%03d' % (time.microsecond / 1000))


def mv_time(line, delta):
    m = T_RE.match(line)
    if m is None:
        return line
    t1, t2 = m.groups()
    return '%s --> %s' % (to_subtitle_time(from_subtitle_time(t1) + delta), to_subtitle_time(from_subtitle_time(t2) + delta))


def srt_mt(lines, seconds):
    '''
    >>> list(srt_mt(['00:00:00,000 --> 00:00:01,000', 'line1', ''], 1.5))
    ['00:00:01,500 --> 00:00:02,500', 'line1', '']
    >>> list(srt_mt(['00:00:00,000 --> 00:00:01,000', 'line1', '', 'foo'], -1.5))
    ['foo']
    >>> list(srt_mt(['00:00:00,000 --> 00:00:01,000', 'line1', 'line2', ' ', 'foo'], -1.5))
    ['foo']
    '''
    lines = iter(lines)
    delta = timedelta(seconds=seconds)
    while True:
        try:
            yield mv_time(lines.next(), delta)
        except InvalidTime:
            # bypass the next non-empty lines if current time is invalid
            while lines.next().strip():
                pass


def usage():
    print '''Usage: %s filename seconds''' % sys.argv[0]
    sys.exit(1)


def main():
    if len(sys.argv) != 3:
        usage()
    filename, delta = sys.argv[1:3]
    with open(filename) as f:
        content = f.read()
    delta = float(delta)
    adjusted = '\n'.join(srt_mt(content.splitlines(), delta))
    with open(filename, 'wb') as f:
        f.write(adjusted)


if __name__ == '__main__':
    main()
