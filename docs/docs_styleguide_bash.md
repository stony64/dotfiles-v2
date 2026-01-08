# Bash Styleguide & Coding Standards (v1.2.1)

Dieses Dokument definiert die verbindlichen Standards für die Entwicklung und Erweiterung des Dotfiles-Projekts. Ziel ist maximale Lesbarkeit, Cross-Plattform-Kompatibilität und Robustheit.

---

## 1. Allgemeine Prinzipien

- **Bash Version:** Alle Skripte müssen kompatibel zu Bash >= 4.0 sein.
- **Sicherheit:** Jedes Skript beginnt mit `set -euo pipefail`.
    - `-e`: Abbruch bei Fehlern.
    - `-u`: Fehler bei ungesetzten Variablen.
    - `-o pipefail`: Erkennt Fehler innerhalb von Pipes.
- **Plattform-Agnostik:** Nutze immer die Variable `$PLATFORM` (linux/windows) für OS-spezifische Pfade oder Befehle.

## 2. Datei-Struktur & Header

Jedes Skript muss einen standardisierten Header im "Box-Design" besitzen.

```bash
#!/usr/bin/env bash
#
# FILE: path/to/script.sh
# ──────────────────────────────────────────────────────────────
# KURZE BESCHREIBUNG IN GROSSBUCHSTABEN
# ──────────────────────────────────────────────────────────────
# Zweck:       Detaillierte Erläuterung der Aufgabe.
# Standards:   set -euo pipefail, Bash >= 4.0.
# ──────────────────────────────────────────────────────────────

```

## 3. Namenskonventionen

- **Variablen (Lokal):** `snake_case` (z. B. `local target_path`).
- **Variablen (Global/Konstanten):** `SCREAMING_SNAKE_CASE` (z. B. `readonly LOG_FILE`).
- **Funktionen:** `snake_case` (z. B. `create_symlink()`).
- **Bibliotheken:** Präfixe nutzen (z. B. `ui_print_error` in `libcolors.sh`).

## 4. Funktions-Dokumentation (Javadoc-Stil)

Jede Funktion muss vor ihrer Definition dokumentiert werden. Dies ermöglicht eine automatisierte Dokumentationserstellung und erhöht die Wartbarkeit.

```bash
# @description Kurze Beschreibung der Funktion.
# @param $1 Typ/Name des ersten Parameters.
# @stdout Beschreibung der Standardausgabe.
# @return Exit-Code (z. B. 0 bei Erfolg, 1 bei Fehler).
function_name() {
    local param_one="${1:-default}"
    # Logik ...
}

```

## 5. UI & Ausgaben

Nutze für alle Ausgaben die vordefinierten Farbcodes und Symbole aus `libcolors.sh` und `libconstants.sh`.

- **Erfolg:** `${COL_GREEN}${SYMBOL_OK}${COL_RESET}`
- **Fehler:** `${COL_RED}${SYMBOL_ERROR}${COL_RESET}` (Ausgabe immer auf `stderr` via `>&2`).
- **Pfade:** Pfade in Ausgaben immer in Anführungszeichen setzen, um Leerzeichen-Probleme zu visualisieren.

## 6. Best Practices für Symlinks (Cross-Plattform)

Da das Projekt native Windows-Symlinks unterstützt, sind folgende Regeln strikt einzuhalten:

1. **Pfad-Auflösung:** Nutze `$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)`, um das Skript-Verzeichnis zu ermitteln.
2. **Absolute Pfade:** Symlinks sollten immer mit absoluten Pfaden erstellt werden, um Plattform-Unterschiede bei relativen Links zu vermeiden.
3. **Existenz-Prüfung:** Prüfe vor dem Linken immer:

- Ist es ein Link? `[[ -L "$path" ]]`
- Ist es eine Datei? `[[ -f "$path" ]]`
- Ist es ein Verzeichnis? `[[ -d "$path" ]]`

## 7. Shellcheck

Jedes Skript muss `shellcheck`-clean sein.

- Lokale Ausnahmen werden mit `# shellcheck disable=SCxxxx` direkt über der Zeile begründet.
- Dynamisches Sourcing wird mit `# shellcheck disable=SC1090/SC1091` markiert.

---

*Dieser Guide ist Teil des Dotfiles-Projekts v1.2.1. Änderungen bedürfen einer Anpassung der Versionsnummer.*
