# for those servers can't install whatever packages I want
alias nvim='vim'
export EDITOR=vim
export VISUAL=vim

bind 'set completion-ignore-case on'

alias l='ls -la'
alias gl='git pull'
alias gp='git push'
alias glo='git log --oneline --decorate'
alias glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
alias glola='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch --all'
alias gd='git diff'
alias gds='git diff --staged'
alias gsb='git status --short --branch'
alias gr='git remote'
alias grv='git remote --verbose'
alias gc='git commit --verbose'
alias gcam='git commit --all --message'
