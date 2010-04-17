#!/usr/bin/env bash


backup ()
{
	if [ ! -e "$1" ]; then
		return
	fi
	path=$(dirname "$1")
	node=$(basename "$1")
	mv "$1" "$path"/"$node"-$(LANG=C date +%F-%H-%M-%S)
}

setup ()
{
	from=$1
	target=$2

	if test -z $from -o -z $target; then
		return
	fi
	backup $HOME/$target
	rm -rf $HOME/$target
	ln -s $from $target
}

# install essential softwares..

sudo aptitude update
sudo aptitude install -y \
	git-core tig git-doc git-svn subversion \
	vim-gtk exuberant-ctags cscope vim-doc tofrodos \
	build-essential manpages manpages-dev \
	lftp apache2 openssh-server openssh-client \
	postfix procmail mutt \
	evince ibus ibus-table-extraphrase ibus-table-wubi im-switch conky \
	ntfs-3g pcmanx-gtk2 rdesktop \
	bash-completion unzip gawk less lsof screen sudo telnet wget

# get menghanrc
if [ -d $HOME/codespace/menghanrc ]; then
	backup $HOME/codespace/menghanrc
fi
mkdir -p $HOME/codespace && cd $HOME/codespace && git clone menghanrchost:.gitroot/menghanrc.git
if ! test $?; then
	exit 1
fi

# setup bash env
cd
if ! grep -q '.bashrc.basic' ~/.bashrc; then
	echo "source ~/.bashrc.basic" >> ~/.bashrc
fi
if ! grep -q '.bashrc.aliases' ~/.bashrc; then
	echo "source ~/.bashrc.aliases" >> ~/.bashrc
fi
if ! grep -q '.bashrc.local' ~/.bashrc; then
	cat >> ~/.bashrc << EOF
if [ -f ~/.bashrc.local ]; then
	source ~/.bashrc.local
fi
EOF
fi
setup codespace/menghanrc/bashrcs/bashrc.basic .bashrc.basic
setup codespace/menghanrc/bashrcs/bashrc.aliases .bashrc.aliases

# setup vim env
cd
setup codespace/menghanrc/dot-vimrc .vimrc
setup codespace/menghanrc/dot-vimrcs .vimrcs
cd $HOME/.vimrcs/plugins_src && ./install.sh

# setup git env
cd
setup codespace/menghanrc/dot-gitconfig .gitconfig

# setup screen env
cd
setup codespace/menghanrc/dot-screenrc .screenrc

# setup Xdefaults env
if grep -q 'Ubuntu' /etc/issue; then
	# ubuntu: don't use .Xdefaults
	:
else
	cd
	setup codespace/menghanrc/dot-Xdefaults .Xdefaults
fi

# setup python env
cd
setup codespace/menghanrc/dot-pythonstartup .pythonstartup

# setup fluxbox and fbpanel
cd
setup codespace/menghanrc/dot-fluxbox .fluxbox
setup codespace/menghanrc/dot-fbpanel .fbpanel
cd .fluxbox
cp -f init.example init

# setup mutt
cd
setup codespace/menghanrc/dot-mutt .mutt

# setup conky
cd
setup codespace/menghanrc/dot-conkys/dot-conkyrc .conkyrc

# setup toprc
cd
setup codespace/menghanrc/dot-toprc .toprc
