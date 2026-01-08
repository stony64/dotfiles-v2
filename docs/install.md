# 📖 Installationsanleitung (v1.2.1)

Diese Anleitung führt Sie durch die saubere Einrichtung des Dotfiles-Systems auf **Linux** und **Windows**.

## 📋 1. Voraussetzungen

### Global

* **Bash:** Version 4.0 oder höher erforderlich (`bash --version`).
* **Git:** Installiert und im Pfad (`git --version`).

### Windows-spezifisch (Git Bash / MSYS2)

Das System nutzt **native NTFS-Symlinks**. Damit diese ohne Administratorrechte erstellt werden können, ist eine einmalige Konfiguration erforderlich:

1. **Entwicklermodus aktivieren:** `Einstellungen -> Datenschutz und Sicherheit -> Für Entwickler -> Entwicklermodus: EIN`.
2. **Umgebung:** Starten Sie die Git Bash nach der Aktivierung einmal neu.
3. **Hintergrund:** Dies erlaubt der Bash, den Befehl `ln -s` auf NTFS-Dateisysteme zu mappen, was für die Konsistenz zwischen Windows und Linux entscheidend ist.

---

## 🛠️ 2. Durchführung der Installation

### Schritt A: Repository klonen

Klonen Sie das Framework in das empfohlene Verzeichnis `.dotfiles` in Ihrem Home-Ordner:

```bash
git clone https://github.com/stony64/dotfiles-v2.git ~/.dotfiles
cd ~/.dotfiles

```

### Schritt B: Systemdiagnose (Doctor-Mode)

Bevor Änderungen am Dateisystem vorgenommen werden, führt der integrierte Diagnose-Modus eine Prüfung aller Abhängigkeiten und Berechtigungen durch:

```bash
./dotfilesctl.sh doctor

```

> **Senior-Tipp:** Achten Sie besonders auf die Meldung zu den Symlink-Rechten unter Windows. Ein `[FAIL]` an dieser Stelle bedeutet meist, dass der Entwicklermodus noch deaktiviert ist.

### Schritt C: Installation ausführen

Sobald die Diagnose grün ist (`[OK]`), starten wir die Installation. Nutzen Sie den `--dry-run` Modus, um die geplanten Verknüpfungen vorab zu validieren:

```bash
# 1. Simulation (keine Änderungen am Dateisystem)
./dotfilesctl.sh install --dry-run

# 2. Reale Installation (erstellt Symlinks und Backups)
./dotfilesctl.sh install

```

---

## 🧪 3. Verifizierung & Aktivierung

Um die neue Konfiguration sofort wirksam zu machen, ohne das Terminal neu zu starten:

1. **Shell neu laden:** `source ~/.bashrc`
2. **Alias-Check:** Geben Sie `dctl` ein. Wenn die Hilfe des Controllers erscheint, ist der Pfad korrekt gesetzt.
3. **Git-Prompt Check:** Navigieren Sie in ein beliebiges Git-Repository. Der Prompt sollte nun automatisch den aktuellen Branch in Gelb anzeigen.

---

## ⚠️ 4. Problemlösung (Troubleshooting)

| Problem | Ursache | Lösung |
| --- | --- | --- |
| **"Operation not permitted"** | Windows Symlink-Rechte fehlen. | Entwicklermodus in Windows-Einstellungen aktivieren. |
| **"SKIP: Destination exists"** | Eine echte Datei blockiert den Link. | Benennen Sie die existierende Datei manuell in `.bak` um. |
| **Prompt sieht "kaputt" aus** | Terminal unterstützt kein ANSI/Farbe. | Nutzen Sie ein modernes Terminal (Windows Terminal, Alacritty, iTerm2). |

### 💡 Best Practice: Lokale Anpassungen

Bearbeiten Sie **niemals** die Dateien im Repository für private Geheimnisse (z. B. API-Keys). Nutzen Sie stattdessen:
`touch ~/.bashrc_local`
Diese Datei wird von der `.bashrc` ignoriert (siehe `.gitignore`), aber automatisch geladen, falls sie existiert.

---

## 🔄 5. Deinstallation

Falls Sie das System entfernen möchten, stellt der Controller den Ursprungszustand weitestgehend wieder her:

```bash
./dotfilesctl.sh uninstall

```

*Hinweis: Zur Sicherheit werden existierende Backups (`.bak`) nicht automatisch gelöscht, sondern müssen bei Bedarf manuell bereinigt werden.*

---
