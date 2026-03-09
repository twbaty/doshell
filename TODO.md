# Doshell — Roadmap

![GitHub License](https://img.shields.io/github/license/twbaty/doshell)
![GitHub Tag](https://img.shields.io/github/v/tag/twbaty/doshell?label=Version)

**Author:** Tom Baty | **License:** MIT | **Current Version:** v1.10

> "Because sometimes your fingers still type *dir*."

---

## Completed

### v1.5
- [x] Install / uninstall / reinstall flow with explicit flags
- [x] Shell detection (bash, zsh, dash) and rc file sourcing
- [x] Dependency tracking (`~/.doshell.deps`) and logging (`~/.doshell.log`)
- [x] Dry-run and verbose modes
- [x] MIT license integrated across repo

### v1.6
- [x] Added `where`, `tasklist`, `mem`, `vol`
- [x] Added `sysinfo` function (OS / CPU / memory / disk)
- [x] Added `taskkill` function with `/PID`, `/IM`, `/F` flag parsing
- [x] Removed no-op aliases (`echo`, `more`, `less`, `sort`, `hostname`)
- [x] Removed broken `exit=logout`
- [x] Fixed `find` shadowing — renamed to `findfile`
- [x] Removed `time` alias that shadowed bash builtin

### v1.7
- [x] Added `notepad` — opens `$EDITOR`, falls back to nano
- [x] Added `start` — `xdg-open` wrapper for files, folders, URLs
- [x] Added `explorer` — `xdg-open .`
- [x] Added sysadmin stubs: `shutdown`, `sc`, `services`, `taskmgr`, `diskpart`, `regedit`
- [x] Stubs teach the correct Linux tool rather than wrapping it

### v1.8
- [x] Fixed `detect_shell_rc()` to use `$SHELL` — reliable in script context
- [x] Fixed `dig` package name: `bind-utils` (RHEL/Arch) vs `dnsutils` (Debian)
- [x] Removed `alias fc='diff'` — was shadowing bash builtin `fc` (fix command)
- [x] Removed `alias type='cat'` — was shadowing bash builtin `type`
- [x] Fixed `deltree` and `xcopy` to use `-i` for safety prompts
- [x] Fixed `taskkill` operator precedence (`&&/||` → explicit `if/else`)
- [x] Fixed `run()` verbose mode to handle errors consistently
- [x] Fixed duplicate install guard (--install checks for existing block)
- [x] Fixed uninstall sed to use safe delimiters; source line removal uses `grep -vF`
- [x] Removed misleading "source now" subshell prompt
- [x] Added `pacman` package manager support (Arch Linux)
- [x] Fixed `PKG_CMD` scoping bug — uninstall can now also remove packages
- [x] Fixed `pause` alias to use `read -rsn1` (true keypress, no Enter needed)

### v1.9
- [x] `findstr` — grep wrapper with Windows-style flags
- [x] `set` — env var function with builtin passthrough
- [x] `mklink` — symlink/hardlink with Windows syntax
- [x] `clip` — stdin to clipboard (xclip/xsel/wl-copy)
- [x] `runas` — sudo wrapper with /user: support
- [x] `title` — set terminal window title
- [x] `typefile` — safe cat replacement (type shadows bash builtin)
- [x] `net` — stubs for net user/start/stop/use/share
- [x] Stubs: icacls, cacls, wmic, schtasks, arp, route

### v1.10
- [x] `sls` — Select-String (grep wrapper with PS flags)
- [x] `gcm` — Get-Command (which)
- [x] `gal` — Get-Alias (alias)
- [x] `gps` — Get-Process (ps aux)
- [x] `gl` — Get-Location (pwd)
- [x] `gv` — Get-Variable (printenv)
- [x] `ni` — New-Item (touch / mkdir -p)
- [x] `ii` — Invoke-Item (xdg-open)
- [x] `spps` — Stop-Process (kill/pkill with -Name/-Id/-Force)
- [x] Stubs: ft, fl, measure

---

## Possible Future Work

### Installer Improvements

- [ ] `--quiet` flag — suppress all output except errors; useful in scripts and dotfile bootstrappers
- [ ] `--status` flag — show whether doshell is installed, which rc file has the source line, and whether aliases are currently active in the shell; useful for troubleshooting
- [ ] Colorized installer output — green for success, yellow for warnings, red for errors; use `tput` for portability, not hardcoded ANSI codes
- [ ] `--custom` flag — interactive alias selection using `fzf`; let users pick only the aliases they want rather than installing everything
- [ ] Profile presets — `--profile basic` (file/dir/terminal only), `--profile networking` (adds network aliases), `--profile power` (everything including PS section); written to a separate marker so reinstall knows which profile was used
- [ ] Post-install self-test — `--test` flag that sources the aliases in a subshell and verifies each one resolves to a real command or function; reports any that are broken or point to missing tools

### Alias & Function Additions

- [ ] `robocopy` — `rsync` wrapper with Windows-style flags (`/MIR`, `/E`, `/Z`, `/LOG`); heavily used by Windows power users for backup/sync
- [ ] `where /r` — recursive `which`; find all instances of a command in PATH, not just the first
- [ ] `systeminfo` — expand `sysinfo` to match more of Windows `systeminfo` output: hostname, domain, boot time, installed hotfixes (uptime, /etc/os-release, last reboot)
- [ ] `color` — stub; explain terminal colors via `tput` or ANSI escape sequences
- [ ] `assoc` / `ftype` — stubs; explain Linux MIME/file-type associations via `xdg-mime`
- [ ] `cipher` — stub; point to `gpg`, `openssl`, and LUKS for encryption
- [ ] `gpupdate` — stub; explain that Linux has no group policy but note `/etc/profile.d/` for system-wide shell config

### PowerShell Additions

- [ ] `Select-Object` equivalent — a safe-named wrapper (not `select`, which is a bash builtin) around `awk`/`cut` for extracting columns; something like `selobj`
- [ ] `Where-Object` pipe filter — safe-named wrapper (not `where`) around `grep` for object-style filtering; something like `whereobj`
- [ ] `Get-Content` / `gc` — `gc` is not a builtin; could alias to `cat` with optional `-Tail` / `-Wait` support (maps to `tail -f`)
- [ ] `Out-File` / `tee` — `tee` already exists natively; a stub or thin wrapper noting the equivalence
- [ ] `ConvertTo-Json` / `ConvertFrom-Json` — stubs pointing to `jq`; increasingly relevant as PS users use JSON pipelines

---

## Philosophy

Doshell translates syntax where the **intent is identical** — file ops, process
listing, network inspection. For Linux sysadmin tasks, it **points you to the
right native tool** rather than hiding what's really happening under a wrapper.

_Last updated: March 2026_
