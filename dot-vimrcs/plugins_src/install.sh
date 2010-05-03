#!/usr/bin/env bash

PLUGINSRCDIR=$HOME/.vimrcs/plugins_src
TMPDIR="/tmp/installvimscripts$$.dir"

mkdir -p $HOME/.vim/{after/syntax,doc,syntax,plugin}

cp $PLUGINSRCDIR/*.vim $HOME/.vim/plugin
cp -f $PLUGINSRCDIR/motemen-git-vim-cb110a2/plugin/git.vim \
	$HOME/.vim/plugin
cp -f $PLUGINSRCDIR/motemen-git-vim-cb110a2/syntax/*.vim \
	$HOME/.vim/syntax
for i in ColorSamplerPack.zip NERD_commenter.zip omnicppcomplete-0.41.zip \
	bufexplorer.zip vst.zip snipMate.zip manpageview.zip
do
	yes|unzip $PLUGINSRCDIR/$i -d $HOME/.vim >/dev/null
done

mkdir -p $TMPDIR
for i in crefvim.zip vim2ansi.v1.2.zip
do
	yes|unzip $PLUGINSRCDIR/$i -d $TMPDIR >/dev/null
done

mv -f $TMPDIR/crefvim/after/syntax/* $HOME/.vim/after/syntax/
mv -f $TMPDIR/crefvim/plugin/* $HOME/.vim/plugin/
mv -f $TMPDIR/crefvim/doc/* $HOME/.vim/doc/
mv -f $TMPDIR/vim2ansi/plugin/* $HOME/.vim/plugin/
mv -f $TMPDIR/vim2ansi/syntax/* $HOME/.vim/syntax/
if type -a fromdos &> /dev/null; then
	fromdos $HOME/.vim/plugin/toansi.vim > /dev/null
else
	dos2unix $HOME/.vim/plugin/toansi.vim > /dev/null
fi
rm -rf $TMPDIR

mkdir -p $HOME/.vim/ftplugin
cd $HOME/.vim/ftplugin
for i in `ls $HOME/.vimrcs/ftplugins/`
do
	rm -f $HOME/.vim/ftplugin/$i
	ln -s $HOME/.vimrcs/ftplugins/$i .
done
for i in `ls $HOME/.vimrcs/snippets/`
do
	rm -f $HOME/.vim/snippets/$i
	ln -s $HOME/.vimrcs/snippets/$i $HOME/.vim/snippets/$i
done
