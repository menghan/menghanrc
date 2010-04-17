#!/usr/bin/env bash

INSTALLPREFIX=/usr/local
WGET="wget -q"
GITSRC=http://kernel.org/pub/software/scm/git/git-1.7.0.5.tar.bz2
SOFTSRC=${GITSRC}

TARFILE=${SOFTSRC##*\/}
DIRNAME=${TARFILE%.tar.bz2}

if ! type -a git > /dev/null 2>&1 ; then
	if ! test -e ${TARFILE}; then
		if ! ${WGET} ${SOFTSRC}; then
			echo 'download failed'
			exit 1
		fi
	fi
	tar xf ${TARFILE} && cd ${DIRNAME} && ./configure && make && sudo make install
	rm -rf ${DIRNAME} ${TARFILE}
fi
