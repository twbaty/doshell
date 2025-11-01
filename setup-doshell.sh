#!/usr/bin/env bash
# ==============================================================================
# Doshell Setup Script - Safe Linux Wrapper for DOS-Style Aliases
# Author: Tom Baty
# Version: 1.1
# ==============================================================================
set -euo pipefail

VERSION_FILE="VERSION"
VERSION="$(cat "$VERSION_FILE" 2>/dev/null || echo 'unknown')"

echo "Doshell setup — version $VERSION"
echo "(Showing milestones. Use --verbose for detailed output.)"

# ------------------------------------------------------------------------------
# Flags
# ------------------------------------------------------------------------------
DRY_RUN=false
VERBOSE=false
UNINSTALL=false
REINSTALL=false
ASSUME_YES=false

# ------------------------------------------------------------------------------
# Argument Parsing
# ------------------------------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    -h|--help)
      cat <<EOF
Doshell Setup Script
Usage: ./setup-doshell.sh [options]

Options:
  -h, --help       Show this help message
  --dry-run        Show what would be done without making changes
  --verbose        Print detailed actions as they happen
  --uninstall      Remove Doshell aliases and related shell config
  --reinstall      Uninstall, pull latest code, then reinstall
  -y, --yes        Assume 'yes' to prompts
EOF
      exit 0
      ;;
    --dry-run) DRY_RUN=true ;;
    --verbose) VERBOSE=true ;;
    --uninstall) UNINSTALL=true ;;
    --reinstall) REINSTALL=true ;;
    -y|--yes) ASSUME_YES=true ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

# ------------------------------------------------------------------------------
# Environment Setup
# ------------------------------------------------------------------------------
ALIAS_FILE="$HOME/.bash_aliases"
LOG_FILE="$HOME/.doshell.log"
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

# ------------------------------------------------------------------------------
# Uninstall Logic
# ------------------------------------------------------------------------------
uninstall_doshell() {
  log "Cleaning existing DOSHELL aliases"
  if [ -f "$ALIAS_FILE" ]; then
    run "Removing DOSHELL section from aliases" \
      "sed -i '/$START_MARK/,/$END_MARK/d' \"$ALIAS_FILE\""
  fi

  for shellrc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [ -f "$shellrc" ]; then
      run "Removing sourcing line from $shellrc" \
        "sed -i '\\#${ALIAS_SOURCE_LINE}#d' \"$shellrc\""
    fi
  done

  echo "🧹 Doshell uninstalled (aliases cleaned)."
}

# ------------------------------------------------------------------------------
# Install Logic
# ------------------------------------------------------------------------------
install_doshell() {
  mkdir -p "$(dirname "$ALIAS_FILE")"

  log "Writing DOSHELL alias block"
  if ! $DRY_RUN; then
    {
      echo "$START_MARK"
      cat <<'EOF'
alias dir='ls -l --color=auto'
alias tree='tree -C'
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
alias title='echo "Use PS1 to customize prompt title"'
alias chkdsk='echo "Use fsck or smartctl on Linux"'
alias attrib='lsattr'
alias pause='read -p "Press any key to continue..."'
alias more='more'
alias less='less'
alias findfile='find . -name'
alias sortfile='sort'
alias ipconfig='ip a'
alias ping='ping -c 4'
alias tracert='traceroute'
alias netstat='ss -tuln'
alias hostname='hostname'
alias nslookup='dig'
alias edit='nano'
alias comp='diff'
alias fc='diff'
alias xcopy='cp -r'
alias movefile='mv'
alias deltree='rm -r'
alias format='echo "Use mkfs or parted on Linux"'
alias time='date +"%T"'
alias setvar='echo "Use export to set variables in Linux"'
EOF
      echo "$END_MARK"
    } >> "$ALIAS_FILE"
  fi

  for shellrc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$shellrc" ] && ! grep -Fq "$ALIAS_SOURCE_LINE" "$shellrc"; then
      run "Ensuring $shellrc sources .bash_aliases" \
        "echo \"$ALIAS_SOURCE_LINE\" >> \"$shellrc\""
    fi
  done

  PKG_CMD=""
  if command -v dnf >/dev/null 2>&1; then
    PKG_CMD="sudo dnf install -y"
    EXTRA_PKGS="tree traceroute bind-utils iproute man-db e2fsprogs attr util-linux bash-completion nano ncdu fzf"
  elif command -v yum >/dev/null 2>&1; then
    PKG_CMD="sudo yum install -y"
    EXTRA_PKGS="tree traceroute bind-utils iproute man-db e2fsprogs attr util-linux bash-completion nano ncdu fzf"
  elif command -v apt >/dev/null 2>&1; then
    PKG_CMD="sudo apt install -y"
    EXTRA_PKGS="tree traceroute dnsutils iproute2 man-db e2fsprogs attr util-linux bash-completion nano ncdu fzf"
  fi

  if [ -n "${PKG_CMD:-}" ]; then
    run "Installing supporting tools" "$PKG_CMD $EXTRA_PKGS"
  else
    echo "❌ Unsupported package manager — skipping package install."
  fi

  if $ASSUME_YES; then
    CHOICE="y"
  else
    read -rp "⚡ Source aliases now? [Y/n]: " CHOICE
  fi

  if [[ "$CHOICE" =~ ^[Yy]$ || -z "$CHOICE" ]]; then
    run "Sourcing aliases" "source \"$ALIAS_FILE\""
  else
    echo "ℹ️ Run 'source ~/.bash_aliases' to activate manually."
  fi

  echo "🎉 Doshell setup complete."
}

# ------------------------------------------------------------------------------
# Main
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

install_doshell
