#!/usr/bin/env bash
# ==============================================================================
# DOSHELL — Windows-style command aliases for Linux
# Author: Tom Baty
# Version: 1.10
# License: MIT
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/VERSION"
VERSION="$(cat "$VERSION_FILE" 2>/dev/null || echo 'v1.10')"
LOG_FILE="$HOME/.doshell.log"
DEPS_FILE="$HOME/.doshell.deps"
LICENSE_NOTE="Licensed under MIT — free to use, modify, and distribute with attribution"
COPYRIGHT_NOTE="© 2025 Tom Baty"

echo "DOSHELL — Windows-style command aliases for Linux ($VERSION)"
echo "$LICENSE_NOTE"
echo "$COPYRIGHT_NOTE"
echo

# ------------------------------------------------------------------------------
# Flags
# ------------------------------------------------------------------------------
DRY_RUN=false
VERBOSE=false
INSTALL=false
UNINSTALL=false
REINSTALL=false
ASSUME_YES=false
SHOW_VERSION=false

# ------------------------------------------------------------------------------
# Argument Parsing
# ------------------------------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    -h|--help)
      cat <<EOF
DOSHELL Setup Script
Usage: ./setup-doshell.sh [options]

Actions (choose one):
  --install        Install DOSHELL aliases
  --uninstall      Remove DOSHELL aliases and related files
  --reinstall      Uninstall, pull latest, then reinstall
  --version        Display DOSHELL version and log summary

Options:
  -h, --help       Show this help message
  --dry-run        Show what would be done without making changes
  --verbose        Print detailed actions as they happen
  -y, --yes        Assume 'yes' to all prompts

License: MIT — free to use, modify, and distribute with attribution
(c) 2025 Tom Baty
EOF
      exit 0
      ;;
    --dry-run)   DRY_RUN=true ;;
    --verbose)   VERBOSE=true ;;
    --install)   INSTALL=true ;;
    --uninstall) UNINSTALL=true ;;
    --reinstall) REINSTALL=true ;;
    --version)   SHOW_VERSION=true ;;
    -y|--yes)    ASSUME_YES=true ;;
    *) echo "Unknown option: $arg"; exit 1 ;;
  esac
done

# ------------------------------------------------------------------------------
# Version flag
# ------------------------------------------------------------------------------
if $SHOW_VERSION; then
  echo
  echo "Version: $VERSION"
  echo "$LICENSE_NOTE"
  echo "$COPYRIGHT_NOTE"
  echo
  if [ -f "$LOG_FILE" ]; then
    echo "Log file: $LOG_FILE"
    echo "  Last 5 log entries:"
    tail -n 5 "$LOG_FILE"
    echo
  else
    echo "No DOSHELL log file found."
    echo
  fi

  if [ -f "$DEPS_FILE" ]; then
    echo "Dependencies installed by DOSHELL:"
    cat "$DEPS_FILE"
  else
    echo "No recorded dependency installations."
  fi

  echo
  echo "Repository: https://github.com/twbaty/doshell"
  echo "For license details, see LICENSE or the header above."
  echo "==============================================================="
  exit 0
fi

# ------------------------------------------------------------------------------
# Require explicit action
# ------------------------------------------------------------------------------
if ! $INSTALL && ! $UNINSTALL && ! $REINSTALL; then
  echo
  echo "Usage: ./setup-doshell.sh [--install|--uninstall|--reinstall|--version] [options]"
  echo "Run with --help for details."
  exit 0
fi

# ------------------------------------------------------------------------------
# Environment setup
# ------------------------------------------------------------------------------
ALIAS_FILE="$HOME/.bash_aliases"
START_MARK="# >>> DOSHELL ALIASES START <<<"
END_MARK="# >>> DOSHELL ALIASES END <<<"
ALIAS_SOURCE_LINE='[ -f ~/.bash_aliases ] && source ~/.bash_aliases'

