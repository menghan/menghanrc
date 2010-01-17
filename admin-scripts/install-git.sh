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
rm -f $HOME/.bashrc.basic && ln -s $HOME/codespace/menghanrc/bashrcs/bashrc.basic $HOME/.bashrc.basic
rm -f $HOME/.bashrc.aliases && ln -s $HOME/codespace/menghanrc/bashrcs/bashrc.aliases $HOME/.bashrc.aliases
if ! grep -q '.bashrc.basic' ~/.bashrc; then
	echo "source ~/.bashrc.basic" >> ~/.bashrc
fi
if ! grep -q '.bashrc.aliases' ~/.bashrc; then
	echo "source ~/.bashrc.aliases" >> ~/.bashrc
fi
rm -f $HOME/.screenrc && ln -s $HOME/codespace/menghanrc/dot-screenrc $HOME/.screenrc
rm -f $HOME/.vimrc && ln -s $HOME/codespace/menghanrc/dot-vimrc $HOME/.vimrc
rm -f $HOME/.vimrcs && ln -s $HOME/codespace/menghanrc/dot-vimrcs $HOME/.vimrcs
cd $HOME/.vimrcs/plugins_src && ./install.sh
