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
    url_list=$("$_tmux_url_source_dir/tmux_url_cmd.sh" extract-url-list)

    # Check if any URLs were found
    if [ -z "$url_list" ]; then
        tmux display-message "No URLs found in current pane"
        exit 0
    fi

    # Get gum filter height from config
    local height
    height=$(_tmux_get_option "@url-gum-height" "20")

    # Show gum filter and get selected URL
    local url
    url=$(echo "$url_list" | gum filter --height="$height" --placeholder="Select URL to open...")

    # Check if a URL was selected (user didn't press ESC)
    if [ -n "$url" ]; then
        # Open the selected URL
        "$_tmux_url_source_dir/tmux_url_cmd.sh" open-url "$url"
    fi
}

# Run main function
main "$@"
