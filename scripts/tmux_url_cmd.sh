#!/usr/bin/env bash

# Command dispatcher for URL operations

# Get the directory where the plugin is installed
_tmux_url_source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source core utilities
source "$_tmux_url_source_dir/tmux_core.sh"

# Main command dispatcher
main() {
	local command="$1"
	shift

	case "$command" in
	get-url-list)
		get_url_list "$@"
		;;
	show-url-list)
		show_url_list "$@"
		;;
	*)
		echo "Unknown command: $command"
		echo "Usage: $0 {get-url-list|show-url-list}"
		exit 1
		;;
	esac
}

# Get URLs from current pane
get_url_list() {
	local pane="${1:-}"

	# Get pane content and pipe to Perl script
	_tmux_get_pane_content "$pane" | "$_tmux_url_source_dir/tmux_url.pl"
}

# Show URL list in gum filter and open selected URL
show_url_list() {
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
	url=$(echo "$url_list" | gum filter --placeholder="Select URL to open..." --padding="-1 0")

	# Check if a URL was selected (user didn't press ESC)
	if [ -n "$url" ]; then
		# Get the URL opener command
		local url_opener
		url_opener=$(_get_opener)
		# Open the selected URL in background and detach from shell
		"$url_opener" "$url"
	fi
}

# Run main function
main "$@"
