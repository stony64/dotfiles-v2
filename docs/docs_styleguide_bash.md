# 📜 Bash Styleguide & Coding Standards (v1.2.1)

Dieses Dokument definiert die verbindlichen Standards für die Entwicklung und Erweiterung des Dotfiles-Projekts. Ziel ist maximale Lesbarkeit, Cross-Plattform-Kompatibilität und absolute Robustheit.

---

## 1. Allgemeine Prinzipien

* **Bash Version:** Alle Skripte müssen kompatibel zu **Bash >= 4.0** sein (wegen assoziativer Arrays und `globstar`).
* **Sicherheit:** Jedes ausführbare Skript beginnt mit `set -euo pipefail`.
* `-e`: Sofortiger Abbruch bei Fehlern.
* `-u`: Fehler bei Zugriff auf ungesetzte Variablen.
* `-o pipefail`: Erkennt Fehler innerhalb von Pipelines (nicht nur am Ende).


* **Plattform-Agnostik:** Nutze immer die globale Variable `$PLATFORM` (`linux`|`windows`) für OS-spezifische Pfade oder Logik-Weichen.

## 2. Datei-Struktur & Header

Jedes Skript muss einen standardisierten Header im "Box-Design" besitzen. Bibliotheken (`lib/*.sh`) müssen zudem einen **Include-Guard** besitzen, um mehrfaches Laden zu verhindern.

```bash
#!/usr/bin/env bash
#
# FILE: path/to/script.sh
# ──────────────────────────────────────────────────────────────
# KURZE BESCHREIBUNG IN GROSSBUCHSTABEN
# ──────────────────────────────────────────────────────────────
# Zweck:       Detaillierte Erläuterung der Aufgabe.
# Standards:   set -euo pipefail, Bash >= 4.0, Shellcheck compliant.
# ──────────────────────────────────────────────────────────────

# Beispiel Include-Guard für Bibliotheken:
[[ -n "${_LIB_EXAMPLE_LOADED:-}" ]] && return
readonly _LIB_EXAMPLE_LOADED=1

```

## 3. Namenskonventionen

| Typ | Stil | Beispiel |
| --- | --- | --- |
| **Lokale Variablen** | `snake_case` | `local target_path` |
| **Globale Konstanten** | `SCREAMING_SNAKE` | `readonly BACKUP_DIR` |
| **UI-Konstanten** | Präfix `UI_` | `UI_COL_RED`, `UI_SYMBOL_OK` |
| **Funktionen** | `snake_case` | `create_symlink()` |
| **Umgebungsvariablen** | `SCREAMING_SNAKE` | `export PLATFORM` |

## 4. Funktions-Dokumentation (Javadoc-Stil)

Jede Funktion muss unmittelbar vor ihrer Definition dokumentiert werden. Dies erleichtert die Wartung und ermöglicht automatische Dokumentationsgenerierung.

```bash
# @description Kurze Beschreibung der Aufgabe.
# @param $1 [String] Zielpfad für den Symlink.
# @param $2 [String] Quellpfad (optional).
# @stdout Feedback-Meldung für den User.
# @return 0 bei Erfolg, 1 bei ungültigen Pfaden.
create_symlink() {
    local target="${1:-}"
    local source="${2:-}"
    # Logik ...
}

```

## 5. UI & Ausgaben

Nutze für alle Ausgaben die vordefinierten Farbcodes und Symbole aus `libcolors.sh` und `libconstants.sh`.

* **Erfolg:** `${UI_COL_GREEN}${UI_SYMBOL_OK}${UI_COL_RESET}`
* **Fehler:** `${UI_COL_RED}${UI_SYMBOL_ERROR}${UI_COL_RESET}` (Ausgabe immer auf `stderr` via `>&2`).
* **Pfade:** Pfade in Ausgaben immer in Anführungszeichen setzen `"..."`, um Leerzeichen-Probleme sofort sichtbar zu machen.

## 6. Cross-Plattform Best Practices

Da das Projekt native Windows-Symlinks unterstützt, gelten folgende Regeln:

1. **Pfad-Handling:** Nutze `$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)`, um das Skript-Verzeichnis robust zu ermitteln.
2. **Quoting:** **Jede** Variable, die einen Pfad enthält, muss in doppelten Anführungszeichen stehen: `"$path"`.
3. **Typprüfung:** Nutze spezifische Flags für Tests:
* `[[ -L "$path" ]]` prüft auf (Sym-)Links.
* `[[ -f "$path" ]]` prüft auf echte Dateien.
* `[[ -e "$path" ]]` prüft auf allgemeine Existenz.



## 7. Statische Analyse (Shellcheck)

Jedes Skript muss `shellcheck`-clean sein. Lokale Ausnahmen sind selten und müssen begründet werden.

* **Sourcing:** Dynamisches Sourcing (Variablen im Pfad) erfordert `# shellcheck disable=SC1090`.
* **Lokale Variablen:** Nutze immer `local` innerhalb von Funktionen, um den globalen Namespace sauber zu halten.

---
