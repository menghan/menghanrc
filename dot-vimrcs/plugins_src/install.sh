#!/usr/bin/env bash

PLUGINSRCDIR=~/.vimrcs/plugins_src
TMPDIR="/tmp/installvimscripts$$.dir"

mkdir -p ~/.vim/{after/syntax,doc,syntax,plugin}

cp $PLUGINSRCDIR/*.vim ~/.vim/plugin
for i in ColorSamplerPack.zip NERD_commenter.zip omnicppcomplete-0.41.zip \
	bufexplorer.zip vst.zip snipMate.zip
do
	yes|unzip $PLUGINSRCDIR/$i -d ~/.vim >/dev/null
done

mkdir -p $TMPDIR
for i in crefvim.zip vim2ansi.v1.2.zip
do
	yes|unzip $PLUGINSRCDIR/$i -d $TMPDIR >/dev/null
done

mv -f $TMPDIR/crefvim/after/syntax/* ~/.vim/after/syntax/
mv -f $TMPDIR/crefvim/plugin/* ~/.vim/plugin/
mv -f $TMPDIR/crefvim/doc/* ~/.vim/doc/
mv -f $TMPDIR/vim2ansi/plugin/* ~/.vim/plugin/
mv -f $TMPDIR/vim2ansi/syntax/* ~/.vim/syntax/
dos2unix ~/.vim/plugin/toansi.vim > /dev/null
fromdos ~/.vim/plugin/toansi.vim > /dev/null
rm -rf $TMPDIR

mkdir -p ~/.vim/ftplugin
cd ~/.vim/ftplugin
for i in `ls ~/.vimrcs/ftplugins/`
do
	rm -f ~/.vim/ftplugin/$i
	ln -s ~/.vimrcs/ftplugins/$i .
done
for i in `ls ~/.vimrcs/snippets/`
do
	rm -f ~/.vim/snippets/$i
	ln -s $HOME/.vimrcs/snippets/$i $HOME/.vim/snippets/$i
done
