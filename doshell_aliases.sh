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

# type shadows a bash builtin so it was removed — typefile is the safe equivalent
typefile() { cat "${1:?Usage: typefile <file>}"; }

# Terminal
alias cls='clear'
alias edit='nano'
# pause: single-keypress wait — no Enter needed, like Windows pause
alias pause='read -rsn1 -p "Press any key to continue..."; echo'

# title: set the terminal window/tab title
title() { printf '\033]0;%s\007' "$*"; }

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

# set: show/export environment variables — passes shell flags through to builtin
# Usage: set              → list all env vars (sorted)
#        set VAR          → show vars matching prefix VAR
#        set VAR=value    → export VAR=value into current session
#        set -x / +e etc. → forwarded to bash builtin (shell options unchanged)
set() {
    if [[ $# -eq 0 ]]; then
        printenv | sort
    elif [[ "$1" == [-+]* ]]; then
        builtin set "$@"
    elif [[ "$1" == *=* ]]; then
        # shellcheck disable=SC2163
        export "${1?}"
    else
        printenv | grep "^${1}" | sort
    fi
}

# Network
alias ipconfig='ip a'
alias ping='ping -c 4'
alias netstat='ss -tuln'

# Optional — only aliased if the tool is installed
command -v tree       >/dev/null 2>&1 && alias tree='tree -C'
command -v traceroute >/dev/null 2>&1 && alias tracert='traceroute'
command -v dig        >/dev/null 2>&1 && alias nslookup='dig'
# arp and route: only stub if the native tool is absent
command -v arp        >/dev/null 2>&1 || alias arp='echo "Linux: ip neigh"'
command -v route      >/dev/null 2>&1 || alias route='echo "Linux: ip route   or   ip route add/del"'

# runas: run a command as another user (sudo wrapper with Windows-style /user: flag)
# Usage: runas /user:username command   or   runas command   (runs as root)
runas() {
    case "$1" in
        /user:*|/USER:*)
            local user="${1#*:}"; shift; sudo -u "$user" "$@" ;;
        *)
            sudo "$@" ;;
    esac
}

# clip: pipe stdin to the clipboard — like Windows 'clip'
# Usage: echo "hello" | clip     cat file.txt | clip
clip() {
    if command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard
    elif command -v xsel >/dev/null 2>&1; then
        xsel --clipboard --input
    elif command -v wl-copy >/dev/null 2>&1; then
        wl-copy
    else
        echo "clip: no clipboard tool found — install xclip, xsel, or wl-clipboard"
        return 1
    fi
}

# mklink: create symbolic or hard links with Windows-style syntax
# Usage: mklink [/D] [/J] [/H] <link> <target>
#        /D /J  symbolic link (directory)    /H  hard link
mklink() {
    local hard=false link="" target=""
    while [[ $# -gt 0 ]]; do
        case "${1^^}" in
            /D|/J) shift ;;
            /H)    hard=true; shift ;;
            *)
                if [[ -z "$link" ]]; then link="$1"
                else target="$1"; fi
                shift ;;
        esac
    done
    if [[ -z "$link" || -z "$target" ]]; then
        echo "Usage: mklink [/D] [/H] [/J] <link> <target>"
        echo "       /D /J  symbolic link   /H  hard link"
        return 1
    fi
    if $hard; then ln "$target" "$link"; else ln -s "$target" "$link"; fi
}

