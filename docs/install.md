# Installationsanleitung (v1.2.1)

Diese Anleitung beschreibt die saubere Einrichtung des Dotfiles-Systems auf Linux und Windows.

## 📋 1. Voraussetzungen

### Global

* **Bash:** Version 4.0 oder höher erforderlich (`bash --version`).
* **Git:** Erforderlich für Updates und Repository-Management.

### Windows (Git Bash / MSYS2)

Das System nutzt native NTFS-Symlinks. Damit dies ohne Administratorrechte funktioniert:

1. **Entwicklermodus aktivieren:** `Einstellungen -> Datenschutz und Sicherheit -> Für Entwickler -> Entwicklermodus: EIN`.
2. **Umgebung:** Starte die Git Bash nach Aktivierung des Entwicklermodus neu.

---

## 🛠️ 2. Installation

### Schritt A: Repository klonen

Klonen Sie das Repository direkt in den Zielordner:

```bash
git clone https://github.com/stony64/dotfiles-v2.git ~/.dotfiles
cd ~/.dotfiles

```

### Schritt B: Systemdiagnose

Bevor Änderungen vorgenommen werden, prüft der „Doctor“ die Schreibrechte und Tools:

```bash
./dotfilesctl.sh doctor

```

### Schritt C: Installation ausführen

Wenn die Diagnose grün ist (Symbol: `[OK]`), führen Sie die Installation aus. Wir empfehlen den `--dry-run` Modus für den ersten Testlauf:

```bash
# Optional: Simulation starten
./dotfilesctl.sh install --dry-run

# Reale Installation
./dotfilesctl.sh install

```

---

## 🧪 3. Verifizierung

Um die neue Umgebung zu aktivieren und zu testen:

1. **Shell neu laden:** `source ~/.bashrc`
2. **Prompt-Test:** Navigiere in ein Git-Verzeichnis – der Branch-Name sollte farbig erscheinen.
3. **Alias-Test:** Tippe `dctl doctor` – der Alias für den Controller muss sofort funktionieren.

---

## ⚠️ 4. Problemlösung (Troubleshooting)

### Fehler: "Operation not permitted" (Windows)

* **Ursache:** Fehlende Berechtigung für native Symlinks.
* **Lösung:** Entwicklermodus aktivieren (siehe Punkt 1). Falls es weiterhin scheitert, prüfen Sie mit `echo $MSYS`, ob `winsymlinks:nativestrict` gesetzt ist.

### Fehler: Konflikte mit existierenden Dateien

* **Verhalten:** Die Engine überschreibt niemals "echte" Dateien ohne Backup.
* **Lösung:** Wenn die Engine meldet `SKIP: Ziel existiert bereits`, benenne deine alte Datei manuell um oder lösche sie, falls sie nicht mehr benötigt wird.

### Best Practice: Lokale Anpassungen

Nutze die Datei `~/.bashrc_local` für Einstellungen, die **nicht** in das öffentliche Git-Repository gehören (z. B. private Aliase oder spezifische Exporte). Diese Datei wird automatisch von der `.bashrc` geladen, falls sie existiert.

---

## 🔄 5. Deinstallation

Das System kann jederzeit rückstandslos entfernt werden:

```bash
./dotfilesctl.sh uninstall

```

*Hinweis: Erstellte Backups (`.bak`) werden zur Sicherheit nicht automatisch gelöscht.*

---
