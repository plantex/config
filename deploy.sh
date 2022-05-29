#!/bin/bash


TMP=`dirname $0`
GIT_REPO=`readlink -m $TMP`
GIT_HOME=$GIT_REPO/home

symlink() {
    if [ $# -ne 1 ]
    then
        exit
    fi
    local PATH_FROM_HOME=$1
    local CURRENT_DIR=`readlink -m $GIT_HOME/$PATH_FROM_HOME`
    local MY_HOME=`readlink -m $HOME/$PATH_FROM_HOME`
    for file in `ls -A $CURRENT_DIR`
    do
        if [ -d $CURRENT_DIR/$file ]
        then
            symlink $PATH_FROM_HOME/$file
        else
            if [ -f $MY_HOME/$file ] && [ ! -h $MY_HOME/$file ]
            then
                mv $MY_HOME/$file $MY_HOME/$file.bak
            fi
            ln -sf $CURRENT_DIR/$file $MY_HOME/$file
            ls -lh $MY_HOME/$file
        fi
    done
}

deploy() {
    ls home | while read file
    do
        cp -Tva home/$file ~/.$file
    done
}

symlink .
