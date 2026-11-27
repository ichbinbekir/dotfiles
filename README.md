# dotfiles

Personal settings for my Arch Linux + KDE Plasma machine, managed with [chezmoi](https://www.chezmoi.io/).

File names follow chezmoi's format: a name starting with `dot_` starts with `.` in the home folder,
e.g. `dot_config/keyd/app.conf` → `~/.config/keyd/app.conf`.

Contents:
- fish: `arrow` prompt, greeting off, `~/.local/bin` in `PATH`
- git: user name and email
- espanso: text abbreviations (`:date`, `:time`, `:mail`), Turkish Q layout
  (start it at login once per machine: `systemctl --user enable --now espanso`)
- keyd: per-window key mapping (ESDF in Sober/Roblox, Caps Lock → F19); `dot_config/autostart/` starts
  `keyd-application-mapper` at login (needs the system-wide `/etc/keyd/default.conf`,
  `python-dbus`, and the user in the `keyd` group)
- plasma-workspace/env: `ANDROID_HOME` and `PATH` for Flutter (FVM in `~/fvm`) and the Android SDK
  (`~/Android/Sdk`); Plasma reads it at login and hands it to every app in the session
  (log out and back in after a change)

Not copied to the home folder (`.chezmoiignore`): this README, `CLAUDE.md`, `old/` (earlier
Hyprland setup, kept for reference).

## Setup

```fish
chezmoi init --apply git@github.com:ichbinbekir/dotfiles.git
```

Update later: `chezmoi update` (pulls and applies).
