# Doshell

![GitHub License](https://img.shields.io/github/license/twbaty/doshell)
![GitHub Tag](https://img.shields.io/github/v/tag/twbaty/doshell?label=Version)
![Supported Shells](https://img.shields.io/badge/Shells-Bash%2C%20Zsh%2C%20Dash-lightgrey)


**Built for admins who live in both worlds.**

Doshell is a lightweight shell enhancement for Linux environments, designed for system administrators and power users who frequently switch between Windows and Linux. It provides a familiar set of DOS-style command aliases (`dir`, `copy`, `del`, `cls`, etc.) and installs optional tools that mimic Windows CLI behavior.

Whether you're managing servers, scripting across platforms, or just tired of switching mental gears, Doshell helps unify your command-line experience. Type what you know — and let Linux respond like Windows.

---

## 🔧 Features

- ✅ DOS-style aliases for common commands (`dir`, `copy`, `del`, `cls`, `md`, `rd`, etc.)
- ✅ Works across `bash`, `zsh`, and `ash` shells
- ✅ Installs optional tools to support alias functionality
- ✅ Immediately activates aliases in your current shell
- ✅ Clean setup script — no bloat, no guesswork

---

## 📦 Included Aliases

| DOS Command | Linux Equivalent |
|-------------|------------------|
| `dir`       | `ls -l --color=auto` |
| `copy`      | `cp -i` |
| `del`       | `rm -i` |
| `cls`       | `clear` |
| `md`        | `mkdir -p` |
| `rd`        | `rmdir` |
| `type`      | `cat` |
| `ren`       | `mv` |
| `xcopy`     | `cp -r` |
| `deltree`   | `rm -r` |
| `attrib`    | `lsattr` |
| `ver`       | `uname -a` |
| `ipconfig`  | `ip a` |
| `tracert`   | `traceroute` |
| `netstat`   | `ss -tuln` |
| `nslookup`  | `dig` |
| `edit`      | `nano` |
| `pause`     | `read -p "Press any key to continue..."` |
| `help`      | `man` |
| `exit`      | `logout` |

---

## 🛠️ Optional Tools Installed

Doshell installs the following tools to support alias functionality and improve CLI parity:

- `tree`, `dos2unix`, `traceroute`, `dnsutils`, `iproute2`, `man-db`, `lsattr`, `coreutils`, `util-linux`, `bash-completion`, `nano`, `ncdu`, `dialog`, `whiptail`, `fzf`

These are installed via `apt` and skipped if already present.

---

## 🚀 Installation

```bash
git clone https://github.com/yourusername/doshell.git
cd doshell
chmod +x setup-doshell.sh
./setup-doshell.sh

---

🐚 Shell Compatibility
Doshell is built around .bash_aliases, which is automatically sourced in most Bash environments. For users of other shells (like Zsh or Ash), the setup script attempts to source .bash_aliases via .zshrc and .profile.

If you're using a non-Bash shell and aliases aren't activating, you may need to manually source the file or copy the alias definitions into your shell's preferred config file.

---

## 📜 Version History

- **v1.0** — Initial release with core aliases and setup script

---

## 📄 License

This project is licensed under the MIT License. You’re free to use, modify, and distribute it with attribution. See the [LICENSE](LICENSE) file for full details.

