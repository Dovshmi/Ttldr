#!/usr/bin/env bash

set -euo pipefail

project_name="Ttldr"
package_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
helper_src="$package_dir/bin/ttldr"
helper_dest="$HOME/.local/bin/ttldr"
tmux_conf="$HOME/.tmux.conf"
block_start="# BEGIN Ttldr"
block_end="# END Ttldr"
old_block_start="# BEGIN tmux-tldr-menu"
old_block_end="# END tmux-tldr-menu"

usage() {
  cat <<'EOF'
Usage: ./install.sh [--uninstall]

Installs Ttldr to ~/.local/bin/ttldr and writes a managed Ctrl-g binding to
~/.tmux.conf. Re-run the installer to update the binding safely.
EOF
}

remove_managed_binding() {
  local tmp_conf

  touch "$tmux_conf"
  tmp_conf="$(mktemp)"

  awk \
    -v start="$block_start" \
    -v end="$block_end" \
    -v old_start="$old_block_start" \
    -v old_end="$old_block_end" '
      $0 == start || $0 == old_start { in_block = 1; next }
      $0 == end || $0 == old_end { in_block = 0; next }
      in_block { next }
      /tmux-tldr-popup/ { next }
      /\.local\/bin\/ttldr/ { next }
      { print }
    ' "$tmux_conf" > "$tmp_conf"

  cat "$tmp_conf" > "$tmux_conf"
  rm -f "$tmp_conf"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" == "--uninstall" ]]; then
  remove_managed_binding
  rm -f "$helper_dest"
  if command -v tmux >/dev/null 2>&1 && [[ -n "${TMUX:-}" ]]; then
    tmux source-file "$tmux_conf"
    printf 'Removed %s binding and reloaded tmux config.\n' "$project_name"
  else
    printf 'Removed %s binding. Reload tmux with: tmux source-file ~/.tmux.conf\n' "$project_name"
  fi
  printf 'Removed helper: %s\n' "$helper_dest"
  exit 0
fi

if [[ $# -gt 0 ]]; then
  usage >&2
  exit 2
fi

if [[ ! -f "$helper_src" ]]; then
  printf 'Missing helper script: %s\n' "$helper_src" >&2
  exit 1
fi

if ! command -v tmux >/dev/null 2>&1; then
  printf 'Warning: tmux is not installed or is not on PATH.\n' >&2
fi

if ! command -v tldr >/dev/null 2>&1; then
  printf 'Warning: tldr is not installed or is not on PATH.\n' >&2
fi

mkdir -p "$HOME/.local/bin"
cp "$helper_src" "$helper_dest"
chmod +x "$helper_dest"

remove_managed_binding

helper_shell="$(printf '%q' "$helper_dest")"
binding_line="bind-key -n C-g run-shell -b \"$helper_shell '#{pane_id}' '#{client_name}'\""

{
  cat "$tmux_conf"
  printf '\n%s\n%s\n%s\n' "$block_start" "$binding_line" "$block_end"
} > "$tmux_conf.tmp"
mv "$tmux_conf.tmp" "$tmux_conf"

printf 'Installed %s helper to %s\n' "$project_name" "$helper_dest"
printf 'Installed/updated Ctrl-g binding in %s\n' "$tmux_conf"

if command -v tmux >/dev/null 2>&1 && [[ -n "${TMUX:-}" ]]; then
  tmux source-file "$tmux_conf"
  printf 'Reloaded tmux config.\n'
else
  printf 'Install complete. Start tmux or run: tmux source-file ~/.tmux.conf\n'
fi
