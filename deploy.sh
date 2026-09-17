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
    # the plain copy below would overwrite authorized_keys: keep the keys the
    # target already grants, or a deploy locks out every other machine
    GRANTED=/tmp/tmp.zo2xJ6lACI
    cat ~/.ssh/authorized_keys 2>/dev/null > $GRANTED

    ls home | while read file
    do
        cp -TvR home/$file ~/.$file
    done

    cat $GRANTED > ~/.ssh/authorized_keys
    grep -qxFf home/ssh/authorized_keys $GRANTED \
        || cat home/ssh/authorized_keys >> ~/.ssh/authorized_keys
    rm -f $GRANTED

    # ssh ignores a config, a key or an authorized_keys the group can write,
    # and the 002 umask of a fresh clone makes every copied file group-writable
    chmod 700 ~/.ssh
    find ~/.ssh -maxdepth 1 -type f -exec chmod 600 {} +
}

deploy
