#!/usr/bin/env bash
set -euo pipefail
[[ -z "${DEBUG:-}" ]] || set -x

_tmux_url_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f "$_tmux_url_root/scripts/tmux_core.sh" ]] || {
	echo "tmux-url: missing tmux_core.sh" >&2
	exit 1
}

# shellcheck source=scripts/tmux_core.sh
source "$_tmux_url_root/scripts/tmux_core.sh"

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

main() {
	if ! _check_dependencies; then
		tmux display-message "tmux-url: Missing dependencies. Check terminal output."
		exit 1
	fi

	local url_key
	url_key=$(_tmux_get_option "@url-key" "u")

	tmux bind-key "$url_key" run-shell "$_tmux_url_root/scripts/tmux_url.sh"
}

main
