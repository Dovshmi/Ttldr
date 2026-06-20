# Ttldr

A tiny tmux helper that opens a right-side `tldr` cheatsheet for the command near your cursor.

Press `Ctrl-g` while working in tmux and Ttldr detects the command on the current prompt line, renders its `tldr` page, and shows it in a temporary side pane. Press `Ctrl-g` again to close it.

## Features

- Prefix-free tmux binding: `Ctrl-g`
- Detects common shell prompt styles (`$`, `#`, `%`, `❯`, `>`)
- Skips wrappers such as `sudo`, `doas`, `env`, `time`, and `command`
- Keeps your shell pane focused while the cheatsheet is open
- Re-running the installer safely updates the managed tmux config block
- Includes an uninstall mode

## Requirements

- `tmux`
- `tldr`
- `bash`
- `awk`
- `perl` for best ANSI stripping fallback behavior, usually already installed

Example dependency install commands:

```bash
# Debian/Ubuntu
sudo apt install tmux tldr perl

# Fedora
sudo dnf install tmux tldr perl

# Arch
sudo pacman -S tmux tldr perl
```

## Install

```bash
git clone https://github.com/Dovshmi/Ttldr.git
cd Ttldr
./install.sh
```

The installer:

1. Copies `bin/ttldr` to `~/.local/bin/ttldr`.
2. Writes this managed block to `~/.tmux.conf`:

```tmux
# BEGIN Ttldr
bind-key -n C-g run-shell -b "$HOME/.local/bin/ttldr '#{pane_id}' '#{client_name}'"
# END Ttldr
```

3. Reloads tmux automatically when run from inside tmux.

If you install outside tmux, reload manually:

```bash
tmux source-file ~/.tmux.conf
```

## Usage

In tmux, type or run a command such as:

```bash
ls -la
```

Then press:

```text
Ctrl-g
```

Press `Ctrl-g` again to close the cheatsheet pane.

## Uninstall

```bash
./install.sh --uninstall
```

This removes the managed tmux binding and deletes `~/.local/bin/ttldr`.

## Notes

- If `Ctrl-g` already has a tmux binding in your config, change the binding in `~/.tmux.conf` after installing.
- Ttldr reads only the visible tmux pane content; if the command prompt line has scrolled away, it may not detect a command.
- The sample `tmux.conf` file is for reference. The installer generates the real user-specific binding.

## Project layout

```text
bin/ttldr                 Helper script installed to ~/.local/bin/ttldr
install.sh                Installer and uninstaller
tmux.conf                 Sample tmux binding
.github/workflows/ci.yml  GitHub Actions checks
```

## License

MIT