# findstr: search for text in files with Windows-style flags (grep wrapper)
# Usage: findstr [/i] [/r] [/n] [/v] [/s] [/m] [/c:"string"] pattern [files...]
#        /i  case-insensitive    /r  regular expression (default: literal)
#        /n  show line numbers   /v  invert (show non-matching lines)
#        /s  search recursively  /m  print filenames only
findstr() {
    local fixed=true icase=false extra_flags=() pattern="" files=() has_pattern=false
    while [[ $# -gt 0 ]]; do
        case "${1^^}" in
            /I)   icase=true;  shift ;;
            /R)   fixed=false; shift ;;
            /L)   fixed=true;  shift ;;
            /N)   extra_flags+=("-n"); shift ;;
            /V)   extra_flags+=("-v"); shift ;;
            /S)   extra_flags+=("-r"); shift ;;
            /M)   extra_flags+=("-l"); shift ;;
            /C:*) pattern="${1:3}"; has_pattern=true; shift ;;
            /*)   shift ;;
            *)
                if ! $has_pattern; then
                    pattern="$1"; has_pattern=true
                else
                    files+=("$1")
                fi
                shift ;;
        esac
    done
    if ! $has_pattern; then
        echo "Usage: findstr [/i] [/r] [/n] [/v] [/s] [/m] [/c:\"string\"] pattern [files...]"
        return 1
    fi
    local match_flag
    if $fixed; then match_flag="-F"; else match_flag="-E"; fi
    local args=("$match_flag")
    if $icase; then args+=("-i"); fi
    args+=("${extra_flags[@]}")
    if [[ ${#files[@]} -gt 0 ]]; then
        grep "${args[@]}" -- "$pattern" "${files[@]}"
    else
        grep "${args[@]}" -- "$pattern"
    fi
}

# net: Windows net command stubs with Linux equivalents
net() {
    case "${1,,}" in
        user)    echo "Linux: id / getent passwd / sudo useradd / usermod / userdel" ;;
        start)   echo "Linux: sudo systemctl start ${2:-<service>}" ;;
        stop)    echo "Linux: sudo systemctl stop ${2:-<service>}" ;;
        restart) echo "Linux: sudo systemctl restart ${2:-<service>}" ;;
        share)   echo "Linux: /etc/samba/smb.conf (Samba)   or   /etc/exports (NFS)" ;;
        use)     echo "Linux: sudo mount -t cifs //server/share /mnt/point   or   sshfs" ;;
        view)    echo "Linux: nmblookup -S '*'   or   smbtree (requires samba-client)" ;;
        *)       printf "Linux equivalents for Windows net commands:\n"
                 printf "  net user         → id / getent passwd / useradd\n"
                 printf "  net start|stop   → sudo systemctl start|stop <service>\n"
                 printf "  net use          → mount (CIFS/NFS) or sshfs\n"
                 printf "  net share        → /etc/samba/smb.conf or /etc/exports\n" ;;
    esac
}

# ==============================================================================
# PowerShell aliases — for users who live in PS and land on bash
# ==============================================================================

# gl / pwd — Get-Location
alias gl='pwd'

# gal — Get-Alias: list all active aliases
alias gal='alias'

# gps — Get-Process
alias gps='ps aux'

# gcm — Get-Command: find where a command lives
gcm() { command -v "${1:?Usage: gcm <command>}"; }

# ii — Invoke-Item: open a file or folder in the default app (like 'start')
alias ii='xdg-open'

# gv — Get-Variable: show environment variables
gv() {
    if [[ $# -eq 0 ]]; then printenv | sort
    else printenv | grep "^${1}" | sort; fi
}

# ni — New-Item: create a file or directory
# Usage: ni <file>   or   ni -ItemType Directory <dirname>
ni() {
    if [[ "${1,,}" == "-itemtype" && "${2,,}" == "directory" ]]; then
        mkdir -p "${3:?Usage: ni -ItemType Directory <dirname>}"
    else
        touch "${1:?Usage: ni <filename>}"
    fi
}

# spps — Stop-Process: kill by name or PID with optional -Force
# Usage: spps -Name <name> [-Force]   or   spps -Id <pid> [-Force]
spps() {
    local name="" pid="" force=false
    while [[ $# -gt 0 ]]; do
        case "${1,,}" in
            -name)  name="${2:-}"; shift 2 ;;
            -id)    pid="${2:-}";  shift 2 ;;
            -force) force=true; shift ;;
            *)
                if [[ "$1" =~ ^[0-9]+$ ]]; then pid="$1"; else name="$1"; fi
                shift ;;
        esac
    done
    if [[ -n "$name" ]]; then
        if $force; then pkill -9 -f "$name"; else pkill -f "$name"; fi
    elif [[ -n "$pid" ]]; then
        if $force; then kill -9 "$pid"; else kill "$pid"; fi
    else
        echo "Usage: spps -Name <name> [-Force]"
        echo "       spps -Id <pid> [-Force]"
    fi
}

# sls — Select-String: search for patterns in files or stdin (case-insensitive by default)
# Usage: sls [pattern] [files...]   or   cat file | sls pattern
#        -CaseSensitive   -NotMatch   -Pattern <pattern>
sls() {
    local icase="-i" invert="" pattern="" files=() has_pattern=false
    while [[ $# -gt 0 ]]; do
        case "${1,,}" in
            -casesensitive) icase="";       shift ;;
            -notmatch)      invert="-v";    shift ;;
            -pattern)       pattern="${2:-}"; has_pattern=true; shift 2 ;;
            -*)             shift ;;
            *)
                if ! $has_pattern; then
                    pattern="$1"; has_pattern=true
                else
                    files+=("$1")
                fi
                shift ;;
        esac
    done
    if ! $has_pattern; then
        echo "Usage: sls [-CaseSensitive] [-NotMatch] pattern [files...]"
        return 1
    fi
    local args=("-E" "$icase")
    [[ -n "$invert" ]] && args+=("$invert")
    if [[ ${#files[@]} -gt 0 ]]; then
        grep "${args[@]}" -- "$pattern" "${files[@]}"
    else
        grep "${args[@]}" -- "$pattern"
    fi
}

# Format stubs — no direct bash equivalent; point to the right native tools
alias ft='echo "Linux: column -t (table)   or   awk for custom formatting"'
alias fl='echo "Linux: cat -n / less / awk for formatted list output"'
alias measure='echo "Linux: wc -l (lines)   wc -w (words)   wc -c (bytes)   wc (all)"'

# System admin stubs — tell you the right Linux tool rather than hiding it
alias chkdsk='echo "Linux: sudo fsck /dev/sdX   (unmount first)"'
alias format='echo "Linux: sudo mkfs.ext4 /dev/sdX  or  sudo parted"'
alias diskpart='echo "Linux: sudo fdisk /dev/sdX   or   sudo parted"'
alias regedit='echo "No registry on Linux. Config lives in /etc/ and ~/.config/"'
alias taskmgr='echo "Linux: htop   (or top, or ps aux)"'
alias services='echo "Linux: systemctl list-units --type=service"'
alias sc='echo "Linux: sudo systemctl start|stop|status|enable|disable <service>"'
alias shutdown='echo "Linux: sudo shutdown -h now  (halt)   sudo reboot  (restart)"'
alias icacls='echo "Linux: chmod / chown / ls -la   (see: man chmod, man chown)"'
alias cacls='echo "Linux: chmod / chown / ls -la   (see: man chmod, man chown)"'
alias wmic='echo "Linux: lshw / dmidecode / lscpu / lsblk / lspci   (see: man lshw)"'
alias schtasks='echo "Linux: crontab -e   (user tasks)   or   /etc/cron.d/   or   systemd timers"'

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
