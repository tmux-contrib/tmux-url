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

	if ! command -v xurls &>/dev/null; then
		missing_deps+=("xurls")
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
			xurls)
				echo "  xurls: https://github.com/mvdan/xurls"
				echo "    - macOS: brew install xurls"
				echo "    - Linux: go install mvdan.cc/xurls/v2/cmd/xurls@latest"
				echo "    - Or download from https://github.com/mvdan/xurls/releases"
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

# Get URL detection mode (default: strict)
_tmux_get_detection_mode() {
	_tmux_get_option "@url-detection-mode" "strict"
}

# Auto-detect browser command based on platform
_get_opener() {
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
