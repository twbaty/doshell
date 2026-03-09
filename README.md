# Doshell

![GitHub License](https://img.shields.io/github/license/twbaty/doshell)
![GitHub Tag](https://img.shields.io/github/v/tag/twbaty/doshell?label=Version)
![Supported Shells](https://img.shields.io/badge/Shells-Bash%2C%20Zsh%2C%20Dash-lightgrey)

**Built for people who live in both worlds.**

Doshell is a lightweight shell enhancement for Linux, designed for anyone who spends time on both Windows and Linux. It provides familiar DOS-style command aliases, useful functions, and honest guidance for commands that belong to Linux itself.

Type what you know — let Linux respond.

> Companion project: [Winix](https://github.com/twbaty/winix) — a Unix-like shell for Windows.

---

## Features

- DOS-style aliases for common commands (`dir`, `copy`, `del`, `cls`, `md`, etc.)
- Functions with real Windows-style argument parsing (`taskkill /PID 1234 /F`)
- `notepad`, `start`, and `explorer` that do what you'd expect on Linux
- Informational stubs for sysadmin commands — tells you the right Linux tool rather than hiding it
- PowerShell muscle-memory covered: `sls`, `gcm`, `gal`, `ni`, `spps`, and more
- Works across `bash`, `zsh`, and `dash`
- Clean installer with `--install`, `--uninstall`, `--reinstall` — no silent changes

---

## Aliases & Functions

### File & Directory

| Windows | Linux |
|---------|-------|
| `dir` | `ls -l --color=auto` |
| `copy` | `cp -i` |
| `move` | `mv -i` |
| `del` | `rm -i` |
| `ren` | `mv` |
| `md` | `mkdir -p` |
| `rd` | `rmdir` |
| `xcopy` | `cp -ri` (prompts on overwrite) |
| `deltree` | `rm -ri` (prompts on each file) |
| `typefile` | `cat` (renamed — `type` shadows a bash builtin) |
| `findfile` | `find . -name` |
| `attrib` | `lsattr` |
| `comp` | `diff` |
| `mklink [/D] [/H] link target` | `ln [-s] target link` |

### Terminal

| Windows | Linux |
|---------|-------|
| `cls` | `clear` |
| `pause` | single-keypress wait (no Enter needed) |
| `title <text>` | sets terminal window/tab title |
| `edit` | `nano` |
| `notepad [file]` | opens `$EDITOR` (falls back to nano) |
| `start [path/url]` | `xdg-open` — opens in default app |
| `explorer` | `xdg-open .` — opens current folder |
| `clip` | pipes stdin to clipboard (`echo hello \| clip`) |

### System Info & Environment

| Windows | Linux |
|---------|-------|
| `ver` | `uname -a` |
| `where` | `which` |
| `path` | `echo $PATH` |
| `set` | list / filter / export env vars |
| `mem` | `free -h` |
| `vol` | `df -h` |
| `sysinfo` | OS + CPU + memory + disk summary |

### Network

| Windows | Linux |
|---------|-------|
| `ipconfig` | `ip a` |
| `ping` | `ping -c 4` |
| `tracert` | `traceroute` |
| `netstat` | `ss -tuln` |
| `nslookup` | `dig` |
| `net user / start / stop / use / share` | guided stubs |

### Process Management

| Windows | Linux |
|---------|-------|
| `tasklist` | `ps aux` |
| `taskkill /PID <n> [/F]` | `kill [-9] <pid>` |
| `taskkill /IM <name> [/F]` | `pkill [-9] -f <name>` |
| `runas [/user:name] cmd` | `sudo [-u name] cmd` |

### Text Search

| Windows / PowerShell | Linux |
|---------------------|-------|
| `findstr [/i] [/r] [/n] [/v] [/s] pattern [files]` | `grep` wrapper with Windows flags |
| `sls [-CaseSensitive] [-NotMatch] pattern [files]` | `grep` wrapper with PS flags |

### PowerShell

| PowerShell | Linux |
|-----------|-------|
| `gl` | `pwd` (Get-Location) |
| `gal` | `alias` (Get-Alias) |
| `gps` | `ps aux` (Get-Process) |
| `gcm <cmd>` | `which` (Get-Command) |
| `ii <path>` | `xdg-open` (Invoke-Item) |
| `gv [prefix]` | `printenv` (Get-Variable) |
| `ni <file>` | `touch` (New-Item) |
| `ni -ItemType Directory <dir>` | `mkdir -p` |
| `spps -Name <n> [-Force]` | `pkill [-9] -f <name>` (Stop-Process) |
| `spps -Id <pid> [-Force]` | `kill [-9] <pid>` |
| `ft` | stub → `column -t` / `awk` |
| `fl` | stub → `cat -n` / `awk` |
| `measure` | stub → `wc -l / -w / -c` |

### Sysadmin Stubs

These commands are Linux sysadmin territory — doshell tells you the right tool rather than wrapping it:

| Windows | Guidance |
|---------|---------|
| `shutdown` | `sudo shutdown -h now` / `sudo reboot` |
| `sc` | `sudo systemctl start\|stop\|status <service>` |
| `services` | `systemctl list-units --type=service` |
| `taskmgr` | `htop` or `top` |
| `diskpart` | `sudo fdisk` / `sudo parted` |
| `chkdsk` | `sudo fsck /dev/sdX` |
| `format` | `sudo mkfs.ext4 /dev/sdX` |
| `regedit` | Config lives in `/etc/` and `~/.config/` |
| `icacls` / `cacls` | `chmod` / `chown` / `ls -la` |
| `wmic` | `lshw` / `dmidecode` / `lscpu` / `lsblk` |
| `schtasks` | `crontab -e` or systemd timers |

---

## Installation

```bash
git clone https://github.com/twbaty/doshell.git
cd doshell
chmod +x setup-doshell.sh
./setup-doshell.sh --install
```

Then reload your shell:

```bash
source ~/.bashrc   # or source ~/.zshrc
```

### Other options

```bash
./setup-doshell.sh --uninstall    # remove all doshell aliases
./setup-doshell.sh --reinstall    # git pull + reinstall
./setup-doshell.sh --version      # show version and install log
./setup-doshell.sh --dry-run      # preview changes without applying
./setup-doshell.sh --help         # full usage
```

---

## Shell Compatibility

Doshell is built around `.bash_aliases`, which is automatically sourced in most Bash environments. The installer detects your active shell and adds a source line to `~/.bashrc`, `~/.zshrc`, or `~/.profile` as appropriate.

For non-standard shells, source the file manually:

```bash
source ~/.bash_aliases
```

---

## Package Manager Support

The installer detects `apt-get`/`apt`, `yum`, `dnf`, and `pacman` automatically and uses whichever is available to install optional dependencies (`tree`, `traceroute`, `dnsutils`/`bind-utils`, `nano`, `fzf`).

---

## Version History

| Version | Highlights |
|---------|-----------|
| v1.0 | Initial release — core aliases, setup script |
| v1.5 | Install/uninstall/reinstall, shell detection, dependency tracking, logging |
| v1.6 | `where`, `tasklist`, `mem`, `vol`, `sysinfo`, `taskkill` function; fixed no-op and broken aliases |
| v1.7 | `notepad`, `start`, `explorer`; sysadmin stubs with Linux guidance |
| v1.8 | Bug fixes: shell detection, `dig` package name, duplicate install guard, safe uninstall sed, `taskkill` operator precedence, `deltree`/`xcopy` safety prompts, removed builtin-shadowing aliases (`fc`, `type`) |
| v1.9 | `findstr`, `set`, `mklink`, `clip`, `runas`, `title`, `net`, `typefile`; stubs for `icacls`, `cacls`, `wmic`, `schtasks`, `arp`, `route` |
| v1.10 | PowerShell section: `sls`, `gcm`, `gal`, `gps`, `gl`, `gv`, `ni`, `ii`, `spps`; stubs for `ft`, `fl`, `measure` |

---

## License

MIT — free to use, modify, and distribute with attribution.
See [LICENSE](LICENSE) for full details. © 2025 Tom Baty
