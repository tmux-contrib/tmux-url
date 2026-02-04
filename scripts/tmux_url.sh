#!/usr/bin/env bash

# Main orchestration script for URL picker

# Get the directory where the plugin is installed
_tmux_url_source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source core utilities
source "$_tmux_url_source_dir/tmux_core.sh"

# Main function
main() {
	local url_list
	# Extract URLs from current pane
	url_list=$("$_tmux_url_source_dir/tmux_url_cmd.sh" get-url-list)

	# Check if any URLs were found
	if [ -z "$url_list" ]; then
		tmux display-message "No URLs found in current pane"
		exit 0
	fi

	local url_file
	url_file=$(mktemp)
	# Create a temporary file to store the URL list
	echo "$url_list" >"$url_file"

	# Show gum filter in a split window (reuse if already open)
	tmux display-popup "$_tmux_url_source_dir/tmux_url_cmd.sh" show-url-list "$url_file"
}

# Run main function
main "$@"
