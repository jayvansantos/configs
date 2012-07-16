# env
export EDITOR=vim
export PAGER=less
export LANG=en_US.UTF-8
export LC_CTYPE=$LANG
export PATH="${PATH}:${HOME}/bin"

# init console colors
if [[ $TERM = linux* ]]; then
    python $HOME/.zsh.d/init_linux_console_colors.py
fi

# includes
source $HOME/.zsh.d/key-bindings.zsh
source $HOME/.zsh.d/termsupport.zsh
source $HOME/.zsh.d/ssh-agent.zsh
# battery status
BATTERY=BAT0
source $HOME/.zsh.d/battery.zsh


# history options
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_space 
setopt hist_ignore_dups
setopt hist_expire_dups_first
setopt extended_history
setopt hist_verify
setopt append_history


# various options
setopt extended_glob
setopt extendedglob
setopt interactive_comments
setopt nomatch
setopt notify
setopt no_beep
setopt multios
setopt long_list_jobs
unsetopt flow_control
WORDCHARS=''

if [ $(id -u) -ne 0 ]; then
    _SUDO='sudo'
fi

# edit command line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line


# smart urls
autoload -U url-quote-magic
zle -N self-insert url-quote-magic


# directories
setopt auto_name_dirs
setopt auto_pushd
setopt pushd_ignore_dups


# keyboard
autoload zkbd
function _zkbd_file() {
    [[ -f $HOME/.zsh.d/zkbd/${TERM}-${VENDOR}-${OSTYPE} ]] && printf '%s' $HOME/".zsh.d/zkbd/${TERM}-${VENDOR}-${OSTYPE}" && return 0
    [[ -f $HOME/.zsh.d/zkbd/${TERM} ]] && printf '%s' $HOME/".zsh.d/zkbd/${TERM}" && return 0
    return 1
}

[[ ! -d $HOME/.zsh.d/zkbd ]] && mkdir $HOME/.zsh.d/zkbd
_keyfile=$(_zkbd_file)
_ret=$?
if [[ ${ret} -ne 0 ]]; then
    zkbd
    _keyfile=$(_zkbd_file)
    _ret=$?
fi
if [[ ${_ret} -eq 0 ]] ; then
    source "${_keyfile}"
else
    printf 'Failed to setup keys using zkbd.\n'
fi
unfunction _zkbd_file; unset _keyfile _ret

[[ -n "${key[Home]}" ]]     && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}" ]]      && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}" ]]   && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}" ]]   && bindkey  "${key[Delete]}"  delete-char
[[ -n "${key[Up]}" ]]       && bindkey  "${key[Up]}"      up-line-or-history
[[ -n "${key[Down]}" ]]     && bindkey  "${key[Down]}"    down-line-or-history
[[ -n "${key[Left]}" ]]     && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[Right]}" ]]    && bindkey  "${key[Right]}"   forward-char
[[ -n "${key[CtrlLeft]}" ]] && bindkey  "${key[CtrlLeft]}"    backward-word
[[ -n "${key[CtrlRight]}" ]]  && bindkey  "${key[CtrlRight]}"   forward-word


# completion
zmodload zsh/complist
autoload -U compinit && compinit
unsetopt menu_complete
setopt auto_menu
setopt always_to_end
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*' # case-insensitive
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path $HOME/.zcache
# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
        dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
        hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
        mailman mailnull mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
        operator pcap postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs


# colors
autoload -U colors && colors
export LS_COLORS='no=01;32:fi=00:di=00;34:ln=01;36:pi=04;33:so=01;35:bd=33;04:cd=33;04:or=31;01:ex=01;32:*.rtf=00;33:*.txt=00;33:*.html=00;33:*.doc=00;33:*.pdf=00;33:*.ps=00;33:*.sit=00;31:*.hqx=00;31:*.bin=00;31:*.tar=00;31:*.tgz=00;31:*.arj=00;31:*.taz=00;31:*.lzh=00;31:*.zip=00;31:*.z=00;31:*.Z=00;31:*.gz=00;31:*.deb=00;31:*.dmg=00;36:*.jpg=00;35:*.gif=00;35:*.bmp=00;35:*.ppm=00;35:*.tga=00;35:*.xbm=00;35:*.xpm=00;35:*.tif=00;35:*.mpg=00;37:*.avi=00;37:*.gl=00;37:*.dl=00;37:*.mov=00;37:*.mp3=00;35:'
export GREP_COLOR='1;31'

