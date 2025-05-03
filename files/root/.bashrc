# This file is managed by puppet.
#
# This file exists purely for quality of life in the rare case we log in as
# root. If there is any disagreement on what's comfy, we should feel free to
# delete anything and revert to defaults.
#
# DO NOT PUT ANYTHING IN THIS FILE THAT IS ACTUALLY CRITICAL TO MAKE A SYSTEM
# WORK. THESE ARE ONLY CREATURE COMFORTS.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# color, abbreviation
eval "$(dircolors)"
alias ls='ls --color=auto'
alias l='ls -F'
alias ll='ls -lh'
alias la='ls -AF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias rgrep='rgrep --color=auto'
alias ip='ip -color=auto'

# history
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
HISTSIZE=10000
HISTFILESIZE=10000
