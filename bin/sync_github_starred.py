#!/usr/bin/env python
# coding=utf-8

import os
import sys
import requests
import argparse
import logging
import subprocess

logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())
logger.setLevel(logging.INFO)


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-u', '--username', required=True, dest='username',
                        help='who\'s starred repos you want to sync?')
    parser.add_argument('-d', '--dir', dest='dir', help='where to store the repos')

    args = parser.parse_args()
    return args


def main():
    args = parse_args()
    if args.dir:
        try:
            os.chdir(args.dir)
        except OSError as e:
            logger.error('chdir %s failed: %s', args.dir, e)
            sys.exit(-1)
    else:
        logger.info('use pwd %s as working directory', os.environ['PWD'])
    link = 'https://api.github.com/users/%s/starred' % args.username
    while True:
        response = requests.get(link)
        for repo in response.json():
            repo_name = repo['full_name']
            basename = repo_name.split('/')[1]
            if os.path.exists(basename):
                logger.info('directory %s exists, don\'t clone %s', basename, repo_name)
                continue
            logger.info('Cloning repo %s', repo_name)
            subprocess.call(['git', 'clone', repo['clone_url']])
        links = dict([map(str.strip, reversed(segment.split(';'))) for segment in response.headers['link'].split(',')])
        if 'rel="next"' not in links:
            break
        link = links['rel="next"'].strip('<>')


if __name__ == '__main__':
    main()
