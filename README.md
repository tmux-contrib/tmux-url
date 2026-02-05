# tmux-url

A tmux plugin that extracts URLs from the current pane and allows interactive selection using [gum](https://github.com/charmbracelet/gum).

## Features

- 🔍 **Smart URL Detection**: Powered by xurls for accurate URL extraction
- 🎯 **Strict Mode by Default**: Only detects URLs with explicit schemes to reduce false positives
- 🎨 **Interactive Selection**: Beautiful terminal UI powered by gum filter
- 🚀 **Quick Access**: Simple `Prefix + u` keybinding
- 🌐 **Cross-Platform**: Works on macOS, Linux, and Windows
- ⚙️ **Configurable**: Customize detection mode, key bindings, and browser
- 📋 **Deduplication**: Automatically removes duplicate URLs

## Requirements

- [tmux](https://github.com/tmux/tmux) (version 1.8+)
- [gum](https://github.com/charmbracelet/gum) - Terminal UI toolkit
- [xurls](https://github.com/mvdan/xurls) - URL extractor

### Installing Dependencies

**gum**:
- macOS: `brew install gum`
- Linux: See [gum installation guide](https://github.com/charmbracelet/gum#installation)
- Windows: See [gum releases](https://github.com/charmbracelet/gum/releases)

**xurls**:
- macOS: `brew install xurls`
- Linux: `go install mvdan.cc/xurls/v2/cmd/xurls@latest`
- Or download binary from [releases](https://github.com/mvdan/xurls/releases)

## Installation

### Using TPM (Tmux Plugin Manager)

1. Add plugin to your `~/.tmux.conf`:

```bash
set -g @plugin 'tmux-contrib/tmux-url'
```

2. Press `Prefix + I` to install (default prefix is `Ctrl+b`)

### Manual Installation

1. Clone the repository:

```bash
git clone https://github.com/tmux-contrib/tmux-url ~/.tmux/plugins/tmux-url
```

2. Add to your `~/.tmux.conf`:

```bash
run-shell ~/.tmux/plugins/tmux-url/main.tmux
```

3. Reload tmux configuration:

```bash
tmux source-file ~/.tmux.conf
```

## Usage

| Key Binding | Action |
|-------------|--------|
| `Prefix + u` | Open URL picker for current pane |

**Workflow**:
1. Press `Prefix + u` (default: `Ctrl+b` then `u`)
2. Select a URL from the interactive list using arrow keys
3. Press `Enter` to open in your default browser
4. Press `Esc` to cancel

## Configuration

Add these options to your `~/.tmux.conf` before loading the plugin:

### Key Binding

Change the key binding (default: `u`):

```bash
set -g @url-key 'o'  # Use Prefix + o instead
```

**Browser auto-detection**:
- macOS: `open`
- Linux: `xdg-open`
- Windows: `start`

### Buffer Scan Depth

Set how many lines to scan from pane history (default: `10000`):

```bash
set -g @url-buffer-lines 5000
```

### URL Detection Mode

Set the URL detection mode (default: `strict`):

```bash
set -g @url-detection-mode strict   # Only URLs with explicit schemes (default)
set -g @url-detection-mode relaxed  # Include bare domains
```

**Strict mode** (default):
- Detects: `https://github.com`, `ftp://example.com`, `mailto:user@example.com`
- Does NOT detect: `github.com`, `user@example.com` (without scheme)
- Fewer false positives from domain-like text

**Relaxed mode**:
- Detects all URLs from strict mode PLUS:
- Bare domains: `github.com` → `https://github.com`
- More permissive but may include false positives

### Example Configuration

```bash
# ~/.tmux.conf

# Custom key binding
set -g @url-key 'o'

# URL detection mode (strict by default)
set -g @url-detection-mode strict  # or 'relaxed' for bare domains

# Scan last 5000 lines
set -g @url-buffer-lines 5000

# Load plugin
set -g @plugin 'tmux-contrib/tmux-url'
```

## URL Detection Patterns

### Strict Mode (Default)

In strict mode, only URLs with explicit schemes are detected:

- **Supported schemes**: `https://`, `http://`, `ftp://`, `ftps://`, `ssh://`, `git://`, `mailto:`, `tel:`, `ws://`, and many more
- Examples:
  - `https://github.com/tmux-contrib/tmux-url` ✅
  - `mailto:user@example.com` ✅
  - `ssh://git@github.com/repo.git` ✅
  - `github.com` ❌ (no scheme)
  - `user@example.com` ❌ (no scheme)

### Relaxed Mode (Opt-in)

In relaxed mode (`set -g @url-detection-mode relaxed`), the plugin also detects:

1. **Bare Domain Names**: Common TLDs without schemes (auto-prepends `https://`)
   - Example: `github.com` → `https://github.com`
   - Supported TLDs: .com, .org, .net, .io, .dev, .app, .co, .edu, and many more

Note: Email addresses without `mailto:` prefix are NOT detected. Use explicit `mailto:user@example.com` format.

## Troubleshooting

### "Missing dependencies" error

Make sure `gum` and `xurls` are installed and available in your PATH:

```bash
which gum    # Should show path to gum
which xurls  # Should show path to xurls
```

### "No URLs found" message

- Check that your pane actually contains URLs
- Try increasing `@url-buffer-lines` to scan more history
- Verify the URL format matches one of the supported patterns

### URLs not opening

- Verify the browser command works from terminal: `open https://example.com` (macOS) or `xdg-open https://example.com` (Linux)

## Similar Projects

- [tmux-urlview](https://github.com/tmux-plugins/tmux-urlview) - Uses urlview for URL extraction
- [tmux-fzf-url](https://github.com/wfxr/tmux-fzf-url) - Uses fzf for selection

## License

[MIT License](LICENSE)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Credits

Inspired by:
- [tmux-fzf](https://github.com/sainnhe/tmux-fzf) - Modular architecture pattern
- [tmux-urlview](https://github.com/tmux-plugins/tmux-urlview) - Original URL extraction concept
- [gum](https://github.com/charmbracelet/gum) - Beautiful terminal UI toolkit
