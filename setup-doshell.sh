#!/usr/bin/env bash
# ==============================================================================
# DOSHELL — Windows-style command aliases for Linux
# Author: Tom Baty
# Version: 1.5 Final
# License: MIT
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the “Software”), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# ==============================================================================

set -euo pipefail

VERSION_FILE="VERSION"
VERSION="$(cat "$VERSION_FILE" 2>/dev/null || echo 'v1.5 Final')"
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
    --dry-run) DRY_RUN=true ;;
    --verbose) VERBOSE=true ;;
    --install) INSTALL=true ;;
    --uninstall) UNINSTALL=true ;;
    --reinstall) REINSTALL=true ;;
    --version) SHOW_VERSION=true ;;
    -y|--yes) ASSUME_YES=true ;;
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
  else
    if $VERBOSE; then
      echo "   ↳ Running: $cmd"
      bash -c "$cmd"
    else
      bash -c "$cmd" >/dev/null 2>&1 || echo "   ⚠️  Command failed: $cmd"
    fi
  fi
}

detect_shell_rc() {
  local shellname
  shellname=$(ps -p $$ -o comm= | sed 's/^-//')
  case "$shellname" in
    bash) echo "$HOME/.bashrc" ;;
    zsh)  echo "$HOME/.zshrc" ;;
    dash) echo "$HOME/.profile" ;;
    *)    echo "unknown" ;;
  esac
}

install_dependency_if_missing() {
  local pkg="$1"
  if ! command -v "${pkg%% *}" >/dev/null 2>&1; then
    run "Installing $pkg" "$PKG_CMD install -y $pkg"
    echo "$pkg" >> "$DEPS_FILE"
  fi
}

# ------------------------------------------------------------------------------
# Uninstall Logic
# ------------------------------------------------------------------------------
uninstall_doshell() {
  log "Cleaning existing DOSHELL aliases"
  if [ -f "$ALIAS_FILE" ]; then
    run "Removing DOSHELL section from aliases" \
      "sed -i '/$START_MARK/,/$END_MARK/d' \"$ALIAS_FILE\""
  fi

  local rcfile
  rcfile=$(detect_shell_rc)
  if [ "$rcfile" != "unknown" ] && [ -f "$rcfile" ]; then
    run "Removing sourcing line from $rcfile" \
      "sed -i '\\#${ALIAS_SOURCE_LINE}#d' \"$rcfile\""
  fi

  if [ -f "$DEPS_FILE" ]; then
    echo
    echo "[doshell] The following packages were installed by DOSHELL:"
    cat "$DEPS_FILE"
    if $ASSUME_YES; then
      REMOVE_DEPS="y"
    else
      read -rp "Remove these packages as part of uninstall? [y/N]: " REMOVE_DEPS
    fi
    if [[ "$REMOVE_DEPS" =~ ^[Yy]$ ]]; then
      while read -r pkg; do
        run "Removing $pkg" "$PKG_CMD remove -y $pkg"
      done < "$DEPS_FILE"
    fi
    rm -f "$DEPS_FILE"
  fi

  if [ -f "$LOG_FILE" ]; then
    if $ASSUME_YES; then
      REMOVE_LOG="y"
    else
      read -rp "[doshell] Delete DOSHELL log file (~/.doshell.log)? [y/N]: " REMOVE_LOG
    fi
    if [[ "$REMOVE_LOG" =~ ^[Yy]$ ]]; then
      run "Deleting log file" "rm -f \"$LOG_FILE\""
    fi
  fi

  echo "🎯 DOSHELL uninstalled and cleaned. $LICENSE_NOTE"
}

