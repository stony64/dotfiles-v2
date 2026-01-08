# Dotfiles Management System (v1.2.1)

Ein hochmodulares, plattformübergreifendes System zur Verwaltung von Konfigurationsdateien (Dotfiles). Optimiert für maximale Konsistenz zwischen nativen **Linux-Systemen** und **Windows-Umgebungen** (Git Bash / MSYS2).

## 🚀 Highlights

* **Plattform-Agnostisch:** Einheitliche Logik für Linux und Windows mit automatischer Erkennung.
* **Native Windows Symlinks:** Nutzt `nativestrict` für echte NTFS-Symlinks (keine Kopien!).
* **Modulare Architektur:** Klare Trennung von Bibliotheken (`lib/`), Engine und User-Konfiguration.
* **Integrierte Diagnose:** Umfangreiche Health-Checks (`dctl doctor`) für Abhängigkeiten und Rechte.
* **Sicher & Robust:** Strenges Error-Handling (`set -euo pipefail`) und idempotente Operationen.

## 📂 Projektstruktur

```text
~/.dotfiles/              # Standard-Installationspfad (Repo-Root)
├── dotfilesctl.sh        # Zentraler Orchestrator (Main Entry)
├── test_suite.sh         # Automatisierte Test-Umgebung (Sandbox)
├── lib/                  # Kern-Bibliotheken (v1.2.1)
│   ├── libcolors.sh      # UI-Definitionen (ESC-Sequenzen)
│   ├── libconstants.sh   # UI_COL_* Variablen & Symbole
│   ├── libplatform_*.sh  # OS-spezifische Abstraktion (Linux/Windows)
│   └── libengine.sh      # Symlink-, Backup- & Idempotenz-Logik
├── home/                 # Die eigentlichen Dotfiles (~/.*)
│   ├── .bashrc           # Orchestrator der Shell-Konfiguration
│   ├── .bashenv          # Plattform-Erkennung & Pfade
│   └── .bashfunctions    # Power-User Hilfsfunktionen
└── docs/                 # Detaillierte Dokumentation

```

## 🛠 Installation

### Voraussetzungen

* **Bash >= 4.0**
* **Git**
* **Windows:** Aktivierter **Entwicklermodus** (Settings > Privacy & Security > For developers), um Symlinks ohne Administratorrechte zu ermöglichen.

### Schnellstart

1. **Repository klonen:**

```bash
git clone https://github.com/stony64/dotfiles-v2.git ~/.dotfiles
cd ~/.dotfiles

```

1. **System-Check ausführen:**

```bash
./dotfilesctl.sh doctor

```

1. **Installation starten:**

```bash
# Auf Linux (interaktiv für aktuellen User):
./dotfilesctl.sh install

# Simulation (empfohlen):
./dotfilesctl.sh install --dry-run

```

## 💻 Benutzung

Nach der Installation steht der Alias **`dctl`** zur Verfügung.

| Befehl | Beschreibung |
| --- | --- |
| `install` | Erstellt Symlinks/Backups gemäß Whitelist. |
| `uninstall` | Entfernt Symlinks sicher und stellt Backups wieder her. |
| `doctor` | Validiert Tools, Pfade und Symlink-Berechtigungen. |
| `update` | Aktualisiert das Repository und synchronisiert Änderungen. |

### Globale Optionen

* `--dry-run`: Führt keine Änderungen am Dateisystem aus (nur Logging).
* `--user <name>`: (Linux-only) Zielbenutzer für die Installation definieren.

## 🛡 Qualitätssicherung

Das Projekt enthält eine integrierte Test-Suite. Diese erstellt eine temporäre Umgebung, simuliert verschiedene Betriebssysteme und validiert die Symlink-Logik, ohne Dateien in deinem echten Home-Verzeichnis zu verändern.

```bash
# Ausführung der Validierungstests
./test_suite.sh

```

## 📄 Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert.
