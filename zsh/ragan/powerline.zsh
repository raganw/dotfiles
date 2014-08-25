POWERLINE_FILE=$PYTHONPATH/powerline/bindings/zsh/powerline.zsh

if [ -f $POWERLINE_FILE ]; then
	`brew --prefix`/bin/powerline-daemon
       	source $POWERLINE_FILE
fi
