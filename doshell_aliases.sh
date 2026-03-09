# shellcheck shell=bash
# ==============================================================================
# DOSHELL — DOS-style command aliases and functions for Linux
# Source: https://github.com/twbaty/doshell
# License: MIT — © 2025 Tom Baty
# ==============================================================================

# File & directory
alias dir='ls -l --color=auto'
alias copy='cp -i'
alias move='mv -i'
alias del='rm -i'
alias ren='mv'
alias md='mkdir -p'
alias rd='rmdir'
alias xcopy='cp -ri'
alias deltree='rm -ri'
alias findfile='find . -name'

# Terminal
alias cls='clear'
alias edit='nano'
# pause: single-keypress wait — no Enter needed, like Windows pause
alias pause='read -rsn1 -p "Press any key to continue..."; echo'

# Open a file in the default editor (like notepad on Windows)
notepad() { ${EDITOR:-nano} "${1:-.}"; }

# Open a file, folder, or URL in the default app (like 'start' on Windows)
start() { xdg-open "${1:-.}" >/dev/null 2>&1 & }
alias explorer='xdg-open .'

# System info
alias ver='uname -a'
alias where='which'
alias path='echo "$PATH"'
alias prompt='echo "$PS1"'
alias mem='free -h'
alias vol='df -h'
alias tasklist='ps aux'
alias attrib='lsattr'
alias comp='diff'

# Network
alias ipconfig='ip a'
alias ping='ping -c 4'
alias netstat='ss -tuln'

# Optional — only aliased if the tool is installed
command -v tree       >/dev/null 2>&1 && alias tree='tree -C'
command -v traceroute >/dev/null 2>&1 && alias tracert='traceroute'
command -v dig        >/dev/null 2>&1 && alias nslookup='dig'

# System admin stubs — tell you the right Linux tool rather than hiding it
alias chkdsk='echo "Linux: sudo fsck /dev/sdX   (unmount first)"'
alias format='echo "Linux: sudo mkfs.ext4 /dev/sdX  or  sudo parted"'
alias diskpart='echo "Linux: sudo fdisk /dev/sdX   or   sudo parted"'
alias regedit='echo "No registry on Linux. Config lives in /etc/ and ~/.config/"'
alias taskmgr='echo "Linux: htop   (or top, or ps aux)"'
alias services='echo "Linux: systemctl list-units --type=service"'
alias sc='echo "Linux: sudo systemctl start|stop|status|enable|disable <service>"'
alias shutdown='echo "Linux: sudo shutdown -h now  (halt)   sudo reboot  (restart)"'

# sysinfo — condensed systeminfo analog
sysinfo() {
    echo "--- OS ---"; uname -a; echo
    echo "--- CPU ---"
    lscpu 2>/dev/null | grep -E "^(Architecture|CPU\(s\)|Model name|CPU MHz)" \
        || grep -m1 "model name" /proc/cpuinfo
    echo
    echo "--- Memory ---"; free -h; echo
    echo "--- Disk ---";   df -h
}

# taskkill /PID <pid> [/F]  |  taskkill /IM <name> [/F]
taskkill() {
    local pid="" name="" force=false
    while [[ $# -gt 0 ]]; do
        case "${1^^}" in
            /PID) pid="${2:-}";  shift 2 ;;
            /IM)  name="${2:-}"; shift 2 ;;
            /F)   force=true; shift ;;
            *)    shift ;;
        esac
    done
    if [[ -n "$name" ]]; then
        if $force; then pkill -9 -f "$name"; else pkill -f "$name"; fi
    elif [[ -n "$pid" ]]; then
        if $force; then kill -9 "$pid"; else kill "$pid"; fi
    else
        echo "Usage: taskkill /PID <pid> [/F]"
        echo "       taskkill /IM <name> [/F]"
    fi
}