# Detect package manager — sets PKG_INSTALL, PKG_REMOVE, and DIG_PKG
PKG_INSTALL=""
PKG_REMOVE=""
DIG_PKG="dnsutils"
if command -v dnf >/dev/null 2>&1; then
  PKG_INSTALL="sudo dnf install -y"; PKG_REMOVE="sudo dnf remove -y"; DIG_PKG="bind-utils"
elif command -v yum >/dev/null 2>&1; then
  PKG_INSTALL="sudo yum install -y"; PKG_REMOVE="sudo yum remove -y"; DIG_PKG="bind-utils"
elif command -v apt-get >/dev/null 2>&1; then
  PKG_INSTALL="sudo apt-get install -y"; PKG_REMOVE="sudo apt-get remove -y"; DIG_PKG="dnsutils"
elif command -v apt >/dev/null 2>&1; then
  PKG_INSTALL="sudo apt install -y"; PKG_REMOVE="sudo apt remove -y"; DIG_PKG="dnsutils"
elif command -v pacman >/dev/null 2>&1; then
  PKG_INSTALL="sudo pacman -S --noconfirm"; PKG_REMOVE="sudo pacman -R --noconfirm"; DIG_PKG="bind"
fi

log() {
  local msg="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') — $msg" >> "$LOG_FILE"
  echo "[doshell] $msg"
}

run() {
  local desc="$1"
  local cmd="$2"
  log "$desc"
  if $DRY_RUN; then
    echo "   ↳ [dry-run] $cmd"
  elif $VERBOSE; then
    echo "   ↳ Running: $cmd"
    bash -c "$cmd" || echo "   ⚠️  Command failed: $cmd"
  else
    bash -c "$cmd" >/dev/null 2>&1 || echo "   ⚠️  Command failed: $cmd"
  fi
}

# Use $SHELL to detect the user's login shell — more reliable than ps inside a script
detect_shell_rc() {
  local shellname
  shellname=$(basename "${SHELL:-bash}")
  case "$shellname" in
    bash) echo "$HOME/.bashrc" ;;
    zsh)  echo "$HOME/.zshrc" ;;
    dash|sh) echo "$HOME/.profile" ;;
    *)    echo "unknown" ;;
  esac
}

# $1 = package to install; $2 (optional) = binary to check (defaults to $1)
install_dependency_if_missing() {
  local pkg="$1"
  local binary="${2:-$1}"
  if ! command -v "$binary" >/dev/null 2>&1; then
    run "Installing $pkg" "$PKG_INSTALL $pkg"
    echo "$pkg" >> "$DEPS_FILE"
  fi
}

# ------------------------------------------------------------------------------
# Uninstall Logic
# ------------------------------------------------------------------------------
uninstall_doshell() {
  log "Cleaning existing DOSHELL aliases"
  if [ -f "$ALIAS_FILE" ]; then
    # Use | as delimiter to avoid issues with < > # in the marker strings
    run "Removing DOSHELL section from aliases" \
      "sed -i \"\|$START_MARK|,\|$END_MARK|d\" \"$ALIAS_FILE\""
  fi

  local rcfile
  rcfile=$(detect_shell_rc)
  if [ "$rcfile" != "unknown" ] && [ -f "$rcfile" ]; then
    # Use grep -vF (fixed-string) to safely strip the source line without regex issues
    run "Removing sourcing line from $rcfile" \
      "grep -vF '$ALIAS_SOURCE_LINE' \"$rcfile\" > \"${rcfile}.doshell.tmp\" && mv \"${rcfile}.doshell.tmp\" \"$rcfile\""
  fi

  if [ -f "$DEPS_FILE" ]; then
    echo
    echo "[doshell] The following packages were installed by DOSHELL:"
    cat "$DEPS_FILE"
    local REMOVE_DEPS="n"
    if $ASSUME_YES; then
      REMOVE_DEPS="y"
    else
      read -rp "Remove these packages as part of uninstall? [y/N]: " REMOVE_DEPS || true
    fi
    if [[ "$REMOVE_DEPS" =~ ^[Yy]$ ]]; then
      if [ -n "$PKG_REMOVE" ]; then
        while read -r pkg; do
          run "Removing $pkg" "$PKG_REMOVE $pkg"
        done < "$DEPS_FILE"
      else
        echo "⚠️  No supported package manager found — please remove packages manually."
      fi
    fi
    rm -f "$DEPS_FILE"
  fi

  if [ -f "$LOG_FILE" ]; then
    local REMOVE_LOG="n"
    if $ASSUME_YES; then
      REMOVE_LOG="y"
    else
      read -rp "[doshell] Delete DOSHELL log file (~/.doshell.log)? [y/N]: " REMOVE_LOG || true
    fi
    if [[ "$REMOVE_LOG" =~ ^[Yy]$ ]]; then
      run "Deleting log file" "rm -f \"$LOG_FILE\""
    fi
  fi

  echo "DOSHELL uninstalled and cleaned. $LICENSE_NOTE"
}

