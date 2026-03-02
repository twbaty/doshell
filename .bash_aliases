# DOS-style command aliases and functions for Linux shell environments
# Project: doshell — https://github.com/twbaty/doshell

# ------------------------------------------------------------
# File & directory navigation
# ------------------------------------------------------------
alias dir='ls -l --color=auto'
alias tree='tree -C'
alias copy='cp -i'
alias move='mv -i'
alias del='rm -i'
alias ren='mv'
alias md='mkdir -p'
alias rd='rmdir'
alias xcopy='cp -r'
alias deltree='rm -r'
alias type='cat'
alias findfile='find . -name'    # 'find' kept intact — use findfile for DOS-style search

# ------------------------------------------------------------
# Terminal
# ------------------------------------------------------------
alias cls='clear'
alias pause='read -p "Press any key to continue..."'
alias edit='nano'

# Open a file in the default editor (like notepad on Windows)
notepad() { ${EDITOR:-nano} "${1:-.}"; }

# Open a file, folder, or URL in the default app (like 'start' on Windows)
start()    { xdg-open "${1:-.}" 2>/dev/null & }
alias explorer='xdg-open .'

# ------------------------------------------------------------
# System info
# ------------------------------------------------------------
alias ver='uname -a'
alias where='which'
alias path='echo $PATH'
alias prompt='echo $PS1'
alias mem='free -h'
alias vol='df -h'
alias tasklist='ps aux'
alias attrib='lsattr'
alias comp='diff'
alias fc='diff'

sysinfo() {
    echo "--- OS ---"
    uname -a
    echo
    echo "--- CPU ---"
    lscpu 2>/dev/null | grep -E "^(Architecture|CPU\(s\)|Model name|CPU MHz)" || grep -m1 "model name" /proc/cpuinfo
    echo
    echo "--- Memory ---"
    free -h
    echo
    echo "--- Disk ---"
    df -h
}

# ------------------------------------------------------------
# Network
# ------------------------------------------------------------
alias ipconfig='ip a'
alias ping='ping -c 4'
alias tracert='traceroute'
alias netstat='ss -tuln'
alias nslookup='dig'

# ------------------------------------------------------------
# Process management
# ------------------------------------------------------------

# taskkill /PID <pid> [/F]   — kill by PID
# taskkill /IM <name> [/F]   — kill by process name
taskkill() {
    local pid="" name="" force=false
    while [[ $# -gt 0 ]]; do
        case "${1^^}" in
            /PID) pid="$2";  shift 2 ;;
            /IM)  name="$2"; shift 2 ;;
            /F)   force=true; shift ;;
            *)    shift ;;
        esac
    done
    if [[ -n "$name" ]]; then
        $force && pkill -9 -f "$name" || pkill -f "$name"
    elif [[ -n "$pid" ]]; then
        $force && kill -9 "$pid" || kill "$pid"
    else
        echo "Usage: taskkill /PID <pid> [/F]"
        echo "       taskkill /IM <name> [/F]"
    fi
}

# ------------------------------------------------------------
# System admin stubs
# These are Linux sysadmin tasks — doshell points you to the
# right native tool rather than wrapping it.
# ------------------------------------------------------------
alias chkdsk='echo    "Linux: sudo fsck /dev/sdX   (unmount first)"'
alias format='echo    "Linux: sudo mkfs.ext4 /dev/sdX  or  sudo parted"'
alias diskpart='echo  "Linux: sudo fdisk /dev/sdX   or   sudo parted"'
alias regedit='echo   "No registry on Linux. Config lives in /etc/ and ~/.config/"'
alias taskmgr='echo   "Linux: htop   (or top, or ps aux)"'
alias services='echo  "Linux: systemctl list-units --type=service"'
alias sc='echo        "Linux: sudo systemctl start|stop|status|enable|disable <service>"'
alias shutdown='echo  "Linux: sudo shutdown -h now  (halt)   sudo reboot  (restart)"'
