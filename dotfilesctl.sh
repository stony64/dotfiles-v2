#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: dotfilesctl.sh                                                      │
# │ ZWECK: Zentraler Orchestrator (Multi-User & /opt fähig)                   │
# │ VERSION: 1.2.2-stable                                                     │
# │ STANDARDS: set -euo pipefail, Bash >= 4.0, Modulares Design               │
# └───────────────────────────────────────────────────────────────────────────┘

set -euo pipefail

# ──────────────────────────────────────────────────────────────
# 1. INITIALISIERUNG & PFAD-AUFLÖSUNG
# ──────────────────────────────────────────────────────────────

# Bash-Versionsprüfung (Assoziative Arrays & mapfile Support erforderlich)
if (( BASH_VERSINFO[0] < 4 )); then
    echo -e "\e[31m[ X ] Fehler: Bash >= 4.0 erforderlich (gefunden: ${BASH_VERSION}).\e[0m" >&2
    exit 1
fi

# Ermittlung des absoluten Repo-Roots (Symlink-aware)
# Dies erlaubt den Aufruf via /usr/local/bin/dctl -> /opt/dotfiles/dotfilesctl.sh
SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
readonly REPO_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# ──────────────────────────────────────────────────────────────
# 2. MODULARES LADEN DER BIBLIOTHEKEN
# ──────────────────────────────────────────────────────────────

LIB_FILES=(
    "libcolors.sh"
    "libconstants.sh"
    "libcommon.sh"
    "libplatform_linux.sh"
    "libplatform_windows.sh"
    "libengine.sh"
    "libchecks.sh"
)

for lib in "${LIB_FILES[@]}"; do
    lib_path="${REPO_ROOT}/lib/$lib"
    if [[ -f "$lib_path" ]]; then
        # shellcheck disable=SC1090
        source "$lib_path"
    else
        echo -e "\e[31mKRITISCH: Bibliothek nicht gefunden: $lib_path\e[0m" >&2
        exit 1
    fi
done

# ──────────────────────────────────────────────────────────────
# 3. CLI FUNKTIONEN
# ──────────────────────────────────────────────────────────────

# @description Zeigt die Hilfe und Nutzungsinformationen an.
usage() {
    echo -e "${UI_ATTR_BOLD:-}${UI_COL_YELLOW:-}Dotfiles Controller${UI_COL_RESET:-} (v1.2.2)"
    echo -e "Location:  ${UI_COL_CYAN:-}${REPO_ROOT}${UI_COL_RESET:-}"
    echo -e "System-OS: ${UI_COL_MAGENTA:-}$(uname -s)${UI_COL_RESET:-}\n"
    cat <<EOF
Nutzung: $(basename "$0") BEFEHL [OPTIONEN]

Befehle:
    install         Erstellt Symlinks idempotent gemäß Whitelist.
    uninstall       Entfernt Symlinks aus den Zielverzeichnissen.
    update          Repository-Update via 'git pull --ff-only'.
    health          System-Check (Abhängigkeiten & Plattform-Sicherheit).
    checksymlinks   Integritätsprüfung der vorhandenen Links (Idempotenz-Test).
    doctor          Vollständige Diagnose (Health + Symlinks).

Optionen:
    --dry-run       Simulation: Keine Schreiboperationen ausführen.
    --strict        Behandelt Warnungen als fatale Fehler (Exit 1).
    --all-users     (Linux) Wendet Aktion auf alle validen Home-Verzeichnisse an.
    --user <name>   (Linux) Spezifischen System-Benutzer ansteuern.
    --help          Diese Hilfe anzeigen.
EOF
}

# @description Delegiert Installations-Aktionen an die Engine.
cmd_install_uninstall() {
    local action="$1" os="$2" all="$3" user="$4"
    local error_count=0

    if [[ "$os" == "linux" ]]; then
        platform_linux_require_root

        local users_to_process=()
        if [[ "$all" -eq 1 ]]; then
            mapfile -t users_to_process < <(platform_linux_list_target_users)
        elif [[ -n "$user" ]]; then
            platform_linux_validate_user "$user" && users_to_process+=("$user") || die "User '$user' ungültig."
        else
            die "Auf Linux ist --all-users oder --user <name> erforderlich."
        fi

        for u in "${users_to_process[@]}"; do
            local home
            home="$(getent passwd "$u" | cut -d: -f6)"
            log_info "Verarbeite Benutzer: ${UI_COL_CYAN:-}$u${UI_COL_RESET:-} ($home)"

            for file in "${DOTFILES_WHITELIST[@]}"; do
                if [[ "$action" == "install" ]]; then
                    engine_create_link "${REPO_ROOT}/home/${file}" "${home}/${file}" || ((error_count++))
                else
                    engine_remove_link "${home}/${file}" || ((error_count++))
                fi
            done
        done
    else
        # Windows-Pfad (Single User Kontext)
        [[ "$all" -eq 1 || -n "$user" ]] && die "User-Wahl unter Windows wird nicht unterstützt."
        [[ "$action" == "install" ]] && platform_windows_require_symlink_rights

        log_info "Verarbeite Windows-Benutzer: ${UI_COL_CYAN:-}$USER${UI_COL_RESET:-} ($HOME)"
        for file in "${DOTFILES_WHITELIST[@]}"; do
            if [[ "$action" == "install" ]]; then
                engine_create_link "${REPO_ROOT}/home/${file}" "${HOME}/${file}" || ((error_count++))
            else
                engine_remove_link "${HOME}/${file}" || ((error_count++))
            fi
        done
    fi

    [[ $error_count -gt 0 ]] && exit "${EXIT_FATAL:-1}"
    return "${EXIT_OK:-0}"
}

