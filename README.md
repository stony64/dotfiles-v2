# Dotfiles Management System (v1.2.1)

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Bash: >=4.0](https://img.shields.io/badge/Bash-%3E%3D4.0-orange.svg)
![Platform: Linux & Windows](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-lightgrey.svg)

Ein hochmodulares, plattformübergreifendes System zur Verwaltung von Konfigurationsdateien (Dotfiles). Optimiert für maximale Konsistenz zwischen nativen **Linux-Systemen** und **Windows-Umgebungen** (Git Bash / MSYS2).

## 🚀 Highlights

- **Plattform-Agnostisch:** Einheitliche Logik für Linux und Windows mit automatischer Erkennung.
- **Native Windows Symlinks:** Nutzt `nativestrict` für echte NTFS-Symlinks (keine Kopien!).
- **Modulare Architektur:** Klare Trennung von Bibliotheken (`lib/`), Engine und User-Konfiguration.
- **Integrierte Diagnose:** Umfangreiche Health-Checks (`dctl doctor`) für Abhängigkeiten und Rechte.
- **Sicher & Robust:** Strenges Error-Handling (`set -euo pipefail`) und idempotente Operationen.

## 📂 Projektstruktur

```text
.
├── dotfilesctl.sh        # Zentraler Orchestrator (Main Entry)
├── test_suite.sh         # Automatisierte Test-Umgebung (Sandbox)
├── lib/                  # Kern-Bibliotheken
│   ├── libcolors.sh      # UI & Farbcodes
│   ├── libplatform_*.sh  # OS-spezifische Abstraktion
│   └── libengine.sh      # Symlink- & Backup-Logik
├── home/                 # Die eigentlichen Dotfiles (~/.*)
│   ├── .bashrc           # Orchestrator der Shell-Konfiguration
│   ├── .bashenv          # Pfade & Shell-Optionen
│   └── .bashfunctions    # Power-User Hilfsfunktionen
└── docs/                 # Detaillierte Dokumentation

```

## 🛠 Installation

### Voraussetzungen

- **Bash >= 4.0**
- **Git**
- **Windows:** Aktivierter "Entwicklermodus" (für native Symlinks ohne Admin-Rechte).

### Schnellstart

1. Repository klonen:

```bash
git clone [https://github.com/dein-user/dotfiles-v2.git](https://github.com/dein-user/dotfiles-v2.git) ~/.dotfiles
cd ~/.dotfiles

```

1. System-Check ausführen:

```bash
./dotfilesctl.sh health

```

1. Installation starten:

```bash
# Auf Linux (für den aktuellen User):
./dotfilesctl.sh install --user $(whoami)

# Auf Windows:
./dotfilesctl.sh install

```

## 💻 Benutzung

Der zentrale Befehl lautet `dotfilesctl.sh` (Alias: `dctl`).

| Befehl | Beschreibung |
| --- | --- |
| `install` | Erstellt Symlinks gemäß Whitelist im Home-Verzeichnis. |
| `uninstall` | Entfernt die Symlinks sicher. |
| `doctor` | Führt eine vollständige System- und Integritätsdiagnose aus. |
| `update` | Aktualisiert das Repository via Git. |
| `checksymlinks` | Validiert die Integrität bestehender Links. |

### Optionen

- `--dry-run`: Simuliert alle Schreibvorgänge (empfohlen vor Erst-Installation).
- `--strict`: Behandelt Warnungen als kritische Fehler.

## 🛡 Qualitätssicherung

Das Projekt enthält eine eigene Test-Suite, die alle Operationen in einer isolierten Sandbox (`/tmp`) validiert, ohne dein echtes System zu gefährden:

```bash
./test_suite.sh

```

## 📄 Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert - siehe [LICENSE](https://www.google.com/search?q=LICENSE) Datei für Details.
