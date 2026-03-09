# Changelog

## [v1.10] — 2026-03-09

### Added — PowerShell section
- `sls` — Select-String: grep wrapper with PS-style flags (`-CaseSensitive`, `-NotMatch`, `-Pattern`); case-insensitive by default like PS
- `gcm` — Get-Command: resolves a command path via `which`
- `gal` — Get-Alias: lists all active aliases
- `gps` — Get-Process: `ps aux`
- `gl` — Get-Location: `pwd`
- `gv` — Get-Variable: `printenv` with optional prefix filter
- `ni` — New-Item: `touch` for files; supports `-ItemType Directory` for `mkdir -p`
- `ii` — Invoke-Item: `xdg-open` (same behaviour as `start`)
- `spps` — Stop-Process: kill by `-Name` or `-Id`, with `-Force` for `-9`
- Stubs: `ft` → `column -t`/`awk`, `fl` → `cat -n`/`awk`, `measure` → `wc`

---

## [v1.9] — 2026-03-09

### Added
- `findstr` — grep wrapper with Windows-style flags: `/i` (case-insensitive), `/r` (regex), `/n` (line numbers), `/v` (invert), `/s` (recursive), `/m` (filenames only), `/c:"string"` (literal with spaces)
- `set` — env var function: no args lists all vars, `set VAR` filters by prefix, `set VAR=value` exports; shell flags (`set -x`, `set +e`, etc.) forwarded to bash builtin
- `mklink` — symlink/hardlink function with Windows syntax: `/D`/`/J` for symlinks, `/H` for hard links
- `clip` — stdin-to-clipboard function; detects `xclip`, `xsel`, or `wl-copy` automatically
- `runas` — sudo wrapper; supports Windows-style `/user:username` flag
- `title` — sets the terminal window/tab title
- `typefile` — `cat` wrapper (safe replacement for the `type` alias removed in v1.8)
- `net` — Windows `net` command stubs: `net user`, `net start/stop/restart`, `net use`, `net share`, `net view`
- Stubs: `icacls`, `cacls` → `chmod`/`chown`; `wmic` → `lshw`/`dmidecode`; `schtasks` → `crontab`/systemd timers
- `arp` and `route` — stubbed only if the native Linux tool is absent

---

## [v1.8] — 2026-03-09

### Fixed
- `detect_shell_rc()` now uses `$SHELL` env var instead of `ps -p $$` — reliable when running inside a script or non-interactive shell
- `dig` dependency now installs the correct package per distro: `bind-utils` (RHEL/Fedora/Arch) or `dnsutils` (Debian/Ubuntu)
- `install_dependency_if_missing` now accepts a separate binary name, so package name and binary name can differ
- `PKG_INSTALL`/`PKG_REMOVE` split out globally so `uninstall_doshell` can also remove packages (was broken — `PKG_CMD` was local to install only)
- sed commands in uninstall now use `|` as delimiter and `grep -vF` for the source line — safe against special characters in markers
- Duplicate install guard: `--install` now exits early if DOSHELL is already installed; use `--reinstall` to update
- `run()` verbose mode now handles command failures consistently with non-verbose mode
- Sourcing prompt removed — sourcing inside a script subshell doesn't affect the parent shell; now always prints manual instruction
- All `read` prompts use `|| true` to avoid `set -e` exits on EOF
- Newline safety: appending to rc file now ensures a trailing newline exists first

### Changed
- `alias deltree='rm -ri'` — added `-i` to prompt before deleting (was `rm -r`, no confirmation)
- `alias xcopy='cp -ri'` — added `-i` to prompt on overwrite (was `cp -r`, silent overwrite)
- `alias pause` — now uses `read -rsn1` for a true single-keypress wait (no Enter required)
- Added `pacman` (Arch Linux) package manager support

### Removed
- `alias fc='diff'` — `fc` is a bash builtin (edit and re-run last command); shadowing it breaks interactive shell history editing
- `alias type='cat'` — `type` is a bash builtin (show command type/path); shadowing it breaks `type ls`, `type cd`, etc.

---

## [v1.7] — 2026-03-01

### Added
- `notepad [file]` — opens file in `$EDITOR` (falls back to nano); same muscle memory as Windows
- `start [path/url]` — opens file, folder, or URL in the default app via `xdg-open`
- `explorer` — alias for `xdg-open .` (open current folder in file manager)
- Informational stubs for system admin commands — rather than wrapping them, doshell
  now tells you the correct native Linux command:
  - `diskpart` → `fdisk` / `parted`
  - `regedit` → points to `/etc/` and `~/.config/`
  - `taskmgr` → `htop` / `top`
  - `services` → `systemctl list-units`
  - `sc` → `systemctl start|stop|status|enable|disable`
  - `shutdown` → `sudo shutdown -h now` / `sudo reboot`

### Philosophy
Doshell translates syntax where the intent is identical (file ops, process listing,
network inspection). For Linux sysadmin tasks, it points you to the right native tool
rather than hiding what's really happening under a Windows wrapper.

---

## [v1.6] — 2026-03-01

### Added
- `where` → `which` (locate a command)
- `tasklist` → `ps aux` (list running processes)
- `mem` → `free -h` (memory usage)
- `vol` → `df -h` (disk volume info)
- `sysinfo` function — condensed `systeminfo` analog (OS, CPU, memory, disk)
- `taskkill` function — parses Windows-style flags `/PID <pid>`, `/IM <name>`, `/F`

### Fixed
- Removed no-op aliases (`echo`, `more`, `less`, `sort`, `hostname` — all aliased to themselves)
- Removed broken `exit='logout'` (bash builtin, cannot be aliased)
- Renamed `find='find . -name'` to `findfile` in `.bash_aliases` to match installer and avoid shadowing the real `find` command
- Removed `time='date +"%T"'` from installer — shadows bash's `time` builtin which times commands

### Changed
- Both `.bash_aliases` and the installer alias block are now in sync

---

## [v1.5 Final] — 2025-11-01
**Stability and License Release**

### Added
- Integrated full MIT License header into all scripts for transparency and compliance.
- Added `--install`, `--uninstall`, `--reinstall`, `--version`, and `--help` flags.
- Added explicit user prompts for dependency installation and sourcing aliases.
- Added `.doshell.deps` tracking file for installed dependencies (created only when needed).
- Added detailed logging to `~/.doshell.log` with timestamped milestones.

### Changed
- `setup-doshell.sh` now requires explicit action; no silent runs.
- Reinstall now performs `git pull` automatically when a repo is detected.
- Default output now shows milestone-level progress unless `--verbose` is specified.

### Fixed
- Improved alias quoting and reserved-word handling.
- Safe uninstall now removes only dependencies it installed and offers confirmation.
- Enhanced cross-shell compatibility (bash, zsh, dash).

### Removed
- Automatic dependency installation without user confirmation.
- Legacy placeholder alias definitions (e.g., `setvar`).

### License
Licensed under the **MIT License (© 2025 Tom Baty)**.  
See [LICENSE](./LICENSE) for full details.

---

*This marks the first stable public release of DOSHELL, built for admins who live in both worlds.*
