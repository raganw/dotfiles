#!/usr/bin/env bash
# Jump to the next Claude pane that wants you: ones waiting on input first, then ones that
# finished (or errored) since you last looked, oldest first. Skips the current pane.

set -u

current=$(tmux display -p '#{pane_id}')
target=$(tmux list-panes -a -F '#{@claude_state}	#{@claude_state_since}	#{pane_id}' |
	awk -F '\t' -v cur="$current" '
		$3 == cur { next }
		$1 == "waiting" { print 0 "\t" $2 "\t" $3 }
		$1 == "done" || $1 == "error" { print 1 "\t" $2 "\t" $3 }' |
	sort -t "$(printf '\t')" -k1,1n -k2,2n | head -1 | cut -f3)

if [ -z "$target" ]; then
	tmux display-message "No Claude is waiting on you"
	exit 0
fi

tmux switch-client -t "$target" \; select-window -t "$target" \; select-pane -t "$target"
