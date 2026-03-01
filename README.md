# tmux-url

Extract and open URLs from your tmux pane with a beautiful interactive picker powered by [gum](https://github.com/charmbracelet/gum).

## Dependencies

- [tmux](https://github.com/tmux/tmux) (version 1.8+)
- [gum](https://github.com/charmbracelet/gum) - Terminal UI toolkit
- [xurls](https://github.com/mvdan/xurls) - URL extractor

## Installation

Add this plugin to your `~/.tmux.conf`:

```tmux
set -g @plugin 'tmux-contrib/tmux-url'
```

And install it by running `<prefix> + I`.

## Usage

| Key Binding   | Action                             |
|---------------|------------------------------------|
| `Prefix + u`  | Open URL picker for current pane   |

**Workflow**:
1. Press `Prefix + u` (default: `Ctrl+b` then `u`)
2. Select a URL from the interactive list using arrow keys
3. Press `Enter` to open in your default browser
4. Press `Esc` to cancel

## Configuration

Add these options to your `~/.tmux.conf` before loading the plugin:

```tmux
# Custom key binding (default: u)
set -g @url-key 'o'

# URL detection mode (default: strict)
set -g @url-detection-mode strict   # Only URLs with explicit schemes
set -g @url-detection-mode relaxed  # Include bare domains

# Buffer scan depth (default: 10000)
set -g @url-buffer-lines 5000
```

### Options

| Option                 | Default    | Description                            |
|------------------------|------------|----------------------------------------|
| `@url-key`             | `"u"`      | Key binding for URL picker             |
| `@url-detection-mode`  | `"strict"` | URL detection mode (strict or relaxed) |
| `@url-buffer-lines`    | `"10000"`  | Lines to scan from pane history        |

### Detection Modes

**Strict mode** (default):
- Detects: `https://github.com`, `ftp://example.com`, `mailto:user@example.com`
- Does NOT detect: `github.com`, `user@example.com` (without scheme)

**Relaxed mode**:
- Detects all URLs from strict mode PLUS bare domains like `github.com`

## Development

### Prerequisites

Install dependencies using [Nix](https://nixos.org/):

```sh
nix develop
```

Or install manually: `bash`, `tmux`, `bats`

### Running Tests

```sh
bats tests/
```

### Debugging

Enable trace output with the `DEBUG` environment variable:

```sh
DEBUG=1 /path/to/tmux-url/scripts/tmux_url.sh
```

## License

MIT
