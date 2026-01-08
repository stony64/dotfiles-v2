# 🛠️ Dotfiles Management System (v1.2.2)

Ein hochmodulares, plattformübergreifendes Framework zur Verwaltung von Konfigurationsdateien. Optimiert für maximale Konsistenz zwischen nativen **Linux-Systemen** und **Windows-Umgebungen** (Git Bash / MSYS2). In der Version 1.2.2 für den **zentralen Multi-User-Einsatz** optimiert.

## 🚀 Highlights

* **Zentrale Verwaltung:** Installation in `/opt/dotfiles` ermöglicht die Steuerung mehrerer Benutzer-Profile von einer Code-Basis aus.
* **Plattform-Agnostisch:** Einheitliche Logik für Linux und Windows mit automatischer Erkennung zur Laufzeit.
* **Native Windows Symlinks:** Nutzt `winsymlinks:nativestrict` für echte NTFS-Symlinks statt bloßer Dateikopien.
* **Modulare Architektur:** Striktes "Separation of Concerns" zwischen Logik-Bibliotheken (`lib/`) und User-Konfiguration (`home/`).
* **Integrierte Diagnose:** Der `doctor`-Modus validiert Abhängigkeiten, Pfade und kritische Berechtigungen systemweit.
* **Sicher & Robust:** Idempotente Operationen und konfliktfreier Namespace durch `_VAL`-Suffixe in den Bibliotheken.

## 📂 Projektstruktur

```text
/opt/dotfiles/            # Zentraler Installationspfad (System-Standard)
├── dotfilesctl.sh        # Zentraler Orchestrator (Main Entry Point)
├── test_suite.sh         # Automatisierte Sandbox-Validierung (v1.2.2)
├── lib/                  # Kern-Bibliotheken (Namespace-gesichert)
│   ├── libcolors.sh      # Atomare ANSI-Werte (_VAL)
│   ├── libconstants.sh   # Zusammengesetzte UI-Sequenzen & Whitelists
│   ├── libplatform_*.sh  # OS-spezifische Abstraktionslayer
│   └── libengine.sh      # Symlink-, Backup- & Kernlogik
├── home/                 # Die eigentlichen Dotfiles (Templates)
│   ├── .bashrc           # Haupt-Initialisierung der Shell
│   ├── .bashenv          # Umgebungsvariablen & Pfade
│   └── .bashprompt        # Dynamisches Git-Prompt Design
└── docs/                 # Vertiefende Dokumentation (v1.2.2 Update)

```

## 🛠️ Installation

### Voraussetzungen

* **Bash >= 4.0**
* **Git**
* **Sudo-Rechte:** Erforderlich für die Einrichtung in `/opt` und Multi-User-Operationen.

### Schnellstart (Empfohlen)

```bash
# 1. Repository zentral klonen
sudo git clone https://github.com/stony64/dotfiles-v2.git /opt/dotfiles
sudo chown -R root:root /opt/dotfiles

# 2. Globalen Befehl 'dctl' registrieren
sudo ln -sf /opt/dotfiles/dotfilesctl.sh /usr/local/bin/dctl
sudo chmod +x /usr/local/bin/dctl

# 3. System-Integrität prüfen
dctl doctor --user root

# 4. Installation für einen Benutzer (z.B. root oder stony)
dctl install --user root

```

## 💻 Benutzung

Durch den Symlink in `/usr/local/bin` ist der Befehl **`dctl`** systemweit verfügbar.

| Befehl | Beschreibung |
| --- | --- |
| `dctl install` | Erstellt Symlinks & Backups (erfordert `--user` oder `--all-users`). |
| `dctl uninstall` | Entfernt Symlinks sicher und stellt Backups wieder her. |
| `dctl doctor` | Validiert Tools, Pfade und Symlink-Berechtigungen. |
| `dctl health` | Schneller System-Check der Abhängigkeiten. |
| `dctl update` | Aktualisiert das zentrale Repo via Git Pull. |

### Globale Optionen

* `--dry-run`: Simulation: Zeigt Änderungen an, ohne sie auszuführen.
* `--user <name>`: Zielbenutzer für die Operation (z.B. `root`, `stony`).
* `--all-users`: Verarbeitet alle validen Home-Verzeichnisse (nur Linux).

## 🛡️ Qualitätssicherung

Das Framework nutzt eine dedizierte Test-Suite, um die Integrität nach Pfadänderungen oder Updates zu gewährleisten.

```bash
# Startet die automatisierten Funktionstests für v1.2.2
/opt/dotfiles/test_suite.sh

```

## 📄 Lizenz

Dieses Projekt ist unter der **MIT-Lizenz** lizenziert – siehe [LICENSE](https://www.google.com/search?q=LICENSE) für Details.

---
