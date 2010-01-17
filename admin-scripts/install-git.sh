#!/usr/bin/env bash

INSTALLPREFIX=/usr/local
WGET="wget -q"
GITSRC=http://kernel.org/pub/software/scm/git/git-1.6.6.tar.bz2
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
mkdir -p ${HOME}/codespace && cd ${HOME}/codespace
if ! test $?; then
	exit 1
fi
git clone http://github.com/thuskyblue/menghanrc.git
