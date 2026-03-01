#!/usr/bin/env bash
# tmux_core.sh — shared library; meant to be sourced, not executed directly.

_tmux_get_option() {
	local option="$1"
	local default="${2:-}"
	local value

	value="$(tmux show-option -gqv "$option" 2>/dev/null)"
	echo "${value:-$default}"
}

_tmux_set_option() {
	local option="$1"
	local value="$2"

	tmux set-option -g "$option" "$value"
}

_tmux_set_session_option() {
	local session="$1"
	local option="$2"
	local value="$3"

	tmux set-option -t "$session" "$option" "$value"
}
