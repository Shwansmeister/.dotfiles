#
# ~/.bashrc
#

# if not running interactively, don't do anything
[[ $- != *i* ]] && return

#aliases
alias ls='lsd -lah --group-dirs=first'
alias lss='lsd -lahS --group-dirs=first'
alias lst='lsd -laht --group-dirs=first'
alias r='. ranger'
alias pussh='git push git@github.com:'
alias gitdot='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias vi='nvim'
alias cl='clear'
alias df='dfhack-run'

#options
set -o vi

# Environment Variables
export PATH="$PATH:$HOME/bin:$HOME/.local/bin:/usr/local/bin"
export EDITOR='nvim'
# export MANPAGER="bat"
# export MANPAGER="nvim -c 'set ft=man' -c 'Man' -"
export XDG_DATA_HOME="$HOME/.local/share/"
export XDG_CONFIG_HOME="$HOME/.config/"
export XDG_STATE_HOME="$HOME/.local/state/"
export XDG_CACHE_HOME="$HOME/.cache/"

#PS1='[\u@\h \W]\$ ' # = default prompt
# custom prompt with RGB colors
PS1='\[\e[38;2;211;198;170m\]╭\[\e[1;38;2;230;126;128m\]<\[\e[38;2;167;192;128m\]\u \[\e[0;38;2;230;126;128m\]☭ \[\e[38;2;167;192;128m\]\h\[\e[1;38;2;230;126;128m\]> \[\e[0;38;2;211;198;170m\][\[\e[3;38;2;127;187;179m\]\w\[\e[0;38;2;211;198;170m\]]\[\e[1;38;2;211;198;170m\]\$\n\[\e[38;2;211;198;170m\]╰\[\e[38;2;211;198;170m\]>\[\e[5;38;2;211;198;170m\]_ \[\e[0m\]'

[ -f "/home/Shwans/.ghcup/env" ] && source "/home/Shwans/.ghcup/env" # ghcup-env

neofetch
