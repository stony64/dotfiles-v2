#!/usr/bin/env bash
#
# FILE: lib/libcommon.sh
# ──────────────────────────────────────────────────────────────
# BASIS-HILFSFUNKTIONEN UND WRAPPER
# ──────────────────────────────────────────────────────────────
# Zweck:    Zentrale Logik für Logging, Fehlerbehandlung und
#           sichere Befehlsausführung (Dry-Run Support).
# Abhängigkeiten: libcolors.sh, libconstants.sh
# ──────────────────────────────────────────────────────────────

# @description Gibt eine Informationsmeldung in Cyan aus.
# @param $1 Die auszugebende Nachricht.
# @stdout Formatierter String mit LOG_PREFIX_INFO.
log_info() {
    echo -e "${LOG_PREFIX_INFO} ${COL_CYAN}$1${COL_RESET}"
}

# @description Gibt eine Warnmeldung in Gelb aus.
# @param $1 Die auszugebende Nachricht.
# @stdout Formatierter String mit LOG_PREFIX_WARN auf stdout.
log_warn() {
    echo -e "${LOG_PREFIX_WARN} ${COL_YELLOW}$1${COL_RESET}"
}

# @description Gibt eine Fehlermeldung in Rot auf stderr aus.
# @param $1 Die auszugebende Nachricht.
# @stdout Formatierter String mit LOG_PREFIX_ERROR auf stderr.
log_error() {
    echo -e "${LOG_PREFIX_ERROR} ${COL_RED}$1${COL_RESET}" >&2
}

# @description Beendet das Skript sofort mit einer Fehlermeldung.
# @param $1 Die Fehlermeldung, die den Abbruch erklärt.
# @stdout Fehlermeldung auf stderr.
# @return EXIT_FATAL (1)
die() {
    log_error "$1"
    exit "$EXIT_FATAL"
}

# @description Führt Befehle aus oder simuliert sie im Dry-Run Modus.
# @param $@ Der auszuführende Befehl inklusive aller Argumente.
# @stdout Gibt den Befehl aus, wenn DRY_RUN=1 aktiv ist.
# @return Rückgabewert des ausgeführten Befehls oder 0 bei Dry-Run.
run() {
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
        echo -e "${COL_YELLOW}[DRY-RUN]${COL_RESET} $ ${ATTR_DIM}$*${COL_RESET}"
        return "$EXIT_OK"
    fi
    "$@"
}

# @description Prüft leise, ob ein Befehl im Systempfad verfügbar ist.
# @param $1 Name des zu prüfenden Befehls.
# @return 0 wenn gefunden, 1 wenn nicht vorhanden.
has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

# @description Erzwingt das Vorhandensein eines Befehls und bricht sonst ab.
# @param $1 Name des erforderlichen Befehls.
# @return EXIT_OK oder bricht via die() ab.
require_cmd() {
    if ! has_cmd "$1"; then
        die "Erforderliches Tool nicht gefunden: $1. Bitte installieren."
    fi
}

# @description Formatiert einen Header für Log-Sektionen.
# @param $1 Titel der Sektion.
# @stdout Ein eingerahmter Header-Block.
log_section() {
    local title="$1"
    local line="──────────────────────────────────────────────────────────────"
    echo -e "\n${COL_BLUE}${line}${COL_RESET}"
    echo -e "${STYLE_BOLD}${title}${COL_RESET}"
    echo -e "${COL_BLUE}${line}${COL_RESET}"
}

true
