# 📖 Installationsanleitung (v1.2.2)

Diese Anleitung führt Sie durch die professionelle Einrichtung des Dotfiles-Systems. In der Version 1.2.2 wird das Framework zentral verwaltet, um mehrere Benutzer gleichzeitig zu unterstützen.

## 📋 1. Voraussetzungen

### Global

* **Bash:** Version 4.0 oder höher erforderlich (`bash --version`).
* **Root-Rechte:** Für die Installation in `/opt` und die Verwaltung anderer User sind `sudo`-Rechte erforderlich.

### Windows-spezifisch

* **Entwicklermodus:** Muss aktiviert sein, um native NTFS-Symlinks ohne Admin-Prompts zu erlauben.

---

## 🛠️ 2. Durchführung der Installation

### Schritt A: Zentrales Repository klonen

Wir installieren das Framework global in `/opt`, damit alle Systembenutzer auf dieselbe Logik zugreifen können.

```bash
# Repository nach /opt klonen
sudo git clone https://github.com/stony64/dotfiles-v2.git /opt/dotfiles
sudo chown -R root:root /opt/dotfiles
cd /opt/dotfiles

```

### Schritt B: Globalen Befehl (Alias) einrichten

Erstellen Sie einen Symlink in den Systempfad, um den Controller überall als `dctl` aufrufen zu können:

```bash
sudo ln -sf /opt/dotfiles/dotfilesctl.sh /usr/local/bin/dctl
sudo chmod +x /usr/local/bin/dctl

```

---

## 🚀 3. Konfiguration der Benutzer

### Szenario 1: Nur für den aktuellen Benutzer (Root)

```bash
dctl install --user root

```

### Szenario 2: Für einen spezifischen Benutzer (z. B. "stony")

Dies ist der empfohlene Weg für Multi-User-Systeme:

```bash
sudo dctl install --user stony

```

### Szenario 3: Für alle validen System-Benutzer

Ideal für die Ersteinrichtung eines neuen Servers:

```bash
sudo dctl install --all-users

```

> **Senior-Tipp:** Nutzen Sie immer zuerst `dctl doctor --user <name>`, um sicherzustellen, dass das Zielverzeichnis des jeweiligen Benutzers bereit ist.

---

## 🧪 4. Verifizierung

Nach der Installation können Sie die Integrität jederzeit systemweit prüfen:

```bash
dctl doctor --all-users

```

---

## 🔄 5. Deinstallation

Um die Links für einen bestimmten Benutzer sauber zu entfernen:

```bash
sudo dctl uninstall --user stony

```

Um das gesamte System rückstandslos zu entfernen:

1. `sudo dctl uninstall --all-users`
2. `sudo rm /usr/local/bin/dctl`
3. `sudo rm -rf /opt/dotfiles`

---

## ⚠️ 6. Wichtige Pfad-Änderungen in v1.2.2

| Alt (v1.2.1) | Neu (v1.2.2) | Grund |
| --- | --- | --- |
| `~/.dotfiles` | `/opt/dotfiles` | Zentralisierung & Multi-User Support. |
| `./dotfilesctl.sh` | `dctl` | Globaler Zugriff über den Systempfad. |
| `install` (implizit) | `install --user <name>` | Explizite Sicherheit bei Multi-User-Systemen. |

---
