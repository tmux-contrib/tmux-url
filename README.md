# tmux-url

A tmux plugin that extracts URLs from the current pane and allows interactive selection using [gum](https://github.com/charmbracelet/gum).

## Features

- 🔍 **Smart URL Detection**: Extracts URLs with explicit schemes (http, https, ftp, git, ssh), email addresses, and common domain names
- 🎯 **Interactive Selection**: Beautiful terminal UI powered by gum filter
- 🚀 **Quick Access**: Simple `Prefix + u` keybinding
- 🌐 **Cross-Platform**: Works on macOS, Linux, and Windows
- ⚙️ **Configurable**: Customize key bindings, browser, buffer depth, and UI height
- 📋 **Deduplication**: Automatically removes duplicate URLs

## Requirements

- [tmux](https://github.com/tmux/tmux) (version 1.8+)
- [gum](https://github.com/charmbracelet/gum) - Terminal UI toolkit
- [perl](https://www.perl.org/) - Usually pre-installed on macOS/Linux

### Installing Dependencies

**gum**:
- macOS: `brew install gum`
- Linux: See [gum installation guide](https://github.com/charmbracelet/gum#installation)
- Windows: See [gum releases](https://github.com/charmbracelet/gum/releases)

**perl**: Usually pre-installed on most systems. If not:
- macOS: Should be available by default
- Linux: `apt-get install perl` or `yum install perl`

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

### Browser Command

Specify a custom browser (default: auto-detected):

```bash
set -g @url-browser 'firefox'           # Use Firefox
set -g @url-browser 'google-chrome'     # Use Chrome
set -g @url-browser 'open -a Safari'    # Use Safari on macOS
```

**Auto-detection** (if not specified):
- macOS: `open`
- Linux: `xdg-open`
- Windows: `start`

### Buffer Scan Depth

Set how many lines to scan from pane history (default: `10000`):

```bash
set -g @url-buffer-lines 5000
```

### UI Height

Configure gum filter height (default: `20`):

```bash
set -g @url-gum-height 15
```

### Example Configuration

```bash
# ~/.tmux.conf

# Custom key binding
set -g @url-key 'o'

# Use Firefox
set -g @url-browser 'firefox'

# Scan last 5000 lines
set -g @url-buffer-lines 5000

# Show 15 lines in picker
set -g @url-gum-height 15

# Load plugin
set -g @plugin 'tmux-contrib/tmux-url'
```

## URL Detection Patterns

The plugin extracts three types of URLs (in order of precedence):

1. **Explicit Schemes**: `https://`, `http://`, `ftp://`, `ssh://`, `git://`
   - Example: `https://github.com/tmux-contrib/tmux-url`

2. **Email Addresses**: Converted to `mailto:` links
   - Example: `user@example.com` → `mailto:user@example.com`

3. **Domain Names**: Common TLDs without schemes (auto-prepends `https://`)
   - Example: `github.com` → `https://github.com`
   - Supported TLDs: .com, .org, .net, .io, .dev, .app, .co, .edu, and many more

## Troubleshooting

### "Missing dependencies" error

Make sure `gum` and `perl` are installed and available in your PATH:

```bash
which gum   # Should show path to gum
which perl  # Should show path to perl
```

### "No URLs found" message

- Check that your pane actually contains URLs
- Try increasing `@url-buffer-lines` to scan more history
- Verify the URL format matches one of the supported patterns

### URLs not opening

- Check that your browser is correctly configured
- Try setting `@url-browser` explicitly
- Verify the browser command works from terminal: `open https://example.com`

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
