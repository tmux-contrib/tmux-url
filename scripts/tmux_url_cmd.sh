#!/usr/bin/env bash

# Command dispatcher for URL operations

# Get the directory where the plugin is installed
_tmux_url_source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source core utilities
source "$_tmux_url_source_dir/tmux_core.sh"

# Get URLs from current pane
# URL extraction flow:
# 1. Get pane content from tmux
# 2. Extract URLs using xurls (strict or relaxed mode)
# 3. Deduplicate URLs with sort -u
_get_url_list() {
	local pane="${1:-}"

	# Get detection mode setting
	local detection_mode
	detection_mode=$(_tmux_get_detection_mode)

	# Set xurls flags based on detection mode
	local xurls_flags=""
	if [ "$detection_mode" = "relaxed" ]; then
		xurls_flags="-r"
	fi

	# Get pane content → extract URLs with xurls → deduplicate
	_tmux_get_pane_content "$pane" | xurls $xurls_flags | sort -u
}

# Show URL list in gum filter and open selected URL
_show_url_list() {
	local url_file="$1"

	# Read URL list from file or stdin
	local url_list
	if [ -n "$url_file" ] && [ -f "$url_file" ]; then
		url_list=$(cat "$url_file")
		# Clean up temp file after reading
		rm -f "$url_file"
	else
		url_list=$(cat)
	fi

	# Check if any URLs were provided
	if [ -z "$url_list" ]; then
		tmux display-message "No URLs found in current pane"
		return 0
	fi

	# Show gum filter and get selected URL
	local url
	url=$(echo "$url_list" | gum filter --placeholder="Select URL to open..." --padding "0 0 -1 0")

	# Check if a URL was selected (user didn't press ESC)
	if [ -n "$url" ]; then
		# Get the URL opener command
		local url_opener
		url_opener=$(_get_opener)
		# Open the selected URL in background and detach from shell
		"$url_opener" "$url"
	fi
}

# Main command dispatcher
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

# Run main function
main "$@"
