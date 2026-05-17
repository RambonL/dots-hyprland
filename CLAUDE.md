# dots-hyprland — CLAUDE.md

## Repo

Fork von [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)  
Eigener Fork: `https://github.com/RambonL/dots-hyprland`  
Lokaler Clone: `~/dots/`

Configs liegen unter `~/dots/dots/.config/` und sind per Symlink eingebunden:
- `~/.config/quickshell/ii` → `~/dots/dots/.config/quickshell/ii`
- `~/.config/hypr` → `~/dots/dots/.config/hypr`

## Struktur

```
~/dots/
  dots/
    .config/
      quickshell/ii/    — Quickshell Shell (siehe eigene CLAUDE.md dort)
      hypr/             — Hyprland Config
        custom/         — Persönliche Overrides (keybinds, execs, rules, env)
        hyprland/       — Modular aufgeteilte Hyprland-Configs
        hyprlock/       — Lockscreen-Themes
        workflows/      — Workspace-Workflows
```

## Commit-Struktur

Zwei getrennte Commits — wichtig für sauberes Rebasing:

| Commit | Inhalt | Anfassen? |
|--------|--------|-----------|
| `upstream baseline` | upstream Updates (dots-hyprland) | Nein |
| `custom: ...` | Eigene Änderungen | Ja |

## Upstream Update

```bash
cd ~/dots
git fetch upstream
git rebase upstream/main
# Konflikte möglich in: BarContent.qml, StyledPopup.qml
# → manuell lösen, dann:
git rebase --continue
git push origin main
```

## Eigene Änderungen committen

```bash
cd ~/dots
git add dots/.config/quickshell/ii/neue-datei.qml
git commit -m "custom: beschreibung"
git push origin main
```

## Hypr Config

- Persönliche Settings nur in `hypr/custom/` — diese Dateien werden von `hyprland.conf` includiert
- `hyprland/` enthält die modulare Haupt-Config (keybinds, rules, env, execs, general)
- `.old` / `.new` Dateien sind Backup-Artefakte vom dots-hyprland Install-Script — ignorieren
