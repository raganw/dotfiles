#!/usr/bin/env zsh
# Fixed left sidebar listing every window with its Claude and PR state. It is one pane
# that moves into whichever window you're viewing.
#
#   sidebar.sh toggle <window>   show/hide it (prefix b)
#   sidebar.sh follow <window>   tmux hook: move it into <window>
#   sidebar.sh place <window>    tmux hook: put it back full-height on the left after a re-layout
#   sidebar.sh orphan            tmux hook: close a window left holding only the sidebar
#   sidebar.sh saved             resurrect hook: record where the sidebar was
#   sidebar.sh restored          resurrect hook: drop restored copies, re-show it if enabled
#   sidebar.sh refresh           redraw now (claude-state.sh and ticket-pr-status call this)
#   sidebar.sh run|list|cursor|go <target>   internal: the fzf process and its actions
#
# The pane carries @sidebar=1 so the navigation bindings in tmux.conf can skip it.
# tmux-resurrect saves it like any pane and restores it as a plain shell; `saved` records
# its position so `restored` can remove that copy (the title is a fallback, since a
# restored shell's prompt may retitle it).

setopt extendedglob
zmodload zsh/datetime zsh/stat

readonly TITLE=tmux-sidebar
readonly SOCK=${TMPDIR:-/tmp}/tmux-sidebar.sock
readonly POS=${TMPDIR:-/tmp}/tmux-sidebar.pos
readonly LOCK=${TMPDIR:-/tmp}/tmux-sidebar.lock
readonly SELF=${0:A}

enabled() { [[ $(tmux show -gqv @sidebar_enabled) == on ]] }

width() {
	local w=$(tmux show -gqv @sidebar_width)
	print -- ${w:-30}
}

# The live sidebar pane, if there is one
sidebar_pane() {
	local id=$(tmux show -gqv @sidebar_pane)
	[[ -n $id && $(tmux display -p -t $id '#{@sidebar}' 2>/dev/null) == 1 ]] && print -- $id
}

# follow and orphan both create panes from async hooks; serialise them
lock() {
	local i
	for i in {1..40}; do
		mkdir $LOCK 2>/dev/null && return 0
		(( EPOCHSECONDS - $(zstat +mtime $LOCK 2>/dev/null || print $EPOCHSECONDS) > 10 )) && rmdir $LOCK 2>/dev/null
		sleep 0.05
	done
	return 1
}
unlock() { rmdir $LOCK 2>/dev/null }

create() {
	local pane
	pane=$(tmux split-window -d -P -F '#{pane_id}' -hbf -l $(width) -t $1 "$SELF run") || return 1
	tmux set -p -t $pane @sidebar 1 \; set -g @sidebar_pane $pane
}

place() {
	local win=$1 sb W left height wheight pwidth panes other
	sb=$(sidebar_pane) || return 0
	[[ $(tmux display -p -t $sb '#{window_id}') == $win ]] || return 0
	W=$(width)
	read -r left height wheight pwidth panes <<<$(tmux display -p -t $sb '#{pane_left} #{pane_height} #{window_height} #{pane_width} #{window_panes}')
	(( panes > 1 )) || return 0
	if (( left != 0 || height != wheight )); then
		other=$(tmux list-panes -t $win -F '#{pane_id} #{@sidebar}' | awk '$2 != 1 { print $1; exit }')
		# -E evens out the panes the re-layout left beside it; the hook it fires finds us placed
		tmux move-pane -d -hbf -l $W -s $sb -t $other \; select-layout -E -t $other
	elif (( pwidth != W )); then
		tmux resize-pane -t $sb -x $W
	fi
}

follow() {
	local win=$1 sb
	enabled || return 0
	[[ -n $win ]] || win=$(tmux display -p '#{window_id}')
	# joining a zoomed window would unzoom it
	[[ $(tmux display -p -t $win '#{window_zoomed_flag}') == 1 ]] && return 0
	lock || return 0
	sb=$(sidebar_pane)
	if [[ -z $sb ]]; then
		create $win
	elif [[ $(tmux display -p -t $sb '#{window_id}') != $win ]]; then
		tmux join-pane -d -hbf -l $(width) -s $sb -t $win
	fi
	unlock
	place $win
	refresh
}

refresh() {
	[[ -S $SOCK ]] || return 0
	curl -s --noproxy '*' --max-time 1 --unix-socket $SOCK -X POST http://localhost \
		-d "reload-sync($SELF list)" >/dev/null 2>&1
}