# @description Führt Diagnosen aus und aggregiert die Ergebnisse.
cmd_health_checks() {
    local action="$1" os="$2" all="$3" user="$4"
    local total_warns=0 total_errors=0

    update_counters() {
        case "$1" in
            "${EXIT_OK:-0}")   return 0 ;;
            "${EXIT_WARN:-2}") ((total_warns++)); return 0 ;;
            *)                 ((total_errors++)); return 0 ;;
        esac
    }

    local target_users=()
    if [[ "$os" == "linux" ]]; then
        if [[ "$all" -eq 1 ]]; then
            mapfile -t target_users < <(platform_linux_list_target_users)
        elif [[ -n "$user" ]]; then
            target_users+=("$user")
        else
            target_users+=("$USER")
        fi
    else
        target_users+=("$USER")
    fi

    for u in "${target_users[@]}"; do
        local h
        h=$([[ "$os" == "linux" ]] && getent passwd "$u" | cut -d: -f6 || echo "$HOME")

        log_section "Diagnose für: $u"

        if [[ "$action" == "health" || "$action" == "doctor" ]]; then
            local ret=0
            checks_health "$h" "$u" "$REPO_ROOT" || ret=$?
            update_counters "$ret"
        fi

        if [[ "$action" == "checksymlinks" || "$action" == "doctor" ]]; then
            local ret=0
            checks_check_symlinks "$h" "$u" "$REPO_ROOT" || ret=$?
            update_counters "$ret"
        fi
    done

    echo -e "\n${UI_ATTR_BOLD:-}ZUSAMMENFASSUNG:${UI_COL_RESET:-}"
    [[ $total_errors -gt 0 ]] && { log_error "Status: FEHLGESCHLAGEN ($total_errors Fehler)"; exit "${EXIT_FATAL:-1}"; }
    [[ $total_warns -gt 0 ]] && {
        log_warn "Status: WARNUNG ($total_warns Warnungen)"
        [[ "${STRICT_MODE_INTERNAL:-0}" -eq 1 ]] && exit "${EXIT_FATAL:-1}" || exit "${EXIT_WARN:-2}"
    }

    log_info "Status: SYSTEM OK"
}

# ──────────────────────────────────────────────────────────────
# 4. MAIN ENTRY POINT
# ──────────────────────────────────────────────────────────────

main() {
    # Default-Werte
    export DRY_RUN=0
    STRICT_MODE_INTERNAL=0
    TARGET_USER=""
    ALL_USERS=0

    [[ $# -eq 0 ]] && { usage; exit "${EXIT_OK:-0}"; }

    local CMD="$1"
    shift

    # Argument Parsing
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)   export DRY_RUN=1; shift ;;
            --strict)    STRICT_MODE_INTERNAL=1; shift ;;
            --all-users) ALL_USERS=1; shift ;;
            --user)      [[ -z "${2:-}" ]] && die "--user benötigt Namen."; TARGET_USER="$2"; shift 2 ;;
            --help)      usage; exit "${EXIT_OK:-0}" ;;
            *)           die "Unbekannte Option: $1" ;;
        esac
    done

    # Plattform-Erkennung
    local os="unknown"
    case "$(uname -s)" in
        Linux*) os="linux" ;;
        MINGW*|MSYS*|CYGWIN*) os="windows" ;;
        *) die "Betriebssystem nicht unterstützt." ;;
    esac

    # Plattform-spezifische Initialisierung
    case "$os" in
        linux)  platform_linux_init ;;
        windows) platform_windows_init ;;
    esac

    # Command Dispatching
    case "$CMD" in
        install|uninstall)
            cmd_install_uninstall "$CMD" "$os" "$ALL_USERS" "$TARGET_USER"
            ;;
        health|checksymlinks|doctor)
            cmd_health_checks "$CMD" "$os" "$ALL_USERS" "$TARGET_USER"
            ;;
        update)
            log_info "Aktualisiere Repository in $REPO_ROOT..."
            if [[ ! -w "$REPO_ROOT" ]]; then
                die "Keine Schreibrechte in $REPO_ROOT (Update fehlgeschlagen)."
            fi
            run git -C "$REPO_ROOT" pull --ff-only
            ;;
        *)
            usage; exit "${EXIT_FATAL:-1}"
            ;;
    esac
}

main "$@"
