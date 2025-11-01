#!/bin/bash

echo "Doshell setup — version $(cat VERSION)"

# Flags
DRY_RUN=false
VERBOSE=false

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    -h|--help)
      echo "Doshell Setup Script"
      echo
      echo "Usage:"
      echo "  ./setup-doshell.sh [options]"
      echo
      echo "Options:"
      echo "  -h, --help       Show this help message"
      echo "  --dry-run        Show what would be done without making changes"
      echo "  --verbose        Print actions as they happen"
      exit 0
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    --verbose)
      VERBOSE=true
      ;;
    *)
      echo "Unknown option: $arg"
      exit 1
      ;;
  esac
done

ALIAS_FILE="$HOME/.bash_aliases"
ALIAS_SOURCE_LINE="[ -f ~/.bash_aliases ] && source ~/.bash_aliases"

do_action() {
  local desc="$1"
  local cmd="$2"

  if $DRY_RUN; then
    echo "[dry-run] $desc: $cmd"
  else
    if $VERBOSE; then
      echo "[doshell] $desc..."
    fi
    eval "$cmd"
  fi
}

do_action "Creating .bash_aliases with DOS-style mappings" "cat > \"$ALIAS_FILE\" <<'EOF'
# DOS-style command aliases for Linux shell environments

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
alias path='echo \$PATH'
alias prompt='echo \$PS1'
alias title='echo \"Use PS1 to customize prompt title\"'
alias chkdsk='echo \"Use fsck or smartctl on Linux\"'
alias attrib='lsattr'
alias echo='echo'
alias pause='read -p \"Press any key to continue...\"'
alias exit='logout'
alias more='more'
alias less='less'
alias find='find . -name'
alias sort='sort'
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
alias format='echo \"Use mkfs or parted on Linux\"'
EOF"

for shellrc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
  if [ -f "$shellrc" ] && ! grep -Fxq "$ALIAS_SOURCE_LINE" "$shellrc"; then
    do_action "Updating $shellrc to source .bash_aliases" "echo \"$ALIAS_SOURCE_LINE\" >> \"$shellrc\""
  fi
done

do_action "Installing supporting tools" "sudo apt update && sudo apt install -y \
  tree \
  dos2unix \
  traceroute \
  dnsutils \
  iproute2 \
  man-db \
  lsattr \
  coreutils \
  util-linux \
  bash-completion \
  nano \
  ncdu \
  dialog \
  whiptail \
  fzf"

do_action "Sourcing aliases now" ". \"$ALIAS_FILE\" 2>/dev/null || echo \"Manual source may be needed in this shell.\""

echo "🎉 Doshell setup complete. Restart your shell or run: source ~/.bash_aliases"