# Truncate to a display width, marking the cut with …
fit() {
	local s=$1 max=$2
	(( ${(m)#s} <= max )) && { print -r -- $s; return }
	while (( ${(m)#s} > max - 1 )); do s=${s[1,-2]}; done
	print -r -- "$s…"
}

list() {
	local W=$(width) sbwin='' sb row=0 cur_row=1 last_session='' sep=$'\x1f'
	local sid sname wid widx wname cstate prstate checks mark claude pr name
	local reset=$'\e[0m'
	local blue=$'\e[1;38;2;137;180;250m' dim=$'\e[38;2;127;132;156m' yellow=$'\e[38;2;249;226;175m'
	local red=$'\e[38;2;243;139;168m' green=$'\e[38;2;166;227;161m' mauve=$'\e[38;2;203;166;247m'
	sb=$(sidebar_pane) && sbwin=$(tmux display -p -t $sb '#{window_id}')

	# one line per window: worst Claude state across its panes wins
	tmux list-panes -a -F $'#{session_id}\x1f#{session_name}\x1f#{window_id}\x1f#{window_index}\x1f#{window_name}\x1f#{@claude_state}\x1f#{@pr_state}\x1f#{@pr_checks}' |
		awk -v FS=$sep -v OFS=$sep '
			function rank(s) { return s == "waiting" ? 5 : s == "error" ? 4 : s == "working" ? 3 : s == "done" ? 2 : s == "idle" ? 1 : 0 }
			!($3 in seen) { seen[$3] = 1; order[++n] = $3; line[$3] = $0; state[$3] = $6 }
			rank($6) > rank(state[$3]) { state[$3] = $6 }
			END { for (i = 1; i <= n; i++) { w = order[i]; split(line[w], f, FS); print f[1], f[2], f[3], f[4], f[5], state[w], f[7], f[8] } }' |
		while IFS=$'\x1f' read -r sid sname wid widx wname cstate prstate checks; do
			if [[ $sid != $last_session ]]; then
				last_session=$sid
				(( ++row ))
				print -r -- "$sid"$'\t'"$blue$(fit $sname $((W - 2)))$reset"
			fi
			mark='  ' claude='  ' pr='  '
			[[ $wid == $sbwin ]] && { mark="$blue▸$reset "; cur_row=$((row + 1)); }
			case $cstate in
			working) claude=" $yellow"$''"$reset" ;;
			waiting) claude=" $red"$''"$reset" ;;
			done) claude=" $green"$''"$reset" ;;
			error) claude=" $red"$''"$reset" ;;
			esac
			case $prstate in
			open) case $checks in pass) pr=" $green" ;; fail) pr=" $red" ;; *) pr=" $yellow" ;; esac; pr+=$''"$reset" ;;
			draft) pr=" $dim"$''"$reset" ;;
			merged) pr=" $mauve"$''"$reset" ;;
			esac
			# 2 for fzf's gutter, 2 for the marker, 4 for the badges
			name=$(fit "$widx $wname" $((W - 8)))
			(( ++row ))
			print -r -- "$wid"$'\t'"$mark${(mr:W-8:)name}$claude$pr"
		done
	print -- $cur_row >$POS
}

run() {
	local loop
	print -n -- $'\e]2;'$TITLE$'\e\\'
	rm -f $SOCK
	# fallback for changes no hook reports, such as renames
	(while sleep 5; do $SELF refresh; done) &
	loop=$!
	trap "kill $loop 2>/dev/null; rm -f $SOCK" EXIT
	trap 'exit 0' HUP TERM INT
	while :; do
		$SELF list | fzf --ansi --no-input --no-sort --layout=reverse --info=hidden --no-separator \
			--delimiter=$'\t' --with-nth=2 --pointer=' ' --gutter=' ' --no-scrollbar \
			--color='bg+:#313244,fg+:-1,hl:-1,hl+:-1' --listen=$SOCK \
			--bind "load:transform($SELF cursor)" \
			--bind "enter:execute-silent($SELF go {1})" \
			--bind "double-click:execute-silent($SELF go {1})" \
			--bind "j:down,k:up,r:reload-sync($SELF list),esc:ignore,ctrl-c:ignore,ctrl-q:ignore"
		sleep 0.2
	done
}

go() {
	local target=$1
	case $target in
	'$'*) tmux switch-client -t $target ;;
	@*) tmux switch-client -t $target \; select-window -t $target ;;
	esac
}

orphan() {
	local sb win
	enabled || return 0
	sb=$(sidebar_pane) || return 0
	[[ $(tmux display -p -t $sb '#{window_panes}') == 1 ]] || return 0
	win=$(tmux display -p -t $sb '#{window_id}')
	tmux set -gu @sidebar_pane \; kill-window -t $win
	follow
}

resurrect_dir() {
	local dir=$(tmux show -gqv @resurrect-dir)
	[[ -n $dir ]] || { [[ -d ~/.tmux/resurrect ]] && dir=~/.tmux/resurrect || dir=${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect }
	print -- ${${dir//\$HOME/$HOME}/#\~/$HOME}
}

saved() {
	local sb target=''
	sb=$(sidebar_pane) && target=$(tmux display -p -t $sb '#{session_name}:#{window_index}.#{pane_index}')
	print -r -- $target >$(resurrect_dir)/sidebar_pane.txt
}

restored() {
	local live=$(sidebar_pane) p title cmd target
	target=$(cat $(resurrect_dir)/sidebar_pane.txt 2>/dev/null)
	if [[ -n $target ]]; then
		p=$(tmux display -p -t $target '#{pane_id}' 2>/dev/null)
		cmd=$(tmux display -p -t $target '#{pane_current_command}' 2>/dev/null)
		[[ -n $p && $p != $live && $cmd == (zsh|bash|sh|fish|-zsh) ]] && tmux kill-pane -t $p
	fi
	tmux list-panes -a -F $'#{pane_id}\t#{pane_title}' | while IFS=$'\t' read -r p title; do
		[[ $title == $TITLE && $p != $live ]] && tmux kill-pane -t $p
	done
	follow
}

toggle() {
	local sb
	if enabled; then
		tmux set -g @sidebar_enabled off
		sb=$(sidebar_pane) && tmux set -gu @sidebar_pane \; kill-pane -t $sb
	else
		tmux set -g @sidebar_enabled on
		follow $1
	fi
}

case ${1:-} in
toggle | follow | place) $1 ${2:-} ;;
orphan | saved | restored | refresh | run | list) $1 ;;
cursor) print -- "pos($(cat $POS 2>/dev/null || print 1))" ;;
go) go ${2:-} ;;
*)
	print -u2 -- "usage: sidebar.sh toggle|follow|place [window] | orphan|saved|restored|refresh | run|list|cursor|go <target>"
	exit 1
	;;
esac
