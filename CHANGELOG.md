# Changelog

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
