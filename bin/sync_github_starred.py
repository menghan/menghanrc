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


def iter_repos(link):
    while True:
        response = requests.get(link)
        for repo in response.json():
            yield repo
        links = dict([map(str.strip, reversed(segment.split(';'))) for segment in response.headers['link'].split(',')])
        if 'rel="next"' not in links:
            break
        link = links['rel="next"'].strip('<>')


def clone_repo(repo, fetched):
    repo_name = repo['full_name']
    if not os.path.exists(repo_name):
        if repo_name in fetched:
            return
        logger.info('Cloning repository \'%s\'', repo_name)
        subprocess.check_call(['git', 'clone', repo['clone_url'], repo_name],
                              stdout=open(os.devnull, 'wb'), stderr=open(os.devnull, 'wb'))
        fetched.add(repo_name)


def main():
    args = parse_args()
    if args.dir:
        os.chdir(args.dir)
    logger.info('use %s as working directory', os.environ['PWD'])
    try:
        fetched = set(map(str.strip, open('.synced')))
    except IOError:
        fetched = set()
    for repo in iter_repos('https://api.github.com/users/%s/starred' % args.username):
        clone_repo(repo, fetched)
    with open('.synced', 'wb') as f:
        for repo_name in fetched:
            f.write('%s\n' % repo_name)


if __name__ == '__main__':
    main()
