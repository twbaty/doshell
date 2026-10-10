# Status — Doshell
_Reviewed 2026-10-10 by GitHub Copilot_

## What it is
Doshell adds familiar DOS/Windows-style commands to Linux shells, translating common file, process, and network tasks into Linux commands. It is for people who switch between Windows and Linux and want familiar commands while learning the Linux equivalents.

## Where it stands
- Version 1.10 includes working aliases, helper functions, and guidance for commands that do not have a direct Windows equivalent.
- The installer offers install, uninstall, reinstall, and dry-run options. Its help, version, and isolated dry-run checks worked during this review; a real install was not performed.
- There is no separate build step. A Bash syntax check and ShellCheck (a shell-script checker) pass, but no automated tests exist, so there is no test suite to pass.
- The documentation claims Bash, Zsh, and Dash/Ash support, but the aliases file fails Dash's syntax check. Compatibility beyond Bash needs verification.
- The roadmap lists additional installer options and command aliases as future work; these are enhancements, not prerequisites for trying the current Bash version.

## Path to a usable first version (MVP)
1. Confirm which shell or shells the first version will support.
2. Add an automated check that installs in a temporary test account, confirms key commands are available, and removes the installation on each supported shell.
3. Fix any problems the check finds and update the installation instructions to match the tested setup.

## Decisions needed (max 3)
### 1. Which shells should the first usable version support?
- **Why it matters:** The documentation lists Bash, Zsh, and Dash/Ash, but the aliases file does not pass Dash's syntax check.
- **Options:** A) Support Bash first and update the compatibility claims. B) Support Bash, Zsh, and Dash/Ash and make the aliases work and test them in each.
- **Recommended:** A) Support Bash first — it matches the Bash-specific implementation and is the smallest path to a tested first version.
- **Answer (2026-10-10, via HQ):** A — Support Bash first and update the compatibility claims

## Can proceed now
- Check install and removal in a temporary test account without changing a real user's shell setup or installing system packages.
- Check the documented commands against the aliases and installer, and correct any mismatches once the supported-shell decision is made.

## ⚠️ Security
No passwords, API keys, or access tokens were found in tracked source files. A historical commit (2d574349dbc9bbc996915779d202537ec2e8d20a) includes an author email address in its commit metadata; it is not reproduced here and is not present on a source-file line.
