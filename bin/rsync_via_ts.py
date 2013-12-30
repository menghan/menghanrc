#!/usr/bin/env python
# coding=utf-8

'''rsync like command tool to copy file from tsclient'''

import os
import re
import shutil
import win32api
import logging as log
import ConfigParser

log.basicConfig(level=log.INFO, format='%(asctime)s %(message)s')

config = ConfigParser.RawConfigParser()
_default_configuration = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    '_rsync_config.ini')
config.read(_default_configuration)
_tsroot = '\\\\tsclient'
_false_overwrite = config.getboolean('DEFAULT', 'force_overwrite')
_client_source_root = config.get('DEFAULT', 'client_source_root')
_ignore_dirlist = ['.git', '.hg', '.svn']
_ignore_dirlist.extend(
    [x for x in config.get('DEFAULT', 'ignore_dirlist').split(';') if x])
_ignore_filepattern_list = [re.compile('\.swp$'), re.compile('\.pyc$')]
_ignore_filepattern_list.extend(
    [re.compile(x) for x in
     config.get('DEFAULT', 'ignore_filepattern_list').split(';') if x])
_alias_name = config.get('DEFAULT', 'alias').strip() or None


def copy_file(src, dst, force=_false_overwrite):
    do_copy = force
    if do_copy:
        log.debug('FORCE: copy \'%s\' to \'%s\'', src, dst)
    if not do_copy and not os.path.exists(dst):
        do_copy = True
        log.debug('DEST NOT EXIST: copy \'%s\' to \'%s\'', src, dst)
    if not do_copy:
        src_mtime = os.stat(src).st_mtime
        dst_mtime = os.stat(dst).st_mtime
        if src_mtime > dst_mtime:
            log.debug('SOURCE IS NEWER: copy \'%s\' to \'%s\'', src, dst)
            do_copy = True
    if do_copy:
        log.info('{0}{1}  -->{0}{2}{0}'.format(os.linesep, src, dst))
        shutil.copyfile(src, dst)


def rsync_dir(src_dir, dst_dir):
    for dirpath, dirnames, filenames in os.walk(src_dir):
        for i in _ignore_dirlist:
            if i in dirnames:
                dirnames.remove(i)
        related_path = dirpath[len(src_dir):].lstrip(os.sep)
        for filename in filenames:
            for i in _ignore_filepattern_list:
                if re.search(i, filename):
                    break
            else:
                copy_file(os.path.join(dirpath, filename),
                          os.path.join(dst_dir, related_path, filename))


def to_unicode(message):
    try:
        message = message.decode('gbk', 'ignore')
    except:
        try:
            message = message.decode('utf-8', 'ignore')
        except:
            pass
    return message


def main():
    in_graph = False
    cur_path = os.getcwd()
    # if runned by right click menu, then set cur_path to file's dir
    if cur_path in win32api.GetSystemDirectory():
        cur_path = os.path.dirname(os.path.abspath(__file__))
        in_graph = True
    log.debug('cur_path = %s', to_unicode(cur_path))
    if _alias_name is None:
        tsclient_path = os.path.join(_tsroot,
                                     _client_source_root.replace(':', ''),
                                     os.path.basename(cur_path))
    else:
        tsclient_path = os.path.join(_tsroot,
                                     _client_source_root.replace(':', ''),
                                     _alias_name)
    log.debug('tsclient_path = %s', to_unicode(tsclient_path))
    rsync_dir(tsclient_path, cur_path)
    if in_graph:
        print 'exit ok'
        raw_input('')


if __name__ == '__main__':
    main()
