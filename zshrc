ZSHA_BASE=$HOME/my/dotfiles
source $ZSHA_BASE/antigen/antigen.zsh

# For historical purposes
HISTSIZE=10000
SAVEHIST=8500

# Oh My ZSH!
ZSH_THEME="rummik"
COMPLETION_WAITING_DOTS="true"

antigen-use oh-my-zsh

antigen-bundles <<EOBUNDLES
command-not-found
heroku
extract
git
github
vagrant
colored-man
vi-mode
bower
gitignore

hchbaw/opp.zsh
zsh-users/zsh-completions src
zsh-users/zsh-syntax-highlighting
zsh-users/zsh-history-substring-search
$ZSHA_BASE/bundles/ragan
EOBUNDLES

# antigen bundle Lokaltog/powerline powerline/bindings/zsh

if [ "$OSTYPE"="darwin11.0" ]; then
  antigen-bundle osx
fi

# antigen theme agnoster

# antigen-theme $ZSHA_BASE/themes/mgdm/mgdm.zsh-theme

antigen-apply

export JAVA_HOME=`/usr/libexec/java_home -v 1.7`

export EDITOR=vim
export PATH=~/bin:/usr/local/bin:~/Library/Python/2.7/bin/:$PATH

### history
command_oriented_history=1
HISTCONTROL=ignoreboth

export HISTFILE=$HOME/.zsh_history
export HISTSIZE=8192
export SAVEHIST=8192

setopt append_history
setopt bang_hist
setopt extended_history
setopt hist_beep
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify
