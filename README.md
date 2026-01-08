# 🛠️ Dotfiles Management System (v1.2.1)

Ein hochmodulares, plattformübergreifendes Framework zur Verwaltung von Konfigurationsdateien. Optimiert für maximale Konsistenz zwischen nativen **Linux-Systemen** und **Windows-Umgebungen** (Git Bash / MSYS2).

## 🚀 Highlights

* **Plattform-Agnostisch:** Einheitliche Logik für Linux und Windows mit automatischer Erkennung zur Laufzeit.
* **Native Windows Symlinks:** Nutzt `winsymlinks:nativestrict` für echte NTFS-Symlinks statt bloßer Dateikopien.
* **Modulare Architektur:** Striktes "Separation of Concerns" zwischen Logik-Bibliotheken (`lib/`) und User-Konfiguration (`home/`).
* **Integrierte Diagnose:** Der `doctor`-Modus validiert Abhängigkeiten, Pfade und kritische Berechtigungen (Symlink-Rechte unter Win).
* **Sicher & Robust:** Idempotente Operationen und automatisches Backup-Management schützen deine bestehende Konfiguration.

## 📂 Projektstruktur

```text
~/.dotfiles/              # Standard-Installationspfad (Repo-Root)
├── dotfilesctl.sh        # Zentraler Orchestrator (Main Entry Point)
├── test_suite.sh         # Automatisierte Sandbox-Validierung
├── lib/                  # Kern-Bibliotheken (v1.2.1)
│   ├── libcolors.sh      # UI-Farbequenzen
│   ├── libconstants.sh   # Globale Variablen & Symbole
│   ├── libplatform_*.sh  # OS-spezifische Abstraktionslayer
│   └── libengine.sh      # Symlink-, Backup- & Kernlogik
├── home/                 # Die eigentlichen Dotfiles (~/.*)
│   ├── .bashrc           # Haupt-Initialisierung der Shell
│   ├── .bashenv          # Umgebungsvariablen & Pfade
│   └── .bashprompt       # Dynamisches Git-Prompt Design
└── docs/                 # Vertiefende Dokumentation & Guides

```

## 🛠️ Installation

### Voraussetzungen

* **Bash >= 4.0**
* **Git**
* **Windows-Hinweis:** Aktiviere den **Entwicklermodus** (*Einstellungen > Datenschutz & Sicherheit > Für Entwickler*), um Symlinks ohne Administratorrechte erstellen zu können.

### Schnellstart

```bash
# 1. Repository klonen
git clone https://github.com/stony64/dotfiles-v2.git ~/.dotfiles
cd ~/.dotfiles

# 2. System-Integrität prüfen
./dotfilesctl.sh doctor

# 3. Installation starten (Simulation empfohlen)
./dotfilesctl.sh install --dry-run

# 4. Final anwenden
./dotfilesctl.sh install

```

## 💻 Benutzung

Nach erfolgreicher Installation wird der Alias **`dctl`** global verfügbar gemacht.

| Befehl | Beschreibung |
| --- | --- |
| `dctl install` | Erstellt Symlinks & Backups gemäß Whitelist. |
| `dctl uninstall` | Entfernt Symlinks sicher und stellt Backups wieder her. |
| `dctl doctor` | Validiert Tools, Pfade und Symlink-Berechtigungen. |
| `dctl update` | Aktualisiert das Repo und synchronisiert Änderungen. |

### Globale Optionen

* `--dry-run`: Zeigt alle geplanten Aktionen an, ohne das Dateisystem zu verändern.
* `--user <name>`: *(Nur Linux)* Definiert den Zielbenutzer für Multi-User-Systeme.

## 🛡️ Qualitätssicherung

Das Framework verfügt über eine integrierte Test-Suite, die eine temporäre Sandbox erstellt. Hierbei werden verschiedene Betriebssysteme simuliert und die Symlink-Logik validiert, ohne dein echtes `$HOME` zu beeinflussen.

```bash
# Startet die automatisierten Funktionstests
./test_suite.sh

```

## 📄 Lizenz

Dieses Projekt ist unter der **MIT-Lizenz** lizenziert – siehe [LICENSE](https://www.google.com/search?q=LICENSE) für Details.

---
