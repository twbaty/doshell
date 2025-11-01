#!/usr/bin/env bash
# ==============================================================================
# DOSHELL — Windows-style command aliases for Linux
# Author: Tom Baty
# Version: 1.2
# ==============================================================================
set -euo pipefail

VERSION_FILE="VERSION"
VERSION="$(cat "$VERSION_FILE" 2>/dev/null || echo 'v1.2')"

echo "DOSHELL — Windows-style command aliases for Linux ($VERSION)"
echo "(Showing milestones. Use --verbose for detailed output.)"

# ------------------------------------------------------------------------------
# Flags
# ------------------------------------------------------------------------------
DRY_RUN=false
VERBOSE=false
INSTALL=false
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
DOSHELL Setup Script
Usage: ./setup-doshell.sh [options]

Actions (choose one):
  --install        Install DOSHELL aliases
  --uninstall      Remove DOSHELL aliases and sourcing lines
  --reinstall      Uninstall, pull latest, then reinstall

Options:
  -h, --help       Show this help message
  --dry-run        Show what would be done without making changes
  --verbose        Print detailed actions as they happen
  -y, --yes        Assume 'yes' to all prompts
EOF
      exit 0
      ;;
    --dry-run) DRY_RUN=true ;;
    --verbose) VERBOSE=true ;;
    --install) INSTALL=true ;;
    --uninstall) UNINSTALL=true ;;
    --reinstall) REINSTALL=true ;;
    -y|--yes) ASSUME_YES=true ;;
    *) echo "Unknown option: $arg"; exit 1 ;;
  esac
done

# ------------------------------------------------------------------------------
# Safety: must specify an action
# ------------------------------------------------------------------------------
if ! $INSTALL && ! $UNINSTALL && ! $REINSTALL; then
  echo
  echo "Usage: ./setup-doshell.sh [--install|--uninstall|--reinstall] [options]"
  echo "Run with --help for details."
  exit 0
fi

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
# Shell Detection
# ------------------------------------------------------------------------------
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

  echo "🧹 DOSHELL uninstalled (aliases cleaned)."
}

# ------------------------------------------------------------------------------
# Install Logic
# ------------------------------------------------------------------------------
install_doshell() {
  mkdir -p "$(dirname "$ALIAS_FILE")"

  # --- Dependency Prompt ------------------------------------------------------
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

  # --- Package Manager Detection ---------------------------------------------
  local PKG_CMD="" EXTRA_PKGS=""
  if $INSTALL_DEPS; then
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

    if [ -n "$PKG_CMD" ]; then
      log "Installing supporting tools"
      run "Installing dependencies" "$PKG_CMD $EXTRA_PKGS"
    else
      echo "❌ Unsupported package manager — skipping dependency install."
      INSTALL_DEPS=false
    fi
  fi

  # --- Build Alias List ------------------------------------------------------
  log "Writing DOSHELL alias block"
  if ! $DRY_RUN; then
    {
      echo "$START_MARK"
      echo "# Core DOS-style command aliases for Linux shell environments"
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

      # dependent aliases only if deps installed
      if $INSTALL_DEPS; then
        cat <<'EOF'
alias tree='tree -C'
alias tracert='traceroute'
alias nslookup='dig'
alias format="echo 'Use mkfs or parted on Linux'"
alias chkdsk="echo 'Use fsck or smartctl on Linux'"
EOF
      else
        OMITTED_ALIASES+=(tree tracert nslookup format chkdsk)
      fi

      echo "$END_MARK"
    } >> "$ALIAS_FILE"
  fi

  # --- RC File Update --------------------------------------------------------
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

  # --- Notify if aliases were skipped ----------------------------------------
  if [ ${#OMITTED_ALIASES[@]} -gt 0 ]; then
    echo
    echo "[doshell] Skipping these aliases (dependencies not installed): ${OMITTED_ALIASES[*]}"
  fi

  # --- Optional source prompt ------------------------------------------------
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

  echo "🎉 DOSHELL setup complete."
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
