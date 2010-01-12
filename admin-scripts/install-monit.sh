#!/usr/bin/env bash

. install-common.sh

# TODO: depend flex ssl
MONITSRC="http://mmonit.com/monit/dist/monit-5.0.3.tar.gz"
SOFTSRC=$MONITSRC

TARFILE=${SOFTSRC##*\/}
DIRNAME=${TARFILE%.tar.gz}
rm -f $TARFILE
download_or_exit $SOFTSRC
tar xf $TARFILE && cd ${DIRNAME} && ./configure --prefix=${INSTALLPREFIX} && make && sudo make install
# rm -rf ${DIRNAME}