# git info
_git_prompt_info() {
    local _hash=$(git show -s --pretty=format:%h HEAD 2> /dev/null)
    [ $_hash ] || return
    local _name=$(git symbolic-ref --short HEAD 2> /dev/null)
    if [[ -z $_name ]]; then
        _name=$(git show -s --pretty=format:%d HEAD 2> /dev/null | awk '{print $2}')
        _name="${_name%,*}"
        _name="${_name%)*}"
    fi
    [ $_name ] && _name="$_name "
    echo -n "%{$fg_bold[red]%}${_name}[${_hash}]%{$reset_color%}"
}


# theme
setopt prompt_subst
PROMPT='%{$fg[blue]%}[%D{%d/%m/%y} %T]%{$reset_color%} %(!.%{$fg_bold[red]%}.%{$fg_bold[green]%}%n@)%m%{$reset_color%} %{$fg[magenta]%}[%(!.%1~.%~)]%{$reset_color%} $(_git_prompt_info)
%{$fg[red]%}>>%{$reset_color%} '
RPROMPT='$(_battery_status)'


# aliases
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias uhalt='dbus-send --system --print-reply --dest=org.freedesktop.ConsoleKit /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop'
alias ureboot='dbus-send --system --print-reply --dest=org.freedesktop.ConsoleKit /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Restart'
alias enable_bluetooth='rfkill unblock $(rfkill list | grep -m 1 Bluetooth | cut -b 1)'
alias disable_bluetooth='rfkill block $(rfkill list | grep -m 1 Bluetooth | cut -b 1)'
alias emacs='emacs -nw'
alias kismet='TERM=rxvt-unicode kismet'
alias mendeleydesktop='mendeleydesktop --force-bundled-qt'
alias arm-none-linux-gnueabi-gdb='arm-none-linux-gnueabi-gdb -nx -x ${HOME}/.gdbinit.arm'
alias arm-none-eabi-gdb='arm-none-eabi-gdb -nx -x ${HOME}/.gdbinit.arm'
alias openocd-panda='${_SUDO} openocd -f /usr/share/openocd/scripts/interface/flyswatter2.cfg -f /usr/share/openocd/scripts/board/ti_pandaboard.cfg'

# special ncmpcpp
alias _ncmpcpp="$(which ncmpcpp)"
ncmpcpp() {
    local _color6
    local _color14

    # change the cyan to black (#4d4d4d rgb)
    if [[ $TERM = linux* ]]; then
        echo -en "\e]P64d4d4d"
        echo -en "\e]PE4d4d4d"
    elif [[ $TERM = screen* ]]; then
        # screen and tmux don't support color changing
    else
        # backup cyan rgb
        _color6=$(python $HOME/.zsh.d/get_term_rgb_color.py 6)
        _color14=$(python $HOME/.zsh.d/get_term_rgb_color.py 14)
        # fallback values for cyan
        [[ $_color6 != rgb:* ]] && _color6='rgb:0000/cdcd/cdcd'
        [[ $_color14 != rgb:* ]] && _color14='rgb:0000/ffff/ffff'
        # change cyan to black
        echo -en '\e]4;6;rgb:4d4d/4d4d/4d4d\e\'
        echo -en '\e]4;14;rgb:4d4d/4d4d/4d4d\e\'
    fi

    _ncmpcpp "$@"

    if [[ $TERM = linux* ]]; then
        # reset colors
        clear
        echo -en '\e]R'
    elif [[ $TERM = screen* ]]; then
    else
        # restore cyan rgb
        echo -en "\\e]4;6;${_color6}\\e\\"
        echo -en "\\e]4;14;${_color14}\\e\\"
    fi
}

chpixelsize() {
    stty -echo
    printf '\33]50;%s\007' xft:Inconsolata:pixelsize=$1
    stty echo
}

