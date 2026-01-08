# Installationsanleitung (v1.2.1)

Diese Anleitung beschreibt die saubere Einrichtung des Dotfiles-Systems auf Linux und Windows.

## 📋 1. Voraussetzungen

Bevor du beginnst, stelle sicher, dass folgende Anforderungen erfüllt sind:

### Global

- **Bash:** Version 4.0 oder höher erforderlich (`bash --version`).
- **Git:** Erforderlich für Updates und Versionierung.

### Windows (Git Bash / MSYS2)

Das System nutzt native NTFS-Symlinks. Damit dies ohne Administratorrechte funktioniert:

1. **Entwicklermodus aktivieren:** `Einstellungen -> Datenschutz und Sicherheit -> Für Entwickler -> Entwicklermodus: EIN`.
2. **Git Bash:** Muss aktuell sein, um MSYS-Pfade korrekt aufzulösen.

---

## 🛠️ 2. Installation

### Schritt A: Repository klonen

Es wird empfohlen, das Repository in einen versteckten Ordner in deinem Home-Verzeichnis zu klonen:

```bash
git clone [https://github.com/dein-user/dotfiles.git](https://github.com/dein-user/dotfiles.git) ~/.dotfiles
cd ~/.dotfiles

```

### Schritt B: Systemdiagnose (Wichtig!)

Führe den integrierten „Doctor“ aus, um sicherzustellen, dass dein System bereit für die Symlink-Erstellung ist:

```bash
./dotfilesctl.sh doctor

```

### Schritt C: Installation ausführen

Wenn die Diagnose grün ist, kannst du die Installation starten.

**Unter Linux:**
Hier muss explizit der Benutzer angegeben werden (oder `--all-users` als Root):

```bash
./dotfilesctl.sh install --user $(whoami)

```

**Unter Windows:**

```bash
./dotfilesctl.sh install

```

---

## 🧪 3. Verifizierung

Nach der Installation solltest du prüfen, ob die Shell-Module korrekt geladen werden:

1. Starte dein Terminal neu oder führe `source ~/.bashrc` aus.
2. Prüfe den Prompt: Erscheint der Branch-Name, wenn du in ein Git-Repo wechselst?
3. Teste einen Alias: Tippe `ll` oder `..`.
4. Teste den Controller-Alias: Tippe `dctl doctor`.

---

## ⚠️ 4. Problemlösung (Troubleshooting)

### Fehler: "Operation not permitted" (Windows)

Dies bedeutet, dass Windows das Erstellen von Symlinks blockiert.

- **Lösung:** Stelle sicher, dass der **Entwicklermodus** (siehe oben) aktiviert ist. Ein Neustart der Git Bash ist danach zwingend erforderlich.

### Fehler: "Bash version too old"

Manche MacOS-Versionen nutzen standardmäßig Bash 3.2.

- **Lösung:** Installiere eine aktuelle Bash via Homebrew (`brew install bash`) und setze sie als Standard-Shell.

### Fehler: Konflikte mit existierenden Dateien

Falls eine `.bashrc` bereits existiert, wird die Engine diese sichern (`.bashrc.bak`), bevor der Symlink erstellt wird. Du kannst deine alten Anpassungen dann manuell in die `~/.bashrc_local` übertragen.

---

## 🔄 5. Deinstallation

Möchtest du das System sauber entfernen, ohne deine Backups zu verlieren:

```bash
./dotfilesctl.sh uninstall

```

Dieser Befehl entfernt nur die vom System erstellten Symlinks und lässt deine `.bak` Dateien unberührt.
