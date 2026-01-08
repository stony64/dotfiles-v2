#!/usr/bin/env bash
#
# FILE: lib/libcommon.sh
# ──────────────────────────────────────────────────────────────
# BASIS-HILFSFUNKTIONEN UND WRAPPER (v1.2.1)
# ──────────────────────────────────────────────────────────────
# Zweck:     Zentrale Logik für Logging, Fehlerbehandlung und
#            sichere Befehlsausführung (Dry-Run Support).
# ──────────────────────────────────────────────────────────────

# 1. INCLUDE GUARD
[[ -n "${_LIB_COMMON_LOADED:-}" ]] && return
readonly _LIB_COMMON_LOADED=1

# @description Gibt eine Informationsmeldung in Cyan aus.
log_info() {
    echo -e "${LOG_PREFIX_INFO} ${UI_COL_CYAN}$1${UI_COL_RESET}"
}

# @description Gibt eine Warnmeldung in Gelb aus.
log_warn() {
    echo -e "${LOG_PREFIX_WARN} ${UI_COL_YELLOW}$1${UI_COL_RESET}"
}

# @description Gibt eine Fehlermeldung in Rot auf stderr aus.
log_error() {
    echo -e "${LOG_PREFIX_ERROR} ${UI_COL_RED}$1${UI_COL_RESET}" >&2
}

# @description Beendet das Skript sofort mit einer Fehlermeldung.
die() {
    log_error "$1"
    exit "$EXIT_FATAL"
}

# @description Führt Befehle aus oder simuliert sie im Dry-Run Modus.
# @param $@ Der auszuführende Befehl inklusive aller Argumente.
run() {
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
        # Nutze STYLE_DIM für die Anzeige des simulierten Befehls
        echo -e "${UI_COL_YELLOW}[DRY-RUN]${UI_COL_RESET} $ ${STYLE_DIM:-}$*${UI_COL_RESET}"
        return "$EXIT_OK"
    fi
    "$@"
}

# @description Prüft leise, ob ein Befehl im Systempfad verfügbar ist.
has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# @description Erzwingt das Vorhandensein eines Befehls und bricht sonst ab.
require_cmd() {
    if ! has_cmd "$1"; then
        die "Erforderliches Tool nicht gefunden: $1. Bitte installieren."
    fi
}

# @description Formatiert einen Header für Log-Sektionen.
log_section() {
    local title="$1"
    local line="──────────────────────────────────────────────────────────────"
    echo -e "\n${UI_COL_BLUE}${line}${UI_COL_RESET}"
    echo -e "${STYLE_BOLD}${title}${UI_COL_RESET}"
    echo -e "${UI_COL_BLUE}${line}${UI_COL_RESET}"
}

true
