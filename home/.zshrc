export ZSH_BASE=$HOME/.zsh
export PYTHONPATH=$(brew --prefix)/lib/python2.7/site-packages

# For historical purposes
HISTSIZE=10000
SAVEHIST=8500

COMPLETION_WAITING_DOTS="true"

export JAVA_HOME=`/usr/libexec/java_home -v 1.8`

export EDITOR=vim
export GOPATH=$HOME/go
export PATH=~/bin::/usr/local/sbin:/usr/local/bin:~/Library/Python/2.7/bin:$PATH
export PATH=$PATH:/usr/local/opt/go/libexec/bin:$GOPATH:$HOME/bin
export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH

### history
command_oriented_history=1
HISTCONTROL=ignoreboth

export HISTFILE=$HOME/.zsh_history
export HISTSIZE=8192
export SAVEHIST=8192

setopt extended_glob
setopt append_history
setopt bang_hist
setopt extended_history
setopt hist_beep
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify

# antigen
[[ -f ~/.antigenrc ]] && source ~/.antigenrc
[[ -f ~/.github ]] && source ~/.github

export DISABLE_AUTO_TITLE=true

export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
autoload -U add-zsh-hook
load-nvmrc() {
  if [[ -f .nvmrc && -r .nvmrc ]]; then
    nvm use
  fi
}
add-zsh-hook chpwd load-nvmrc
export LANG=en_US.UTF-8
ulimit -n 65536
fpath=(~/.zsh/completion $fpath)

# Source Socrata configuration
source /Users/Ragan/.socratarc

if test -f ~/.gnupg/.gpg-agent-info -a -n "$(pgrep gpg-agent)"; then
  source ~/.gnupg/.gpg-agent-info
  export GPG_AGENT_INFO
else
  eval $(gpg-agent --daemon --write-env-file ~/.gnupg/.gpg-agent-info)
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
alias ls='ls --color' 

iterm2_print_user_vars() {
  ITERM2_GIT_BRANCH=$(git branch --no-color 2> /dev/null | grep --color=no \* | cut -c3-)
  if [[ -n "$ITERM2_GIT_BRANCH" ]]; then
    iterm2_set_user_var badge "Current git branch is $ITERM2_GIT_BRANCH"
  else
    iterm2_set_user_var badge ""
  fi
}
export DOCKER_HOST=unix:///var/run/docker.sock
if which jenv > /dev/null; then eval "$(jenv init -)"; fi

zstyle ‘:completion:*’ verbose yes

zstyle ‘:completion:*:descriptions’ format ‘%B%d%b’

zstyle ‘:completion:*:messages’ format ‘%d’

zstyle ‘:completion:*:warnings’ format ‘No matches for: %d’

zstyle ‘:completion:*’ group-name ”
autoload -U ~/.zsh/ragan/*(:t)
source "${HOME}/.shell_prompt"
export HOMESHICK_DIR=/usr/local/opt/homeshick
source "/usr/local/opt/homeshick/homeshick.sh"
fpath=($HOME/.homesick/repos/homeshick/completions $fpath)
