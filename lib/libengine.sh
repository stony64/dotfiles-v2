#!/usr/bin/env bash
#
# FILE: lib/libengine.sh
# ──────────────────────────────────────────────────────────────
# KERN-LOGIK FÜR SYMLINKS UND BACKUPS
# ──────────────────────────────────────────────────────────────
# Zweck:       Automatisiert das Verlinken von Dotfiles und sichert
#              existierende reale Dateien mit Zeitstempel.
# Standards:   set -euo pipefail, Bash >= 4.0.
# ──────────────────────────────────────────────────────────────

[[ -n "${_LIB_ENGINE_LOADED:-}" ]] && return
readonly _LIB_ENGINE_LOADED=1

# @description Erstellt einen Symlink und sichert bestehende Dateien.
# @param $1 Quell-Pfad (absolut, im Repository).
# @param $2 Ziel-Pfad (absolut, im Home-Verzeichnis).
# @return 0 bei Erfolg, 1 bei Fehlern.
engine_create_link() {
    local src="$1"
    local dest="$2"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)

    # 1. Validierung: Existiert die Quelle im Repo?
    if [[ ! -e "$src" ]]; then
        ui_print_error "Quelle nicht gefunden: '$src'"
        return 1
    fi

    # 2. Backup-Logik: Nur für reale Dateien (keine Symlinks)
    if [[ -e "$dest" || -L "$dest" ]]; then
        if [[ -L "$dest" ]]; then
            # Bestehenden Symlink einfach entfernen (Idempotenz)
            rm "$dest"
        elif [[ -f "$dest" || -d "$dest" ]]; then
            # Reale Datei/Ordner -> Sicherung mit Zeitstempel
            local backup_path="${dest}.bak_${timestamp}"
            ui_print_info "Sichere reale Datei: '$(basename "$dest")' -> '$(basename "$backup_path")'"

            if ! mv "$dest" "$backup_path"; then
                ui_print_error "Backup fehlgeschlagen für '$dest'"
                return 1
            fi
        fi
    fi

    # 3. Verzeichnisstruktur sicherstellen
    local dest_dir
    dest_dir=$(dirname "$dest")
    [[ ! -d "$dest_dir" ]] && mkdir -p "$dest_dir"

    # 4. Symlink erstellen (delegiert an plattformspezifische Lib)
    if platform_create_symlink "$src" "$dest"; then
        ui_print_ok "Link erstellt: '$(basename "$dest")'"
        return 0
    else
        ui_print_error "Symlink-Erstellung fehlgeschlagen: '$dest'"
        return 1
    fi
}

# @description Entfernt Symlinks und informiert über verbliebene Backups.
# @param $1 Ziel-Pfad (der Symlink).
engine_remove_link() {
    local target="$1"

    if [[ -L "$target" ]]; then
        if rm "$target"; then
            ui_print_ok "Symlink entfernt: '$(basename "$target")'"
        else
            ui_print_error "Konnte Symlink nicht entfernen: '$target'"
        fi
    else
        ui_print_info "Kein Symlink gefunden: '$(basename "$target")' - überspringe."
    fi
}

true
