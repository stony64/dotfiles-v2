#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: lib/libengine.sh                                                    │
# │ ZWECK: Kern-Logik für idempotente Symlink-Verwaltung und Backups          │
# │ STANDARDS: set -euo pipefail, Bash >= 4.0, Google Shell Style Guide       │
# └───────────────────────────────────────────────────────────────────────────┘

# INCLUDE GUARD
# Include-Guard (verhindert Mehrfachladen und schützt vor readonly-Fehlern)
[[ -n "${_LIB_$(basename "${BASH_SOURCE[0]}" .sh | tr '[:lower:]' '[:upper:]')_LOADED:-}" ]] && return
declare -g _LIB_$(basename "${BASH_SOURCE[0]}" .sh | tr '[:lower:]' '[:upper:]')_LOADED=1

# @description Erstellt einen Symlink idempotent und sichert reale Dateien.
# @param $1 Quell-Pfad (absolut, im Repository).
# @param $2 Ziel-Pfad (absolut, im Home-Verzeichnis).
# @return EXIT_OK oder EXIT_FATAL.
engine_create_link() {
    local src="$1"
    local dest="$2"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)

    # 1. Validierung: Existiert die Quelle im Repo?
    [[ ! -e "$src" ]] && { log_error "Quelle nicht im Repo: '$src'"; return "${EXIT_FATAL:-1}"; }

    # 2. Idempotenz-Check: Existiert bereits ein korrekter Link?
    if [[ -L "$dest" ]]; then
        local current_target
        current_target=$(canon_path "$dest")
        if [[ "$current_target" == "$(canon_path "$src")" ]]; then
            log_info "Link für '$(basename "$dest")' ist bereits korrekt. Überspringe."
            return "${EXIT_OK:-0}"
        fi
        # Link ist falsch -> entfernen für Neu-Erstellung
        log_warn "Link '$(basename "$dest")' ist veraltet/falsch. Korrigiere..."
        run rm "$dest"
    fi

    # 3. Backup-Logik: Reale Datei/Ordner blockiert den Pfad
    if [[ -e "$dest" && ! -L "$dest" ]]; then
        local backup_path="${dest}.bak_${timestamp}"
        log_warn "Reale Datei blockiert Pfad: '$(basename "$dest")'. Erstelle Backup..."

        if run mv "$dest" "$backup_path"; then
            log_info "Backup erstellt: '$(basename "$backup_path")'"
        else
            log_error "Backup fehlgeschlagen: '$dest'"
            return "${EXIT_FATAL:-1}"
        fi
    fi

    # 4. Verzeichnisstruktur sicherstellen
    local dest_dir
    dest_dir=$(dirname "$dest")
    [[ ! -d "$dest_dir" ]] && run mkdir -p "$dest_dir"

    # 5. Symlink erstellen (Plattform-Abstraktion nutzen)
    # Nutzt 'run' für Dry-Run Support
    if run ln -sf "$src" "$dest"; then
        log_info "${UI_COL_GREEN:-}Link erfolgreich erstellt: '$(basename "$dest")'${UI_COL_RESET:-}"
        return "${EXIT_OK:-0}"
    else
        log_error "Link-Erstellung fehlgeschlagen: '$dest'"
        return "${EXIT_FATAL:-1}"
    fi
}

# @description Entfernt Symlinks sauber.
# @param $1 Ziel-Pfad (der Symlink).
# @return EXIT_OK.
engine_remove_link() {
    local target="$1"

    if [[ -L "$target" ]]; then
        if run rm "$target"; then
            log_info "Symlink entfernt: '$(basename "$target")'"
        else
            log_error "Konnte Symlink nicht entfernen: '$target'"
        fi
    else
        log_info "Kein Symlink gefunden für '$(basename "$target")'. Keine Aktion erforderlich."
    fi

    return "${EXIT_OK:-0}"
}

true