# ------------------------------------------------------------------------------
# Install Logic
# ------------------------------------------------------------------------------
install_doshell() {
  mkdir -p "$(dirname "$ALIAS_FILE")"

  if command -v dnf >/dev/null 2>&1; then
    PKG_CMD="sudo dnf"
  elif command -v yum >/dev/null 2>&1; then
    PKG_CMD="sudo yum"
  elif command -v apt >/dev/null 2>&1; then
    PKG_CMD="sudo apt"
  else
    PKG_CMD=""
  fi

  local INSTALL_DEPS=false
  if $ASSUME_YES; then
    INSTALL_DEPS=true
  else
    echo
    read -rp "[doshell] Some aliases rely on extra tools (tree, traceroute, dig, etc.). Install them? [Y/n]: " choice
    if [[ "$choice" =~ ^[Yy]$ || -z "$choice" ]]; then
      INSTALL_DEPS=true
    fi
  fi

  local OMITTED_ALIASES=()
  rm -f "$DEPS_FILE" || true

  if $INSTALL_DEPS && [ -n "$PKG_CMD" ]; then
    log "Checking and installing missing dependencies"
    install_dependency_if_missing "tree"
    install_dependency_if_missing "traceroute"
    install_dependency_if_missing "dig"
    install_dependency_if_missing "nano"
    install_dependency_if_missing "fzf"
  elif ! $INSTALL_DEPS; then
    OMITTED_ALIASES+=(tree tracert nslookup format chkdsk)
  else
    echo "❌ Unsupported package manager — skipping dependency install."
  fi

  log "Writing DOSHELL alias block"
  if ! $DRY_RUN; then
    {
      echo "$START_MARK"
      echo "# Core DOS-style command aliases"
      cat <<'EOF'
alias dir='ls -l --color=auto'
alias copy='cp -i'
alias move='mv -i'
alias del='rm -i'
alias ren='mv'
alias md='mkdir -p'
alias rd='rmdir'
alias type='cat'
alias cls='clear'
alias ver='uname -a'
alias help='man'
alias path='echo $PATH'
alias prompt='echo $PS1'
alias attrib='lsattr'
alias pause='read -p "Press any key to continue..."'
alias more='more'
alias less='less'
alias findfile='find . -name'
alias sortfile='sort'
alias ipconfig='ip a'
alias ping='ping -c 4'
alias netstat='ss -tuln'
alias hostname='hostname'
alias edit='nano'
alias comp='diff'
alias fc='diff'
alias xcopy='cp -r'
alias movefile='mv'
alias deltree='rm -r'
alias time='date +"%T"'
EOF
      if $INSTALL_DEPS; then
        cat <<'EOF'
alias tree='tree -C'
alias tracert='traceroute'
alias nslookup='dig'
alias format="echo 'Use mkfs or parted on Linux'"
alias chkdsk="echo 'Use fsck or smartctl on Linux'"
EOF
      fi
      echo "$END_MARK"
    } >> "$ALIAS_FILE"
  fi

  local rcfile
  rcfile=$(detect_shell_rc)
  if [ "$rcfile" != "unknown" ]; then
    if [ -f "$rcfile" ] && ! grep -Fq "$ALIAS_SOURCE_LINE" "$rcfile"; then
      run "Ensuring $rcfile sources .bash_aliases" \
        "echo \"$ALIAS_SOURCE_LINE\" >> \"$rcfile\""
    fi
  else
    echo "⚠️ Unknown shell; please source ~/.bash_aliases manually."
  fi

  if [ ${#OMITTED_ALIASES[@]} -gt 0 ]; then
    echo
    echo "[doshell] Skipping these aliases (dependencies not installed): ${OMITTED_ALIASES[*]}"
  fi

  if $ASSUME_YES; then
    CHOICE="y"
  else
    echo
    read -rp "⚡ Source aliases now? [Y/n]: " CHOICE
  fi
  if [[ "$CHOICE" =~ ^[Yy]$ || -z "$CHOICE" ]]; then
    run "Sourcing aliases" "source \"$ALIAS_FILE\""
  else
    echo "ℹ️ Run 'source ~/.bash_aliases' to activate manually."
  fi

  echo "🎉 DOSHELL setup complete. $LICENSE_NOTE"
}

# ------------------------------------------------------------------------------
# Main Logic
# ------------------------------------------------------------------------------
if $REINSTALL; then
  uninstall_doshell
  if [ -d .git ]; then
    run "Updating codebase" "git pull"
  else
    echo "⚠️ Not a Git repository; skipping git pull."
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
