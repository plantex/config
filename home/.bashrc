# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[01;31m\]\$\[\033[00m\] '
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[01;31m\]>\[\033[00m\] '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# My functions

vimo() {
    vim -O $1c $1h;
}

ssh-shadow() {
    if [ -z $1 ]
    then
        echo ssh-shadow boxIP [cmd]
    else
        ssh-keygen -f "/home/plantex/.ssh/known_hosts" -R $1
        echo 'killall ClientSDL'
        echo 'SHADOW_BRANCH= DISPLAY=:0 nohup run-shadow 2>&1 > /dev/null &'
        echo 'DISPLAY=:0 run-shadow -- --log-level=debug'
        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$1
    fi
}

rem() {
    if [ $# -eq 3 ]
    then
        _DC=$1
        _HOSTNAME_OR_IP=$2
        _SLOT=$3
        sed "s/__DC__/$_DC/g" ~/.local/share/remmina/.prod-template > /tmp/vnc.remmina
    elif [ $# -eq 2 ]
    then
        _HOSTNAME_OR_IP=$1
        _SLOT=$2
        cp ~/.local/share/remmina/.gcp-template /tmp/vnc.remmina
    else
        echo usage: rem [dc] hostname slot
        return 1
    fi
    _IP=`echo $_HOSTNAME_OR_IP | sed 's/sh-//g' | sed 's/-/./g'`
    sed -i "s/__HOSTNAME__/$_IP/g" /tmp/vnc.remmina
    sed -i "s/__SLOT__/$_SLOT/g" /tmp/vnc.remmina
    remmina -c /tmp/vnc.remmina
    sleep 0.5s
    rm /tmp/vnc.remmina
}

githelp() {
    echo 'add / change / deprecated / remove / fix / security / doc'
}

getscreen() {
    if [ $# -gt 2 ]
    then
        echo 'getscreen [ [SERVER(sh-XXX-XX-XX-XXX)] SLOT]'
        return
    fi
    SERVER=$1
    SLOT=$2
    IP=`echo $SERVER | sed 's/-/./g' | cut -d'.' -f 2-`

    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -AX -l blade $IP 'echo -en "screendump /tmp/screen-1\r" > `cat /tmp/vm.'${SLOT}'.pty` ; read < `cat /tmp/vm.'${SLOT}'.pty`'
    scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no blade@${IP}:/tmp/screen-1 /tmp/screen-1
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -AX -l blade $IP 'echo -en "screendump /tmp/screen-2\r" > `cat /tmp/vm.'${SLOT}'.pty` ; read < `cat /tmp/vm.'${SLOT}'.pty`'
    scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no blade@${IP}:/tmp/screen-2 /tmp/screen-2
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -AX -l blade $IP 'rm /tmp/screen-1 /tmp/screen-2'
    feh /tmp/screen-1 /tmp/screen-2
    rm /tmp/screen-1 /tmp/screen-2
}

multi-ssh() {
    if [ $# -ne 2 ]
    then
        echo 'parallele-ssh SERVER.list "COMMAND"'
        return
    fi
    LIST=$1

    cat $LIST | while read server
    do
        ssh -l blade $server -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ConnectTimeout=2 "$2" < /dev/null 2>/dev/null
    done
}

# My Aliases

alias jao='pad 0; source /home/jao/.bashrc; sudo -u jao -i; pad 1; source ~/.bashrc'
alias commit='git commit -m'
alias push='git push'
alias status='git config --global user.name;git config --global user.email;git status'
alias gitlg='git log --decorate --oneline --all --graph'
alias TODO='clear; cat TODO'
alias README='clear; cat README'
alias gcc='gcc -Wall -Wextra -Werror -pedantic -std=c99'
alias g++='g++ -Wall -Wextra -Werror -pedantic -std=c++1y'
alias vimo='vimo'
alias dual-screen='xrandr --output HDMI1 --mode 1920x1080 --rate 60 --left-of eDP1'
alias pad='xinput set-prop 14 "Device Enabled"'
alias pokemon='./Téléchargements/PROLinux.x86_64 &'
alias mountShareDir='sudo mount -t cifs //192.168.0.50/share ~/Share/'
alias touchpad-disable='xinput -disable "ETPS/2 Elantech Touchpad"'
alias touchpad-enable='xinput -enable "ETPS/2 Elantech Touchpad"'
alias touchscreen-disable='xinput -disable "USBest Technology SiS HID Touch Controller"'
alias touchscreen-enable='xinput -enable "USBest Technology SiS HID Touch Controller"'
#alias suspend='i3lock -i /home/plantex/Images/blade.png && sudo pm-suspend'

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/plantex/Downloads/google-cloud-sdk/path.bash.inc' ]; then . '/home/plantex/Downloads/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/plantex/Downloads/google-cloud-sdk/completion.bash.inc' ]; then . '/home/plantex/Downloads/google-cloud-sdk/completion.bash.inc'; fi
