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
| `xcopy` | `cp -r` |
| `deltree` | `rm -r` |
| `type` | `cat` |
| `findfile` | `find . -name` |
| `attrib` | `lsattr` |
| `comp` / `fc` | `diff` |

### Terminal

| Windows | Linux |
|---------|-------|
| `cls` | `clear` |
| `pause` | `read -p "Press any key..."` |
| `edit` | `nano` |
| `notepad [file]` | opens `$EDITOR` (falls back to nano) |
| `start [path/url]` | `xdg-open` — opens in default app |
| `explorer` | `xdg-open .` — opens current folder |

### System Info

| Windows | Linux |
|---------|-------|
| `ver` | `uname -a` |
| `where` | `which` |
| `path` | `echo $PATH` |
| `mem` | `free -h` |
| `vol` | `df -h` |
| `tasklist` | `ps aux` |
| `sysinfo` | OS + CPU + memory + disk summary |

### Network

| Windows | Linux |
|---------|-------|
| `ipconfig` | `ip a` |
| `ping` | `ping -c 4` |
| `tracert` | `traceroute` |
| `netstat` | `ss -tuln` |
| `nslookup` | `dig` |

### Process Management

| Windows | Linux |
|---------|-------|
| `tasklist` | `ps aux` |
| `taskkill /PID <n> [/F]` | `kill [-9] <pid>` |
| `taskkill /IM <name> [/F]` | `pkill [-9] -f <name>` |

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

The installer detects `apt`, `yum`, and `dnf` automatically and uses whichever is available to install optional dependencies (`tree`, `traceroute`, `dnsutils`, `nano`, `fzf`).

---

## Version History

| Version | Highlights |
|---------|-----------|
| v1.0 | Initial release — core aliases, setup script |
| v1.5 | Install/uninstall/reinstall, shell detection, dependency tracking, logging |
| v1.6 | `where`, `tasklist`, `mem`, `vol`, `sysinfo`, `taskkill` function; fixed no-op and broken aliases |
| v1.7 | `notepad`, `start`, `explorer`; sysadmin stubs with Linux guidance |

---

## License

MIT — free to use, modify, and distribute with attribution.
See [LICENSE](LICENSE) for full details. © 2025 Tom Baty
