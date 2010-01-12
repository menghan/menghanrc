#!/usr/bin/env bash

. install-common.sh

GITSRC=http://kernel.org/pub/software/scm/git/git-1.6.6.tar.bz2
SOFTSRC=$GITSRC

TARFILE=${SOFTSRC##*\/}
DIRNAME=${TARFILE%.tar.bz2}
rm -f $TARFILE
download_or_exit $SOFTSRC
tar xf $TARFILE && cd ${DIRNAME} && ./configure && make && sudo make install
rm -rf ${DIRNAME}
