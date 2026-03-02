# Changelog

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
See [LICENSE](./LICENSE) or run `./doshell.sh` for attribution details.

---

*This marks the first stable public release of DOSHELL, built for admins who live in both worlds.*
