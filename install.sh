#!/bin/bash

# refer  spf13-vim bootstrap.sh`
BASEDIR=$(dirname $0)
cd $BASEDIR
CURRENT_DIR=`pwd`

lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi
}

echo "Step1: backing up current vim config"
today=`date +%Y%m%d`
for i in $HOME/.vim $HOME/.vimrc $HOME/.gvimrc $HOME/.vimrc.bundles; do [ -e $i ] && [ ! -L $i ] && mv $i $i.$today; done
for i in $HOME/.vim $HOME/.vimrc $HOME/.gvimrc $HOME/.vimrc.bundles; do [ -L $i ] && unlink $i ; done


echo "Step2: setting up symlinks"
lnif $CURRENT_DIR/vimrc $HOME/.vimrc
lnif $CURRENT_DIR/vimrc.bundles $HOME/.vimrc.bundles
lnif "$CURRENT_DIR/" "$HOME/.vim"

echo "Step3: install vundle"
if [ ! -e $CURRENT_DIR/bundle/Vundle.vim ]; then
    echo "Installing Vundle"
    git clone https://github.com/VundleVim/Vundle.Vim $CURRENT_DIR/bundle/Vundle.vim
else
    echo "Upgrade Vundle"
    cd "$HOME/.vim/bundle/Vundle.vim" && git pull origin master
fi

echo "Step4: update/install plugins using Vundle"
system_shell=$SHELL
export SHELL="/bin/sh"
vim -u $HOME/.vimrc.bundles +BundleInstall! +BundleClean +qall
export SHELL=$system_shell


echo "Step5: compile YouCompleteMe"
echo "It will take a long time, just be patient!"
echo "If error,you need to compile it yourself"
echo "cd $CURRENT_DIR/bundle/YouCompleteMe/ && bash -x install.sh --clang-completer"
cd $CURRENT_DIR/bundle/YouCompleteMe/

if [ `which clang` ]   # check system clang
then
    ./install.py --clang-completer
    # bash -x install.sh --clang-completer --system-libclang   # use system clang
else
    ./install.py --clang-completer
    # bash -x install.sh --clang-completer
fi


echo "Install Done!"
