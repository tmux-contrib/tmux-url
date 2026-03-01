#!/usr/bin/env bash
set -euo pipefail
[[ -z "${DEBUG:-}" ]] || set -x

_tmux_url_source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f "$_tmux_url_source_dir/tmux_core.sh" ]] || {
	echo "tmux-url: missing tmux_core.sh" >&2
	exit 1
}

# shellcheck source=tmux_core.sh
source "$_tmux_url_source_dir/tmux_core.sh"

_tmux_get_pane_content() {
	local pane="${1:-}"
	local buffer_lines
	buffer_lines=$(_tmux_get_option "@url-buffer-lines" "10000")

	if [ -n "$pane" ]; then
		tmux capture-pane -t "$pane" -p -S "-$buffer_lines"
	else
		tmux capture-pane -p -S "-$buffer_lines"
	fi
}

_tmux_get_detection_mode() {
	_tmux_get_option "@url-detection-mode" "strict"
}

_get_opener() {
	case "$(uname -s)" in
	Darwin)
		echo "open"
		;;
	Linux)
		echo "xdg-open"
		;;
	CYGWIN* | MINGW* | MSYS*)
		echo "start"
		;;
	*)
		echo "xdg-open"
		;;
	esac
}

_get_url_list() {
	local pane="${1:-}"
	local detection_mode
	detection_mode=$(_tmux_get_detection_mode)

	local xurls_flags=""
	if [ "$detection_mode" = "relaxed" ]; then
		xurls_flags="-r"
	fi

	_tmux_get_pane_content "$pane" | xurls $xurls_flags | sort -u
}

_show_url_list() {
	local url_file="$1"

	local url_list
	if [ -n "$url_file" ] && [ -f "$url_file" ]; then
		url_list=$(cat "$url_file")
		rm -f "$url_file"
	else
		url_list=$(cat)
	fi

	if [ -z "$url_list" ]; then
		tmux display-message "No URLs found in current pane"
		return 0
	fi

	local url
	url=$(echo "$url_list" | gum filter --placeholder="Select URL to open..." --padding "0 0 -1 0")

	if [ -n "$url" ]; then
		local url_opener
		url_opener=$(_get_opener)
		"$url_opener" "$url"
	fi
}

main() {
	local command="$1"
	shift

	case "$command" in
	get-url-list)
		_get_url_list "$@"
		;;
	show-url-list)
		_show_url_list "$@"
		;;
	*)
		echo "Unknown command: $command"
		echo "Usage: $0 {get-url-list|show-url-list}"
		exit 1
		;;
	esac
}

main "$@"
