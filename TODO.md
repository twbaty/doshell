# Doshell — Roadmap

![GitHub License](https://img.shields.io/github/license/twbaty/doshell)
![GitHub Tag](https://img.shields.io/github/v/tag/twbaty/doshell?label=Version)

**Author:** Tom Baty | **License:** MIT | **Current Version:** v1.7

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
