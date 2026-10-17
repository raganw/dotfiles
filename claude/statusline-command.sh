#!/bin/bash

input=$(cat)

dir=$(echo "$input" | jq -r '.workspace.current_dir')
dir_name=$(basename "$dir")

branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)

model=$(echo "$input" | jq -r '.model.display_name')

remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

DIM='\033[2m'
CYAN='\033[2;36m'
GREEN='\033[2;32m'
YELLOW='\033[2;33m'
RESET='\033[0m'

# Worktrunk's segment covers dir, branch, worktree status and model; fall back without it
wt_status=""
if command -v wt >/dev/null 2>&1; then
  wt_status=$(echo "$input" | wt list statusline --format=claude-code 2>/dev/null)
fi

if [ -n "$wt_status" ]; then
  output="${wt_status}${RESET}"
else
  output="${DIM}${dir_name}${RESET}"
  if [ -n "$branch" ]; then
    output="${output} ${DIM}on${RESET} ${GREEN}${branch}${RESET}"
  fi
  output="${output} ${DIM}|${RESET} ${CYAN}${model}${RESET}"
fi

if [ -n "$remaining" ]; then
  output="${output} ${DIM}|${RESET} ${YELLOW}${remaining}% left${RESET}"
fi

printf "%b\n" "$output"
