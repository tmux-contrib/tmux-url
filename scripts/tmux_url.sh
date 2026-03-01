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

main() {
	local url_list
	url_list=$("$_tmux_url_source_dir/tmux_url_cmd.sh" get-url-list)

	if [ -z "$url_list" ]; then
		tmux display-message "No URLs found in current pane"
		exit 0
	fi

	local url_file
	url_file=$(mktemp)
	echo "$url_list" >"$url_file"

	tmux display-popup -E -T " URL Finder " "$_tmux_url_source_dir/tmux_url_cmd.sh" show-url-list "$url_file"
}

main "$@"
