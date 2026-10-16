#!/usr/bin/env bash
# Track Claude Code session IDs per tmux pane and resume them after tmux-resurrect.
#
#   tag     Claude SessionStart hook: tag $TMUX_PANE with the session_id from stdin
#   untag   Claude SessionEnd hook: clear the tag if it still names this session
#   save    @resurrect-hook-post-save-layout: write pane -> session map next to the save file
#   restore @resurrect-hook-post-restore-all: run `claude --resume <id>` in each saved pane

set -u

OPT=@claude_session_id
MAP_NAME=claude_sessions.txt

resurrect_dir() {
	local dir
	dir=$(tmux show -gqv @resurrect-dir)
	if [ -z "$dir" ]; then
		if [ -d "$HOME/.tmux/resurrect" ]; then
			dir="$HOME/.tmux/resurrect"
		else
			dir="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect"
		fi
	fi
	echo "$dir" | sed "s,\$HOME,$HOME,g; s,\~,$HOME,g"
}

session_id_from_stdin() {
	jq -r '.session_id // empty'
}

case "${1:-}" in
tag)
	[ -n "${TMUX_PANE:-}" ] || exit 0
	id=$(session_id_from_stdin)
	[ -n "$id" ] && tmux set -p -t "$TMUX_PANE" "$OPT" "$id"
	;;
untag)
	[ -n "${TMUX_PANE:-}" ] || exit 0
	id=$(session_id_from_stdin)
	# /clear ends one session and starts another; only clear our own tag
	[ "$(tmux show -p -t "$TMUX_PANE" -qv "$OPT")" = "$id" ] &&
		tmux set -p -t "$TMUX_PANE" -u "$OPT"
	;;
save)
	dir=$(dirname "${2:-$(resurrect_dir)/x}")
	tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}	#{$OPT}" |
		awk -F '\t' '$2 != ""' >"$dir/$MAP_NAME"
	;;
restore)
	map="$(resurrect_dir)/$MAP_NAME"
	[ -f "$map" ] || exit 0
	while IFS=$'\t' read -r target id; do
		[ -n "$target" ] && [ -n "$id" ] || continue
		cmd=$(tmux display -p -t "$target" '#{pane_current_command}' 2>/dev/null) || continue
		case "$cmd" in
		zsh | bash | fish | sh | -zsh | -bash) tmux send-keys -t "$target" "claude --resume $id" Enter ;;
		esac
	done <"$map"
	;;
*)
	echo "usage: $0 tag|untag|save [file]|restore" >&2
	exit 1
	;;
esac
exit 0
