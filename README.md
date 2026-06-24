# ⚡ Ttldr — tmux TLDR Helper

<div align="center">
  <img src="https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white" alt="Bash" />
  <img src="https://img.shields.io/badge/tmux-1BB91F?style=for-the-badge&logo=tmux&logoColor=white" alt="tmux" />
  <img src="https://img.shields.io/badge/tldr-Cheatsheets-2563EB?style=for-the-badge" alt="tldr Cheatsheets" />
  <img src="https://img.shields.io/badge/ShellCheck-Enabled-0F766E?style=for-the-badge" alt="ShellCheck" />
  <img src="https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white" alt="GitHub Actions" />
  <img src="https://img.shields.io/badge/tmux_Binding-Ctrl--g-64748B?style=for-the-badge" alt="tmux Ctrl-g Binding" />
  <img src="https://img.shields.io/badge/Installer-Included-111827?style=for-the-badge" alt="Installer Included" />
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="MIT License" />
</div>

<div align="center">
  <p><strong>A tiny tmux helper that opens the relevant TLDR cheatsheet beside your terminal without stealing focus from your shell.</strong></p>
  <p>
    <a href="https://github.com/Dovshmi/Ttldr"><strong>GitHub Repository</strong></a>
  </p>
</div>

---

## Overview

**Ttldr** is a small Bash utility for tmux users. Press `Ctrl-g` while working in a tmux pane and it detects the command near your cursor, opens a right-side helper pane, and renders the matching `tldr` page.

It is designed for fast terminal learning: no browser switch, no full-screen help menu, and no interruption to your active shell pane. Press `Ctrl-g` again to close the cheatsheet.

---

## Product Goals

- Make command examples instantly available while staying inside tmux.
- Keep the original shell pane focused while the help pane is open.
- Detect the relevant command from common prompt styles automatically.
- Avoid a plugin manager requirement.
- Keep installation and uninstall simple.
- Keep the project small, auditable, and shell-native.

---

## Core Features

- **Prefix-free tmux binding** using `Ctrl-g`.
- **Right-side cheatsheet pane** rendered next to the current shell.
- **Command detection near the cursor** from visible tmux pane content.
- **Common prompt support** for markers like `$`, `#`, `%`, `❯`, and `>`.
- **Wrapper skipping** for commands such as `sudo`, `doas`, `env`, `time`, and `command`.
- **Focus-preserving behavior** so your original shell pane remains active.
- **Toggle behavior**: press `Ctrl-g` again to close the helper pane.
- **Responsive pane sizing** based on the tmux client width.
- **Managed installer block** in `~/.tmux.conf` so rerunning the installer updates cleanly.
- **Uninstall mode** for removing the binding and helper script.
- **CI checks** using Bash syntax checks, ShellCheck, and installer smoke tests.

---

## Tech Stack

| Area | Technology |
| :--- | :--- |
| Runtime | Bash |
| Terminal Multiplexer | tmux |
| Cheatsheet Provider | `tldr` CLI |
| Text Processing | awk + optional perl ANSI stripping |
| Installer | Bash `install.sh` |
| CI | GitHub Actions |
| Quality Checks | `bash -n`, ShellCheck, installer smoke test |
| License | MIT |

---

## Project Structure

```text
Ttldr/
├── .github/
│   └── workflows/
│       └── ci.yml          # Bash, ShellCheck, and installer smoke checks
├── bin/
│   └── ttldr               # Main tmux helper script
├── install.sh              # Installer and uninstaller
├── tmux.conf               # Reference tmux binding
├── LICENSE                 # MIT license
└── README.md
```

---

## Requirements

Required:

- `tmux`
- `tldr`
- `bash`
- `awk`

Recommended:

- `perl` for better ANSI escape stripping fallback behavior.

Install dependencies on common Linux distributions:

```bash
# Debian / Ubuntu
sudo apt install tmux tldr perl

# Fedora
sudo dnf install tmux tldr perl

# Arch
sudo pacman -S tmux tldr perl
```

---

## Installation

Clone the repository:

```bash
git clone https://github.com/Dovshmi/Ttldr.git
cd Ttldr
```

Run the installer:

```bash
chmod +x install.sh
./install.sh
```

The installer copies the helper to:

```text
~/.local/bin/ttldr
```

It also writes a managed tmux binding to:

```text
~/.tmux.conf
```

The generated binding uses `Ctrl-g`:

```tmux
# BEGIN Ttldr
bind-key -n C-g run-shell -b "$HOME/.local/bin/ttldr '#{pane_id}' '#{client_name}'"
# END Ttldr
```

If you install outside tmux, reload tmux manually:

```bash
tmux source-file ~/.tmux.conf
```

---

## Usage

In tmux, type or run a command, for example:

```bash
ls -la
```

Then press:

```text
Ctrl-g
```

Ttldr will open a helper pane with the relevant TLDR examples.

Press `Ctrl-g` again to close the helper pane.

---

## How Detection Works

Ttldr reads the visible content of the current tmux pane, checks the cursor line first, and then scans upward for a shell prompt line. It extracts the command name, removes common wrappers, and renders the matching `tldr` page.

Examples of supported shell prompt styles include:

```text
$ ls -la
# systemctl status ssh
% git status
❯ docker ps
> npm run dev
```

Wrapper examples that are skipped:

```text
sudo apt update
command ls
/usr/bin/git status
```

In each case, Ttldr tries to identify the real command and show the matching page.

---

## Uninstall

Remove the managed tmux binding and helper script:

```bash
./install.sh --uninstall
```

This removes:

```text
~/.local/bin/ttldr
```

It also removes the managed `Ttldr` block from `~/.tmux.conf`.

---

## Quality and CI

The repository includes a GitHub Actions workflow that checks the shell scripts on push and pull request.

The CI pipeline runs:

- Bash syntax checks for `install.sh` and `bin/ttldr`.
- ShellCheck on both scripts.
- Installer smoke test in a temporary home directory.
- tmux startup validation.
- Uninstall verification.

Run the most important local checks manually:

```bash
bash -n install.sh
bash -n bin/ttldr
shellcheck install.sh bin/ttldr
```

---

## Design Notes

- **No plugin manager required:** the installer writes the tmux binding directly.
- **Safe reruns:** the installer replaces its managed block instead of duplicating it.
- **Focus stays in the shell:** the helper pane opens in the background and returns focus to the original pane.
- **Small surface area:** the project is one helper script plus one installer.
- **Terminal-native:** no GUI, no browser dependency, and no background service.

---

## Troubleshooting

### `Ctrl-g` does nothing

Reload tmux:

```bash
tmux source-file ~/.tmux.conf
```

Then check whether another binding is already using `Ctrl-g`.

### No command is detected

Ttldr only reads visible tmux pane content. If the command prompt line has scrolled away, type the command again or keep the prompt line visible before pressing `Ctrl-g`.

### `tldr` is missing

Install the `tldr` command-line client with your system package manager, then run:

```bash
tldr --update
```

---

## Roadmap Ideas

Potential future improvements:

- Add optional custom key binding during install.
- Add a configuration file for pane width and position.
- Add support for more prompt styles.
- Add a small demo GIF or screenshot to the README.
- Add more CI cases for command extraction behavior.

---

## License

This project is licensed under the **MIT License**.

---

<div align="center">
  Built for fast command help inside tmux.<br />
  By Rony Shmidov
</div>
