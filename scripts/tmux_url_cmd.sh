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
    extract-url-list)
        extract_url_list "$@"
        ;;
    show-url-list)
        show_url_list "$@"
        ;;
    open-url)
        open_url "$@"
        ;;
    *)
        echo "Unknown command: $command"
        echo "Usage: $0 {extract-url-list|show-url-list|open-url}"
        exit 1
        ;;
    esac
}

# Extract URLs from current pane
extract_url_list() {
    local pane="${1:-}"

    # Get pane content and pipe to Perl script
    _tmux_get_pane_content "$pane" | "$_tmux_url_source_dir/tmux_url.pl"
}

# Show URL list in gum filter and open selected URL
show_url_list() {
    local url_list_file="$1"

    # Read URL list from file or stdin
    local url_list
    if [ -n "$url_list_file" ] && [ -f "$url_list_file" ]; then
        url_list=$(cat "$url_list_file")
        # Clean up temp file after reading
        rm -f "$url_list_file"
    else
        url_list=$(cat)
    fi

    # Check if any URLs were provided
    if [ -z "$url_list" ]; then
        tmux display-message "No URLs found in current pane"
        return 0
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
        open_url "$url"
    fi
}

# Open URL in browser
open_url() {
    local url="$1"

    if [ -z "$url" ]; then
        echo "Error: No URL provided"
        return 1
    fi

    local browser
    browser=$(_get_browser_command)

    # Display message to user
    tmux display-message "Opening: $url"

    # Open URL in browser (run in background)
    "$browser" "$url" &>/dev/null &
}

# Run main function
main "$@"
