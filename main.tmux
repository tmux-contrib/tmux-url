#!/usr/bin/env bash

# tmux-url plugin entry point
# Sourced by TPM (Tmux Plugin Manager)

# Get the directory where the plugin is installed
_tmux_url_root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source core utilities
source "$_tmux_url_root_dir/scripts/tmux_core.sh"

# Check dependencies
if ! _check_dependencies; then
    tmux display-message "tmux-url: Missing dependencies. Check terminal output."
    exit 1
fi

# Get user-configured key binding (default: 'u')
url_key=$(_tmux_get_option "@url-key" "u")

# Bind the key to run the URL picker
tmux bind-key "$url_key" run-shell "$_tmux_url_root_dir/scripts/tmux_url.sh"
