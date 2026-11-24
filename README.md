# dotfiles

Personal settings for my Arch Linux + KDE Plasma machine, managed with [chezmoi](https://www.chezmoi.io/).

File names follow chezmoi's format: a name starting with `dot_` starts with `.` in the home folder,
e.g. `dot_config/keyd/app.conf` → `~/.config/keyd/app.conf`. A file starting with `symlink_`
becomes a symbolic link whose target is the file's content
(`dot_config/systemd/user/default.target.wants/symlink_espanso.service` enables the espanso
user service, like `systemctl --user enable espanso`).

Contents:
- fish: `arrow` prompt, greeting off, `~/.local/bin` in `PATH`
- git: user name and email
- espanso: text abbreviations (`:date`, `:time`, `:mail`), Turkish Q layout
- keyd: per-window key mapping (ESDF in Sober/Roblox, Caps Lock → F19); `dot_config/autostart/` starts
  `keyd-application-mapper` at login (needs the system-wide `/etc/keyd/default.conf`,
  `python-dbus`, and the user in the `keyd` group)

Not copied to the home folder (`.chezmoiignore`): this README, `CLAUDE.md`, `old/` (earlier
Hyprland setup, kept for reference).

## Setup

```fish
chezmoi init --apply git@github.com:ichbinbekir/dotfiles.git
```

Update later: `chezmoi update` (pulls and applies).
