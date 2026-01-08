# 📜 Bash Styleguide & Coding Standards (v1.2.2)

Dieses Dokument definiert die verbindlichen Standards für die Entwicklung und Erweiterung des Dotfiles-Projekts. In der Version 1.2.2 liegt der Fokus auf **Namespace-Sicherheit** (Vermeidung von `readonly`-Fehlern) und **zentraler Systemverwaltung**.

---

## 1. Allgemeine Prinzipien

* **Bash Version:** Alle Skripte müssen kompatibel zu **Bash >= 4.0** sein (wegen assoziativer Arrays und `mapfile`).
* **Sicherheit:** Jedes ausführbare Skript beginnt mit `set -euo pipefail`.
* **Zentraler Pfad:** Das Projekt ist für `/opt/dotfiles` optimiert. Nutze immer die dynamische Pfadauflösung via `REPO_ROOT`, um Portabilität zu gewährleisten.

## 2. Datei-Struktur & Header

Bibliotheken (`lib/*.sh`) müssen einen **Include-Guard** besitzen. Dies ist in v1.2.2 kritisch, da viele Variablen als `readonly` deklariert sind.

```bash
#!/usr/bin/env bash
#
# FILE: lib/libexample.sh
# ──────────────────────────────────────────────────────────────
# BESCHREIBUNG DER BIBLIOTHEK
# ──────────────────────────────────────────────────────────────

# v1.2.2 Include-Guard
[[ -n "${_LIB_EXAMPLE_LOADED:-}" ]] && return
readonly _LIB_EXAMPLE_LOADED=1

```

## 3. Namenskonventionen (v1.2.2 Update)

Um Kollisionen bei `readonly`-Variablen zu vermeiden, nutzen wir eine strikte Trennung zwischen **Rohwerten** und **formatierten UI-Strings**.

| Typ | Stil | Beispiel | Zweck |
| --- | --- | --- | --- |
| **Rohwerte (Werte)** | `UI_*_VAL` | `UI_COL_RED_VAL='31'` | Atomare Werte in `libcolors.sh`. |
| **UI-Sequenzen** | `UI_*` | `UI_COL_RED='\e[31m'` | Finale ANSI-Strings in `libconstants.sh`. |
| **Lokale Variablen** | `snake_case` | `local target_path` | Nur innerhalb von Funktionen. |
| **Globale Konstanten** | `SCREAMING_SNAKE` | `readonly REPO_ROOT` | Systemweite Konstanten. |
| **Funktionen** | `snake_case` | `engine_create_link()` | Mit Modul-Präfix (z.B. `engine_`). |

## 4. Namespace-Sicherheit (WICHTIG)

In v1.2.2 ist es untersagt, Variablen in verschiedenen Bibliotheken mit demselben Namen als `readonly` zu definieren.

* **Regel:** `libcolors.sh` definiert nur Werte mit dem Suffix `_VAL`.
* **Regel:** `libconstants.sh` setzt diese zu den finalen UI-Variablen zusammen.

## 5. Funktions-Dokumentation (Javadoc-Stil)

Jede Funktion muss dokumentiert sein. Das Präfix sollte dem Dateinamen entsprechen (Modul-Design).

```bash
# @description Erstellt einen Symlink mit Backup-Logik.
# @param $1 [String] Quellpfad (im Repo).
# @param $2 [String] Zielpfad (im Home).
# @return 0 bei Erfolg, EXIT_FATAL bei Fehlern.
engine_create_link() {
    local source="${1:-}"
    local target="${2:-}"
    # Logik ...
}

```

## 6. Multi-User & Pfad-Handling

Da das System nun in `/opt/dotfiles` lebt, gelten verschärfte Regeln für Pfade:

1. **Dynamischer Root:** Nutze die v1.2.2 `while`-Schleife mit `readlink`, um den `REPO_ROOT` zu finden (folgt Symlinks von `/usr/local/bin`).
2. **User-Kontext:** Nutze niemals `$HOME` hartcodiert, wenn das Skript für andere User (`--user <name>`) agiert. Verwende stattdesssen die vom Controller ermittelte lokale Variable `home`.
3. **Quoting:** **Jede** Variable in Pfaden **muss** in `"..."` stehen.

## 7. UI & Ausgaben

Nutze die Präfixe aus `libconstants.sh` für konsistentes Logging:

* `log_info "Nachricht"` -> `${LOG_PREFIX_INFO} Nachricht`
* `log_error "Nachricht"` -> `${LOG_PREFIX_ERROR} Nachricht` (geht autom. auf `stderr`)

## 8. Statische Analyse (Shellcheck)

* Jedes Skript muss `shellcheck`-clean sein.
* Nutze `readonly` für alle globalen Variablen, die nach der Initialisierung nicht mehr geändert werden.
* Nutze `local` für **alle** Variablen innerhalb von Funktionen.

---
