export ZSH_BASE=$HOME/.zsh

export PYTHONPATH=/usr/local/lib/python2.7/site-packages

# For historical purposes
HISTSIZE=10000
SAVEHIST=8500

COMPLETION_WAITING_DOTS="true"

export JAVA_HOME=`/usr/libexec/java_home -v 1.8`

export EDITOR=vim
export PATH=~/bin::/usr/local/bin:~/Library/Python/2.7/bin:$PATH

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

export NVM_DIR=~/.nvm
source /usr/local/opt/nvm/nvm.sh

autoload -U add-zsh-hook
load-nvmrc() {
  if [[ -f .nvmrc && -r .nvmrc ]]; then
    nvm use
  fi
}
add-zsh-hook chpwd load-nvmrc

source ~/.github
export SBT_OPTS="-Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled -Dsbt.jse.engineType=Node"

test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh
source "${HOME}/.shell_prompt"
export HOMESHICK_DIR=/usr/local/opt/homeshick
source "/usr/local/opt/homeshick/homeshick.sh"
fpath=($HOME/.homesick/repos/homeshick/completions $fpath)