image_music_video() {
    if [ $# -ne 2 ]; then
        echo "usage: image_music_video <image> <audio>"
        return 1
    fi

    local _IMG=$1
    local _AUD=$2
    local _TMP_IMG=$(mktemp --suffix=.${_IMG##*.})
    cp ${_IMG} ${_TMP_IMG}
    mogrify -resize 1920x1080 -background black -gravity center -extent 1920x1080 ${_TMP_IMG}
    ffmpeg -loop_input -i ${_TMP_IMG} -i ${_AUD} -shortest -strict experimental -s hd1080 -acodec copy -vcodec libx264 -pix_fmt rgba ${_AUD%.*}.mp4
    rm -f ${_TMP_IMG}
}

wpa_dhcp() {
    if [ $# -ne 3 ]; then
        echo "usage: wpa_dhcp <interface> <essid> <passphrase>"
        return 1
    fi

    $_SUDO iwconfig $1 channel auto || return $?

    local _tmp_conf=$(mktemp --suffix=.conf)
    wpa_passphrase $2 $3 > $_tmp_conf
    local _ret=$?
    if [ $_ret -ne 0 ]; then
        cat $_tmp_conf
        rm -f $_tmp_conf
        return $_ret
    fi

    $_SUDO wpa_supplicant -B -Dwext -i $1 -c $_tmp_conf
    _ret=$?
    rm -f $_tmp_conf
    if [ $_ret -ne 0 ]; then
        return $_ret
    fi

    $_SUDO dhcpcd $1
    return $?
}

wep_dhcp() {
    if [ $# -ne 3 ]; then
        echo "usage: wep_dhcp <interface> <essid> <passphrase>"
        return 1
    fi

    $_SUDO iwconfig $1 channel auto || return $?
    $_SUDO iwconfig $1 essid $2 key $3 || return $?
    $_SUDO dhcpcd $1
    return $?
}

open_dhcp() {
    if [ $# -ne 2 ]; then
        echo "usage: open_dhcp <interface> <essid>"
        return 1
    fi

    $_SUDO iwconfig $1 channel auto || return $?
    $_SUDO iwconfig $1 essid $2|| return $?
    $_SUDO dhcpcd $1
    return $?
}

wifi_scan() {
    if [ $# -ne 1 ]; then
        echo "usage: wifi_scan <interface>"
        return 1
    fi

    $_SUDO iwconfig $1 channel auto || return $?
    $_SUDO iwlist $1 scan
    return $?
}

alias _udisks="$(which udisks)"
udisks() {
    for x in $*; do
        if [ $x = "--unmount" ]; then
            sync
            break
        fi
    done
    _udisks $*
}

embed_subtitle() {
    if [ $# -lt 3 ]; then
        echo "usage: embed_subtitle <video> <subtitle> [ffmpeg options] <output>"
        return 1
    fi

    if [ ! -e $1 ]; then
        echo "file $1 does not exists!"
        return 1
    fi

    if [ ! -e $2 ]; then
        echo "file $2 does not exists!"
        return 1
    fi

    local _VIDRAND_F=$(mktemp -u --suffix=.mp4)
    local _SOUNDRAND_F=$(mktemp -u --suffix=.wav)

    mkfifo $_VIDRAND_F
    mkfifo $_SOUNDRAND_F

    (mplayer -benchmark -really-quiet -sub $2 -noframedrop -nosound -vo yuv4mpeg:file=${_VIDRAND_F} $1 -osdlevel 0 &) > /dev/null 2>&1
    (mplayer -benchmark -really-quiet -noframedrop -ao pcm:file=${_SOUNDRAND_F} -novideo $1 &) > /dev/null 2>&1
    sleep 2
    ffmpeg -i $_VIDRAND_F -i $_SOUNDRAND_F -isync ${*:3}

    rm -f $_VIDRAND_F $_SOUNDRAND_F
}

mkmagnettorrent() {
    local _torhash
    local _torfile

    if [ $# -lt 1 ]; then
        echo "usage: mkmagnettorrent \"MAGET_URI\""
        return 1
    fi

    [[ "$1" =~ "xt=urn:btih:([^&/]+)" ]] || exit
    _torhash=${match[1]}
    if [[ "$1" =~ "dn=([^&/]+)" ]]; then
        _torfile=${match[1]}
    else
        _torfile=$_torhash
    fi

    echo "d10:magnet-uri${#1}:${1}e" > "meta-${_torfile}.torrent"
}
