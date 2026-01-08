#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: lib/libcommon.sh                                                    │
# │ ZWECK: Zentrale Logging-Logik, Fehlerbehandlung und Command-Wrapper       │
# │ STANDARDS: set -euo pipefail, Bash >= 4.0, Google Shell Style Guide       │
# └───────────────────────────────────────────────────────────────────────────┘


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

# @description Führt Befehle aus oder simuliert sie (Dry-Run).
# Verhindert im Dry-Run Modus die Ausführung, loggt aber den versuchten Befehl.
# @param $@ Der auszuführende Befehl.
run() {
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
        # Simulation: Befehl wird nur angezeigt, nicht ausgeführt.
        echo -e "${UI_COL_YELLOW:-}[DRY-RUN]${UI_COL_RESET:-} ${UI_ATTR_DIM:-}$*${UI_COL_RESET:-}"
        return "${EXIT_OK:-0}"
    fi

    # Direkte Ausführung. set -e sorgt bei Fehlern für Abbruch,
    # sofern nicht im Aufrufer abgefangen.
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

# @description Formatiert einen optisch abgegrenzten Header.
# @param $1 Titel der Sektion.
log_section() {
    local title="$1"
    local line="──────────────────────────────────────────────────────────────"
    echo -e "\n${UI_COL_BLUE:-}${line}${UI_COL_RESET:-}"
    echo -e "${UI_ATTR_BOLD:-}${title}${UI_COL_RESET:-}"
    echo -e "${UI_COL_BLUE:-}${line}${UI_COL_RESET:-}"
}

true
