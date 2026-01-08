#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: dotfilesctl.sh                                                      │
# │ ZWECK: Zentraler Orchestrator (v1.2.3 - Stable Release)                   │
# │ STANDARDS: set -euo pipefail, Bash >= 4.0                                 │
# └───────────────────────────────────────────────────────────────────────────┘

set -euo pipefail

# ──────────────────────────────────────────────────────────────
# 1. INITIALISIERUNG & MASTER-GUARD
# ──────────────────────────────────────────────────────────────

# Erlaubt das Laden der Libs und verhindert Redefinition-Fehler
DOTFILES_CORE_LOADED=1
export DOTFILES_CORE_LOADED

# Absolute Pfad-Ermittlung (folgt Symlinks zu /opt/dotfiles)
SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
readonly REPO_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# ──────────────────────────────────────────────────────────────
# 2. MODULARES LADEN (BOOTSTRAP)
# ──────────────────────────────────────────────────────────────

LIB_DIR="${REPO_ROOT}/lib"
# Die Reihenfolge ist wichtig (Farben & Konstanten zuerst)
CORE_LIBS=(
    "libcolors.sh"
    "libconstants.sh"
    "libcommon.sh"
    "libplatform_linux.sh"
    "libplatform_windows.sh"
    "libengine.sh"
    "libchecks.sh"
)

for lib in "${CORE_LIBS[@]}"; do
    if [[ -f "$LIB_DIR/$lib" ]]; then
        # shellcheck disable=SC1090
        source "$LIB_DIR/$lib"
    else
        echo -e "\e[31m[!] Kritisch: Komponente $lib in $LIB_DIR nicht gefunden.\e[0m" >&2
        exit 1
    fi
done

# ──────────────────────────────────────────────────────────────
# 3. CLI-HANDLER (STEUERUNG)
# ──────────────────────────────────────────────────────────────

usage() {
    cat << EOF
${UI_ATTR_BOLD:-}DOTFILES v1.2.3 - Management Interface${UI_COL_RESET:-}
Usage: $(basename "$0") [COMMAND] [OPTIONS]

Commands:
  install      Installiert Symlinks für einen oder alle Benutzer
  uninstall    Entfernt Symlinks und stellt Backups wieder her
  doctor       Führt eine Systemdiagnose durch
  health       Schneller Integritätscheck

Options:
  --user <name>   Ziel-Benutzer (z.B. root, stony)
  --all-users     Verarbeitet alle validen System-User (nur Linux)
  --dry-run       Simulation ohne Dateisystem-Änderungen

Beispiele:
  dctl install --user root
  sudo dctl install --all-users --dry-run
EOF
}

# Zentraler Verarbeiter für install/uninstall Operationen
cmd_action_handler() {
    local action="$1"
    shift
    local target_user=""
    local all_users=false
    local dry_run=false

    # Parsing der Argumente
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --user)      target_user="$2"; shift 2 ;;
            --all-users) all_users=true; shift ;;
            --dry-run)   export DRY_RUN=true; dry_run=true; shift ;;
            *) shift ;;
        esac
    done

    if [[ "$all_users" == true ]]; then
        # Funktion aus libengine/libplatform
        engine_process_all_users "$action"
    elif [[ -n "$target_user" ]]; then
        # Funktion aus libengine
        engine_setup_user "$target_user" "$action"
    else
        echo -e "${UI_COL_RED:-}[ X ] Fehler:${UI_COL_RESET:-} Bitte --user <name> oder --all-users angeben."
        exit 1
    fi
}

# ──────────────────────────────────────────────────────────────
# 4. MAIN ENTRY POINT
# ──────────────────────────────────────────────────────────────

main() {
    local cmd="${1:-}"

    # Header ausgeben
    echo -e "${UI_ATTR_BOLD:-}${UI_COL_BLUE:-}>>> Dotfiles Control v1.2.3 (Root: $REPO_ROOT)${UI_COL_RESET:-}"

    case "$cmd" in
        install|uninstall)
            cmd_action_handler "$@"
            ;;
        doctor|health)
            # Delegation an libchecks.sh
            shift
            cmd_diagnosis_handler "$@"
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

# Skript ausführen
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
