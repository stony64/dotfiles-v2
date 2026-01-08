# General Project Styleguide (v1.2.1)

Dieser Guide definiert die projektweiten Standards für Architektur, Dateiorganisation und Dokumentation. Er dient als Grundlage für die Konsistenz des gesamten Dotfiles-Ökosystems.

---

## 1. Architektur-Philosophie

Das Projekt folgt drei Kernprinzipien:

1. **Modularität:** Logik wird strikt in Bibliotheken (`lib/`) und ausführbare Skripte getrennt. Kein Skript sollte Logik enthalten, die auch an anderer Stelle nützlich sein könnte.
2. **Plattform-Abstraktion:** Betriebssystem-Unterschiede werden so früh wie möglich abgefangen (in der `libplatform_*.sh`) und in abstrakte Befehle übersetzt.
3. **Zustandslosigkeit & Idempotenz:** Jede Operation (Installation, Löschung) muss beliebig oft hintereinander ausführbar sein, ohne das System in einen instabilen Zustand zu bringen.

## 2. Verzeichnisstruktur

Die Struktur ist flach und zweckorientiert:

- **`/home`**: Enthält die Rohdateien (Dotfiles), die als Symlinks in das `$HOME` des Nutzers gespiegelt werden.
- **`/lib`**: Das Gehirn des Projekts. Enthält Module wie `libengine.sh`, `libconstants.sh` und `libplatform_*.sh`. Nur Funktionen, keine direkten Befehle.
- **`/docs`**: Markdown-Dokumentation für Menschen.
- **Root (`/`)**: Nur die Haupt-Entrypoints (`dotfilesctl.sh`, `test_suite.sh`) und Projektmetadaten.

## 3. Dokumentations-Standards (Markdown)

Alle `.md`-Dateien müssen folgenden Regeln entsprechen:

- **Sprache:** Deutsch (für Kommentare im Code und Anleitungen), Fachbegriffe bleiben Englisch.
- **Hierarchie:** Konsistente Nutzung von Überschriften (`#`, `##`, `###`).
- **Code-Blöcke:** Immer mit Sprach-Syntax-Highlighting versehen (z. B. ` ```bash `).
- **Dateipfade:** Pfade werden immer **fett** oder als `Inline-Code` dargestellt.

## 4. Versionierung & Git-Konventionen

### Versionsschema

Wir nutzen Semantic Versioning (SemVer):

- **Major (1.x.x):** Grundlegende Architekturänderungen.
- **Minor (x.2.x):** Neue Features oder Module (z. B. v1.2.1 Review-Upgrade).
- **Patch (x.x.1):** Bugfixes oder reine Dokumentationsänderungen.

### Commit-Messages

Commits sollten präzise und kategorisiert sein:

- `feat:` Neue Funktionen.
- `fix:` Fehlerbehebungen.
- `docs:` Änderungen an der Dokumentation.
- `refactor:` Code-Optimierung ohne Funktionsänderung.

## 5. Cross-Plattform Standards

Um die Kompatibilität zwischen Linux und Windows (Git Bash) zu gewährleisten:

- **Zeilenumbrüche:** Alle Dateien im Repository müssen `LF` (Unix) Zeilenumbrüche nutzen. Git-Konfiguration: `git config core.autocrlf input`.
- **Pfad-Referenzen:** Nutze ausschließlich `/` als Pfadtrennzeichen. Die Engine kümmert sich um die Übersetzung für Windows-APIs.
- **Symlink-Policy:** Wir erzwingen native NTFS-Symlinks via `winsymlinks:nativestrict`. Dies stellt sicher, dass Windows-Tools die Links als solche erkennen und nicht als Kopien behandeln.

## 6. Qualitätssicherung (QA)

Bevor Code in den `main`-Branch übernommen wird, muss er:

1. Den `shellcheck` ohne Warnungen bestehen.
2. Die `test_suite.sh` in einer Sandbox erfolgreich durchlaufen.
3. Mit dem `doctor`-Modul auf einem Linux- und einem Windows-System validiert werden.

---
> **Revision:** v1.2.1 | **Stand:** Januar 2026
