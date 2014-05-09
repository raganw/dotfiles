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

jimhester/per-directory-history
hchbaw/opp.zsh
zsh-users/zsh-completions src
zsh-users/zsh-syntax-highlighting
zsh-users/zsh-history-substring-search
$ZSHA_BASE/bundles/ragan
EOBUNDLES

antigen bundle Lokaltog/powerline powerline/bindings/zsh

if [ "$OSTYPE"="darwin11.0" ]; then
  antigen-bundle osx
fi

# antigen theme agnoster

# antigen-theme $ZSHA_BASE/themes/mgdm/mgdm.zsh-theme

antigen-apply

source /opt/boxen/env.sh
export PATH=$PATH:/opt/boxen/nodenv/versions/v0.10/bin
export JAVA_HOME=`/usr/libexec/java_home -v 1.7`

export EDITOR=vim
