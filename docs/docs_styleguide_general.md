# 🌐 General Project Styleguide (v1.2.1)

Dieser Guide definiert die projektweiten Standards für Architektur, Dateiorganisation und Dokumentation. Er bildet das Fundament für die Konsistenz und Wartbarkeit des gesamten Dotfiles-Ökosystems.

---

## 1. Architektur-Philosophie

Das Framework folgt drei Kernprinzipien für professionelle Systemadministration:

1. **Strikte Modularität:** Logik wird konsequent in Bibliotheken (`lib/`) gekapselt. Ausführbare Skripte (Entrypoints) dienen lediglich als Orchestratoren und enthalten keine wiederverwendbare Geschäftslogik.
2. **Plattform-Abstraktion:** Betriebssystem-Unterschiede werden exklusiv in der `libplatform_*.sh` behandelt. Der Rest des Codes nutzt abstrakte Funktionen, um unabhängig vom OS zu agieren.
3. **Idempotenz:** Jede Operation (Installation, Update, Deinstallation) muss ohne Seiteneffekte beliebig oft wiederholbar sein. Der Zielzustand ist definiert; der Weg dorthin ist sicher.

## 2. Verzeichnisstruktur

Die Struktur ist flach, intuitiv und skalierbar:

* **`/home`**: Die "Payload". Enthält die Rohdateien, die als Symlinks in das `$HOME` des Nutzers gespiegelt werden.
* **`/lib`**: Das "Gehirn". Enthält funktionale Module. **Wichtig:** Libs dürfen nur Funktionen definieren, aber keine Befehle direkt beim Laden ausführen.
* **`/docs`**: Wissenstransfer. Markdown-Dokumentation für Anwender und Entwickler.
* **Root (`/`)**: Nur primäre Entrypoints (`dotfilesctl.sh`, `test_suite.sh`) und Konfigurations-Metadaten (`.editorconfig`, `.gitattributes`).

## 3. Dokumentations-Standards

Qualitativ hochwertige Dokumentation ist Teil des Produkts, nicht nur ein Beiwerk:

* **Sprache:** Deutsch für Anleitungen und Kommentare; technische Fachbegriffe bleiben Englisch (z. B. "Symlink", "Shell-Expansion").
* **Visuelle Hierarchie:** Konsistente Nutzung von Markdown-Headern (`#` bis `###`).
* **Präzision:** Code-Blöcke müssen immer den Sprach-Bezeichner enthalten (z. B. ````bash`), um korrektes Syntax-Highlighting zu gewährleisten.
* **Hervorhebung:** Systempfade werden fett oder als `Inline-Code` markiert (z. B. **~/.bashrc**).

## 4. Versionierung & Git-Konventionen

### Semantic Versioning (SemVer 2.0.0)

* **Major (1.x.x):** Breaking Changes (z. B. neue Pfadstruktur).
* **Minor (x.2.x):** Neue Features (z. B. ein neues Modul `bashprompt`).
* **Patch (x.x.1):** Bugfixes, Tippfehler oder Refactoring.

### Commit-Guidelines

Wir nutzen aussagekräftige Präfixe für die Git-Historie:

* `feat:` Neue Features.
* `fix:` Fehlerbehebung.
* `docs:` Dokumentations-Updates.
* `style:` Änderungen, die die Logik nicht beeinflussen (Formatting).

## 5. Cross-Plattform Standards

Zur Gewährleistung der nahtlosen Koexistenz von Linux und Windows:

* **Erzwungenes LF:** Alle Textdateien müssen Unix-Zeilenumbrüche (`LF`) nutzen. Dies wird über die `.gitattributes` hart vorgegeben.
* **Pfad-Syntax:** Innerhalb der Skripte wird ausschließlich der Forward-Slash `/` genutzt. Die Engine übersetzt dies bei Bedarf für Windows-spezifische Aufrufe.
* **Native NTFS-Symlinks:** Wir nutzen das "Native-First"-Prinzip. Links unter Windows werden so erstellt, dass sie auch für native Windows-Programme (z. B. Explorer) als Verknüpfung erkennbar sind.

## 6. Qualitätssicherung (QA)

Ein Release der Version v1.2.x oder höher erfordert:

1. **Zero-Warning Policy:** ShellCheck darf keine Warnungen ausgeben.
2. **Sandbox-Validierung:** Die `test_suite.sh` muss in einer isolierten Umgebung fehlerfrei durchlaufen.
3. **Cross-Check:** Erfolgreicher `dctl doctor` Lauf auf mindestens einer nativen Linux-Distribution und einer Git-Bash-Installation.

---

> **Revision:** v1.2.1 | **Stand:** Januar 2026
