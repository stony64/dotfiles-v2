#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: lib/libcommon.sh                                                    │
# │ ZWECK: Zentrale Logging-Logik, Fehlerbehandlung und Command-Wrapper       │
# │ STANDARDS: set -euo pipefail, Bash >= 4.0, Google Shell Style Guide       │
# └───────────────────────────────────────────────────────────────────────────┘

# Master-Guard: Verhindert direktes Ausführen ohne Controller
[[ -n "${DOTFILES_CORE_LOADED:-}" ]] || return

# ──────────────────────────────────────────────────────────────
# 1. LOGGING & UI
# ──────────────────────────────────────────────────────────────

# @description Gibt eine Informationsmeldung aus.
# @param $1 Nachrichtentext.
log_info() {
    echo -e "${LOG_PREFIX_INFO:-[INFO]} ${UI_COL_CYAN:-}$1${UI_COL_RESET:-}"
}

# @description Gibt eine Warnmeldung aus.
# @param $1 Nachrichtentext.
log_warn() {
    echo -e "${LOG_PREFIX_WARN:-[WARN]} ${UI_COL_YELLOW:-}$1${UI_COL_RESET:-}"
}

# @description Gibt eine Fehlermeldung auf stderr aus.
# @param $1 Nachrichtentext.
log_error() {
    echo -e "${LOG_PREFIX_ERROR:-[ERROR]} ${UI_COL_RED:-}$1${UI_COL_RESET:-}" >&2
}

# @description Beendet das Skript sofort mit einer Fehlermeldung.
# @param $1 Fehlerursache.
die() {
    log_error "FATAL: $1"
    exit "${EXIT_FATAL:-1}"
}

# @description Formatiert einen optisch abgegrenzten Header.
# @param $1 Titel der Sektion.
log_section() {
    local title="$1"
    local line="──────────────────────────────────────────────────────────────"
    echo -e "\n${UI_COL_BLUE:-}${line}${UI_COL_RESET:-}"
    echo -e "${UI_ATTR_BOLD:-}${title}${UI_COL_RESET:-}"
    echo -e "${UI_COL_BLUE:-}${line}${UI_COL_RESET:-}"
}

# ──────────────────────────────────────────────────────────────
# 2. BEFEHLS-WRAPPER & DRY-RUN
# ──────────────────────────────────────────────────────────────

# @description Führt Befehle aus oder simuliert sie (Dry-Run).
# Verhindert im Dry-Run Modus die Ausführung, loggt aber den versuchten Befehl.
# @param $@ Der auszuführende Befehl.
run() {
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
        # Simulation: Befehl wird nur angezeigt, nicht ausgeführt.
        echo -e "${UI_COL_YELLOW:-}[DRY-RUN]${UI_COL_RESET:-} ${UI_ATTR_DIM:-}$*${UI_COL_RESET:-}"
        return "${EXIT_OK:-0}"
    fi

    # Direkte Ausführung.
    # set -e sorgt bei Fehlern für Abbruch, sofern nicht im Aufrufer abgefangen.
    "$@"
}

# @description Prüft leise, ob ein Befehl verfügbar ist.
# @param $1 Name des Befehls.
has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# @description Erzwingt das Vorhandensein eines Befehls.
# @param $1 Name des Befehls.
require_cmd() {
    if ! has_cmd "$1"; then
        die "Erforderliches Tool nicht gefunden: $1. Bitte installieren."
    fi
}

# ──────────────────────────────────────────────────────────────
# 3. DATEI- & PFAD-LOGIK (DIE FEHLENDEN FUNKTIONEN)
# ──────────────────────────────────────────────────────────────

# @description Ermittelt das Home-Verzeichnis eines Benutzers.
# Funktioniert plattformübergreifend (Linux & Git Bash).
# @param $1 Benutzername (z.B. "root" oder "stony").
# @return Absoluter Pfad zum Home (stdout).
get_user_home() {
    local user="$1"

    # Expliziter Root-Check für Stabilität
    if [[ "$user" == "root" ]]; then
        echo "/root"
        return
    fi

    # Sichere Tilde-Expansion für den User
    if getent passwd "$user" >/dev/null 2>&1; then
        eval echo "~$user"
    else
        # Fallback für Git Bash oder wenn User nicht in /etc/passwd
        echo "$HOME"
    fi
}

# @description Erstellt einen Symlink mit Backup-Logik.
# @param $1 Dateiname (z.B. ".bashrc") relativ zu home/.
# @param $2 Zielverzeichnis (Absoluter Pfad zum User-Home).
create_symlink() {
    local file="$1"
    local target_dir="$2"

    # REPO_ROOT muss vom Controller exportiert sein
    local source_path="${REPO_ROOT}/home/${file}"
    local target_path="${target_dir}/${file}"

    # 1. Quell-Check
    if [[ ! -e "$source_path" ]]; then
        # Nur Warnung, kein Abbruch (Whitelist könnte veraltet sein)
        # log_warn "Überspringe $file: Nicht im Repo gefunden ($source_path)."
        return
    fi

    # 2. Backup-Logik (Idempotenz)
    # Wir backuppen nur, wenn dort eine "echte" Datei liegt, kein Symlink.
    if [[ -e "$target_path" && ! -L "$target_path" ]]; then
        log_info "Erstelle Backup für existierende Datei: $file"
        run mv "$target_path" "${target_path}.bak"
    fi

    # 3. Link erstellen (Force Update)
    # ln -sf überschreibt auch existierende (falsche) Symlinks
    run ln -sf "$source_path" "$target_path"

    # Optional: Status-Ausgabe (Verbosity checken?)
    echo -e "    ${UI_COL_GREEN:-}${SYMBOL_OK:-}${UI_COL_RESET:-} Verlinkt: $file"
}

# @description Entfernt einen Symlink und stellt Backups wieder her.
# @param $1 Dateiname.
# @param $2 Zielverzeichnis.
remove_symlink() {
    local file="$1"
    local target_dir="$2"
    local target_path="${target_dir}/${file}"

    # 1. Link entfernen
    if [[ -L "$target_path" ]]; then
        run rm "$target_path"
        echo -e "    ${UI_COL_YELLOW:-}${SYMBOL_OK:-}${UI_COL_RESET:-} Link entfernt: $file"
    fi

    # 2. Backup wiederherstellen
    if [[ -f "${target_path}.bak" ]]; then
        # Prüfen, ob das Ziel jetzt frei ist
        if [[ ! -e "$target_path" ]]; then
            run mv "${target_path}.bak" "$target_path"
            echo -e "    ${UI_COL_BLUE:-}${SYMBOL_INFO:-}${UI_COL_RESET:-} Backup wiederhergestellt: $file"
        else
            log_warn "Konnte Backup für $file nicht wiederherstellen (Ziel blockiert)."
        fi
    fi
}

true
