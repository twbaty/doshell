# 🧭 DOSHELL Development Roadmap

![GitHub License](https://img.shields.io/github/license/twbaty/doshell)
![GitHub Tag](https://img.shields.io/github/v/tag/twbaty/doshell?label=Version)
![Supported Shells](https://img.shields.io/badge/Shells-Bash%2C%20Zsh%2C%20Dash-lightgrey)

---

### Windows-style command aliases for Linux  
**Author:** Tom Baty  
**License:** MIT  
**Current Version:** v1.5 Final  

> “Because sometimes your fingers still type *dir*.”

---

## 🚀 Next Steps — DOSHELL Roadmap

**Current version:** `v1.5 Final`  
**Author:** Tom Baty  
**License:** MIT  

---

### ✅ Completed (v1.5 Final)
- Core install/uninstall/reinstall logic finalized  
- Explicit user prompts and safe dependency tracking  
- MIT license integration across repo and scripts  
- Logging, alias cleanup, and shell detection  
- GitHub tags, README badges, and changelog structure  

---

### 🧭 Planned for Next Release (v1.6)
- **Interactive alias selector** using `whiptail`  
  - Launches with `--custom` flag  
  - Checkbox menu to choose which aliases to install  
  - Writes `.bash_aliases` dynamically based on selections  
  - Stores choices in `~/.doshell.selected` for easy re-use  

- **Enhanced dependency logic**  
  - Only suggest installs for selected aliases that require them  

- **Improved uninstall flow**  
  - Reads `.doshell.selected` and `.doshell.deps` to precisely remove only installed components  

- **Optional UI polish**  
  - Add colorized milestone output for better readability  
  - Add a `--quiet` flag for minimal install output  

---

### 🧪 Experimental Ideas
- Profile presets (`basic`, `networking`, `power`)  
- Minimal “test mode” that runs alias checks after setup  
- Automatic `.bash_aliases` validator  
- Optional shell auto-detection for first-time users  

---

### 💬 Notes
DOSHELL remains intentionally lightweight — no package build (RPM/DEB) is planned unless future community demand warrants it.  
A GUI or `whiptail`-based setup is the next logical evolution.  

---

_Last updated: **November 2025**_
