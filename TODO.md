# Doshell — Roadmap

![GitHub License](https://img.shields.io/github/license/twbaty/doshell)
![GitHub Tag](https://img.shields.io/github/v/tag/twbaty/doshell?label=Version)

**Author:** Tom Baty | **License:** MIT | **Current Version:** v1.9

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

---

## Possible Future Work

- [ ] `--quiet` flag for minimal install output
- [ ] Colorized output for milestones and status messages
- [ ] `--custom` flag: interactive alias selection (fzf-based, not whiptail)
- [ ] Profile presets: `basic`, `networking`, `power`
- [ ] Post-install alias self-test (`doshell --test`)

---

## Philosophy

Doshell translates syntax where the **intent is identical** — file ops, process
listing, network inspection. For Linux sysadmin tasks, it **points you to the
right native tool** rather than hiding what's really happening under a wrapper.

_Last updated: March 2026_
