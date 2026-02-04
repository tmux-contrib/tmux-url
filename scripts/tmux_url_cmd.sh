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
    open-url)
        open_url "$@"
        ;;
    *)
        echo "Unknown command: $command"
        echo "Usage: $0 {extract-url-list|open-url}"
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
