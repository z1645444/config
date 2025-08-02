# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k" # set by `omz`

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git ssh-agent)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# nvm setting
# export NVM_DIR="$HOME/.nvm"
#   [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
#   [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Calling nvm use automatically in a directory with a .nvmrc file
# autoload -U add-zsh-hook

# Load nvmrc
# load-nvmrc() {
#   local nvmrc_path
#   nvmrc_path="$(nvm_find_nvmrc)"
#
#   if [ -n "$nvmrc_path" ]; then
#     local nvmrc_node_version
#     nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
#
#     if [ "$nvmrc_node_version" = "N/A" ]; then
#       nvm install
#     elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
#       nvm use
#     fi
#   elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
#     echo "Reverting to nvm default version"
#     nvm use default
#   fi
# }
#
# add-zsh-hook chpwd load-nvmrc
# load-nvmrc

#export NODE_TLS_REJECT_UNAUTHORIZED=0
export EDITOR=nvim

# proxy setting
# export https_proxy=http://127.0.0.1:7890
# export http_proxy=http://127.0.0.1:7890
# export all_proxy=socks5://127.0.0.1:7890

# alias
alias ra=ranger
alias vi=nvim
alias vim=nvim
alias buu="brew update && brew upgrade"
# alias yarn="yarn --network-timeout 9999999"

# chromium with cors
# alias chromium="open -na /Applications/Chromium.app/Contents/MacOS/Chromium --args --disable-web-security --disable-site-isolation-trials"

# chrome with cors
# alias chrome="open -na Google\ Chrome --args --disable-web-security --disable-site-isolation-trials"
alias chrome="open -na Google\ Chrome --args --user-data-dir='/Users/z1645444/Library/Application Support/Google/Chrome/user0/' --disable-web-security --disable-site-isolation-trials"

# zed editor
alias zed="open -a /Applications/Zed.app -n"

# npm
export NPM_HOME="/Users/z1645444/.local/share/fnm/aliases/default/lib/"
export PATH="$NPM_HOME:$PATH"
# npm end

# pnpm
export PNPM_HOME="/Users/z1645444/Library/pnpm/"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# JetBrains
export PATH="/Applications/WebStorm.app/Contents/MacOS:$PATH"
# JetBrains end

# Flutter
export PATH="/Users/z1645444/development/flutter/bin:$PATH"

# dir for saving scripts
# export PATH=$PATH:~/bin/

# homebrew
# export HOMEBREW_NO_INSTALL_FROM_API=1
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  FPATH=~/.rbenv/completions:"$FPATH"

  autoload -Uz compinit
  compinit
fi

# Load ssh identities
# if ! ssh-add -l | grep -q "z1645444_ssh" || ! ssh-add -l | grep -q "aliyun";
# then
#     ssh-add ~/.ssh/z1645444_ssh
# fi

# never do so, it will slow down startup a lot
# for key_file in ~/.ssh/*_ssh; do
#     if ! ssh-add -l | grep -q "$key_file"; then
#         ssh-add "$key_file"
#     fi
# done

# LLVM
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

[ -f "/Users/z1645444/.ghcup/env" ] && source "/Users/z1645444/.ghcup/env" # ghcup-env

# --- ffmdir ---
# ffmpeg convert script
ffc() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: ffc <format>"
        return 1
    fi

    format=$1

    if [ ! -d "converted" ]; then
        mkdir converted
    fi

    for file in *.*; do
        # only files
        if [ -d "$file" ]; then
            continue
        fi

        filename=$(basename "$file")
        extension="${filename##*.}"
        name="${filename%.*}"

        output="converted/${name}.${format}"

        ffmpeg -i "$file" "$output"
    done

    echo "--------------------------------------------------------------"
    echo "| Conversion completed. All files are saved in 'converted/'. |"
    echo "--------------------------------------------------------------"
}

# yazi
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# shell test
function hello() {
    local opt
    while getopts "a:b:c" opt; do
        case $opt in
            a)
                echo "Pay attention, Option -a with argument $OPTARG"
                ;;
            b)
                echo "Carefully, Option -b with argument $OPTARG"
                ;;
            c)
                echo "Hello, world!"
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                ;;
        esac
    done
}

# zlib
export LDFLAGS="-L/opt/homebrew/opt/zlib/lib"
export CPPFLAGS="-I/opt/homebrew/opt/zlib/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/zlib/lib/pkgconfig"

# fnm env config
eval "$(fnm env --use-on-cd --shell zsh)"


# Added by Windsurf
export PATH="/Users/z1645444/.codeium/windsurf/bin:$PATH"

#compdef pnpm
###-begin-pnpm-completion-###
if type compdef &>/dev/null; then
  _pnpm_completion () {
    local reply
    local si=$IFS

    IFS=$'\n' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" SHELL=zsh pnpm completion-server -- "${words[@]}"))
    IFS=$si

    if [ "$reply" = "__tabtab_complete_files__" ]; then
      _files
    else
      _describe 'values' reply
    fi
  }
  # When called by the Zsh completion system, this will end with
  # "loadautofunc" when initially autoloaded and "shfunc" later on, otherwise,
  # the script was "eval"-ed so use "compdef" to register it with the
  # completion system
  if [[ $zsh_eval_context == *func ]]; then
    _pnpm_completion "$@"
  else
    compdef _pnpm_completion pnpm
  fi
fi
###-end-pnpm-completion-###


# Added by `rbenv init` on Tue May 20 14:14:32 CST 2025
eval "$(rbenv init - --no-rehash zsh)"

# Git-related
alias git='LANG=en_US.UTF-8 git'