# ------------------------------------------------------------------------------
# Install Logic
# ------------------------------------------------------------------------------
install_doshell() {
  # Prevent duplicate installs — use --reinstall to update
  if grep -qF "$START_MARK" "$ALIAS_FILE" 2>/dev/null; then
    echo "[doshell] Already installed. Use --reinstall to update."
    exit 0
  fi

  mkdir -p "$(dirname "$ALIAS_FILE")"

  local INSTALL_DEPS=false
  if $ASSUME_YES; then
    INSTALL_DEPS=true
  else
    echo
    local choice=""
    read -rp "[doshell] Some aliases rely on extra tools (tree, traceroute, dig, etc.). Install them? [Y/n]: " choice || true
    if [[ "$choice" =~ ^[Yy]$ || -z "$choice" ]]; then
      INSTALL_DEPS=true
    fi
  fi

  rm -f "$DEPS_FILE"

  if $INSTALL_DEPS && [ -n "$PKG_INSTALL" ]; then
    log "Checking and installing missing dependencies"
    install_dependency_if_missing "tree"
    install_dependency_if_missing "traceroute"
    install_dependency_if_missing "$DIG_PKG" "dig"
    install_dependency_if_missing "nano"
    install_dependency_if_missing "fzf"
  elif $INSTALL_DEPS; then
    echo "⚠️  No supported package manager found — skipping dependency install."
    echo "    Install tree, traceroute, dig, nano, and fzf manually if needed."
  fi

  log "Writing DOSHELL alias block"
  if ! $DRY_RUN; then
    {
      echo "$START_MARK"
      cat "$SCRIPT_DIR/doshell_aliases.sh"
      echo "$END_MARK"
    } >> "$ALIAS_FILE"
  fi

  local rcfile
  rcfile=$(detect_shell_rc)
  if [ "$rcfile" != "unknown" ]; then
    if [ -f "$rcfile" ] && ! grep -Fq "$ALIAS_SOURCE_LINE" "$rcfile"; then
      # Ensure file ends with a newline before appending
      if [ -s "$rcfile" ] && [ "$(tail -c1 "$rcfile" | wc -l)" -eq 0 ]; then
        echo "" >> "$rcfile"
      fi
      run "Ensuring $rcfile sources .bash_aliases" \
        "echo \"$ALIAS_SOURCE_LINE\" >> \"$rcfile\""
    fi
  else
    echo "⚠️  Unknown shell; please add the following to your shell rc file manually:"
    echo "   $ALIAS_SOURCE_LINE"
  fi

  echo
  echo "[doshell] To activate aliases, run:"
  echo "   source ~/.bash_aliases"
  echo "   — or open a new terminal."
  echo
  echo "🎉 DOSHELL setup complete. $LICENSE_NOTE"
}

# ------------------------------------------------------------------------------
# Main Logic
# ------------------------------------------------------------------------------
if $REINSTALL; then
  uninstall_doshell
  if [ -d "$SCRIPT_DIR/.git" ]; then
    run "Updating codebase" "git -C \"$SCRIPT_DIR\" pull"
  else
    echo "⚠️  Not a Git repository; skipping git pull."
  fi
  install_doshell
  exit 0
fi

if $UNINSTALL; then
  uninstall_doshell
  exit 0
fi

if $INSTALL; then
  install_doshell
  exit 0
fi
