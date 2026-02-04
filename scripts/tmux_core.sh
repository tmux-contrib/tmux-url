#!/usr/bin/env bash

# Core utility functions for tmux-url plugin

# Get the directory where the plugin is installed
_tmux_root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Check if required dependencies are installed
_check_dependencies() {
    local missing_deps=()

    if ! command -v gum &>/dev/null; then
        missing_deps+=("gum")
    fi

    if ! command -v perl &>/dev/null; then
        missing_deps+=("perl")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Error: Missing required dependencies: ${missing_deps[*]}"
        echo ""
        echo "Installation instructions:"
        for dep in "${missing_deps[@]}"; do
            case "$dep" in
            gum)
                echo "  gum: https://github.com/charmbracelet/gum#installation"
                echo "    - macOS: brew install gum"
                echo "    - Linux: https://github.com/charmbracelet/gum/releases"
                ;;
            perl)
                echo "  perl: Usually pre-installed on macOS/Linux"
                echo "    - macOS: Should be available by default"
                echo "    - Linux: apt-get install perl / yum install perl"
                ;;
            esac
        done
        return 1
    fi
    return 0
}

# Get tmux option with default fallback
_tmux_get_option() {
    local option="$1"
    local default="$2"
    local value

    value=$(tmux show-option -gqv "$option")

    if [ -z "$value" ]; then
        echo "$default"
    else
        echo "$value"
    fi
}

# Auto-detect browser command based on platform
_get_browser_command() {
    local browser
    browser=$(_tmux_get_option "@url-browser" "")

    if [ -n "$browser" ]; then
        echo "$browser"
        return
    fi

    # Platform detection
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

# Get pane content using tmux capture-pane
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
