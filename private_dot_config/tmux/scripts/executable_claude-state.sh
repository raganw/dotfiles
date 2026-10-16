#!/usr/bin/env bash
# Mirror Claude Code's state onto its tmux pane and window.
#
#   claude-state.sh idle|working|waiting|done|error|end   Claude hook; reads hook JSON on stdin
#   claude-state.sh seen <window>                         tmux hook; you looked at <window>
#
# Sets @claude_state and @claude_state_since on the pane (read by claude-jump.sh) and
# @claude_badge on the window (shown in the window tab). done/error mean "finished and
# you haven't looked yet": they drop to idle once the window is viewed. waiting/done/error
# ring the pane's bell and post a macOS notification unless the pane is on screen.

set -u

badge_for() {
	case "$1" in
	working) echo '#[fg=#{@thm_yellow}] ' ;;
	waiting) echo '#[fg=#{@thm_red}] ' ;;
	done) echo '#[fg=#{@thm_green}] ' ;;
	error) echo '#[fg=#{@thm_red}] ' ;;
	esac
}

set_state() {
	local pane=$1 state=$2 badge
	badge=$(badge_for "$state")
	[ -n "$badge" ] && badge="$badge#[fg=#{@thm_fg}]"
	tmux set -p -t "$pane" @claude_state "$state" \; \
		set -p -t "$pane" @claude_state_since "$(date +%s)" \; \
		set -w -t "$pane" @claude_badge "$badge"
	"$(dirname "$0")/sidebar.sh" refresh >/dev/null 2>&1 &
}

on_screen() {
	[ "$(tmux display -p -t "$1" '#{&&:#{session_attached},#{&&:#{window_active},#{pane_active}}}')" = 1 ]
}

notify() {
	local pane=$1 message=$2 tty title
	tty=$(tmux display -p -t "$pane" '#{pane_tty}')
	printf '\a' >"$tty" 2>/dev/null
	title=$(tmux display -p -t "$pane" 'Claude · #{session_name}: #{window_name}')
	osascript -e 'on run argv' -e 'display notification (item 2 of argv) with title (item 1 of argv)' -e 'end run' \
		"$title" "$message" >/dev/null 2>&1 &
}

state=${1:-}

if [ "$state" = seen ]; then
	window=${2:-}
	[ -n "$window" ] || exit 0
	tmux list-panes -t "$window" -F '#{pane_id} #{@claude_state}' | while read -r pane s; do
		case "$s" in done | error) set_state "$pane" idle ;; esac
	done
	exit 0
fi

[ -n "${TMUX_PANE:-}" ] || exit 0
pane=$TMUX_PANE
input=$(cat)

case "$state" in
end)
	tmux set -p -t "$pane" -u @claude_state \; set -p -t "$pane" -u @claude_state_since \; \
		set -w -t "$pane" -u @claude_badge
	;;
idle | working)
	# PostToolUse fires per tool call; skip the write when nothing changed
	[ "$(tmux show -p -t "$pane" -qv @claude_state)" = "$state" ] || set_state "$pane" "$state"
	;;
waiting | done | error)
	if on_screen "$pane"; then
		[ "$state" = waiting ] && set_state "$pane" waiting || set_state "$pane" idle
		exit 0
	fi
	set_state "$pane" "$state"
	case "$state" in
	waiting) message=$(jq -r '.message // empty' <<<"$input") ;;
	done) message=Finished ;;
	error) message="Stopped with an error" ;;
	esac
	notify "$pane" "${message:-Needs your input}"
	;;
*)
	echo "usage: $0 idle|working|waiting|done|error|end | seen <window>" >&2
	exit 1
	;;
esac
exit 0
