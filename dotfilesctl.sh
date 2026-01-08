#!/usr/bin/env bash
#
# FILE: dotfilesctl.sh
# ──────────────────────────────────────────────────────────────
# ZENTRALER ORCHESTRATOR FÜR DAS DOTFILES-MANAGEMENT (v1.2.1)
# ──────────────────────────────────────────────────────────────
# Zweck:      Zentraler Einstiegspunkt zur Verwaltung von Symlinks
#             und System-Diagnosen auf Linux & Windows.
# Standards:  set -euo pipefail, Bash >= 4.0, Modulares Design.
# ──────────────────────────────────────────────────────────────

set -euo pipefail

# ──────────────────────────────────────────────────────────────
# 1. INITIALISIERUNG & PFAD-AUFLÖSUNG
# ──────────────────────────────────────────────────────────────

if (( BASH_VERSINFO[0] < 4 )); then
    echo -e "[ X ] Fehler: Bash >= 4.0 erforderlich (gefunden: ${BASH_VERSION})." >&2
    exit 1
fi

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
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
    if [[ -f "${REPO_ROOT}/lib/$lib" ]]; then
        # shellcheck disable=SC1090
        source "${REPO_ROOT}/lib/$lib"
    else
        # Fallback-Farbe, falls libcolors/constants noch nicht geladen
        echo -e "\e[31mKRITISCH: Bibliothek ${REPO_ROOT}/lib/$lib nicht gefunden!\e[0m" >&2
        exit 1
    fi
done

# ──────────────────────────────────────────────────────────────
# 3. FUNKTIONEN
# ──────────────────────────────────────────────────────────────

usage() {
    echo -e "${STYLE_BOLD_YELLOW}Dotfiles Controller${UI_COL_RESET} (v1.2.1)"
    echo -e "Repo: ${UI_COL_CYAN}${REPO_ROOT}${UI_COL_RESET}\n"
    cat <<EOF
Nutzung: $(basename "$0") BEFEHL [OPTIONEN]

Befehle:
    install         Erstellt Symlinks gemäß DOTFILES_WHITELIST.
    uninstall       Entfernt Symlinks aus den Zielverzeichnissen.
    update          Repo-Aktualisierung via 'git pull --ff-only'.
    health          System-Check (Abhängigkeiten & Schreibrechte).
    checksymlinks   Integritätsprüfung der vorhandenen Links.
    doctor          Vollständige Diagnose (Health + Symlinks).

Optionen:
    --dry-run       Simulation: Keine Schreiboperationen ausführen.
    --strict        Behandelt Warnungen als fatale Fehler (Exit 1).
    --all-users     (Linux) Wendet Aktion auf alle Home-Verzeichnisse an.
    --user <name>   (Linux) Spezifischen System-Benutzer ansteuern.
    --help          Diese Hilfe anzeigen.
EOF
}

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
            log_info "Verarbeite Benutzer: ${UI_COL_CYAN}$u${UI_COL_RESET} ($home)"

            if [[ "$action" == "install" ]]; then
                engine_install_home "$home" "$u" "$REPO_ROOT" || ((error_count++))
            else
                engine_uninstall_home "$home" "$u" "$REPO_ROOT" || ((error_count++))
            fi
        done
    else
        [[ "$all" -eq 1 || -n "$user" ]] && die "User-Wahl unter Windows nicht unterstützt."
        [[ "$action" == "install" ]] && platform_windows_require_symlink_rights

        log_info "Verarbeite Benutzer: ${UI_COL_CYAN}$USER${UI_COL_RESET} ($HOME)"
        if [[ "$action" == "install" ]]; then
            engine_install_home "$HOME" "$USER" "$REPO_ROOT" || ((error_count++))
        else
            engine_uninstall_home "$HOME" "$USER" "$REPO_ROOT" || ((error_count++))
        fi
    fi

    [[ $error_count -gt 0 ]] && exit "$EXIT_FATAL"
    return "$EXIT_OK"
}

cmd_health_checks() {
    local action="$1" os="$2" all="$3" user="$4"
    local total_warns=0 total_errors=0

    update_counters() {
        case "$1" in
            "$EXIT_OK")    return 0 ;;
            "$EXIT_WARN")  ((total_warns++)); return 0 ;;
            *)             ((total_errors++)); return 0 ;;
        esac
    }

    run_check_single() {
        local u="$1" h="$2" ret=0
        echo -e "\n${UI_COL_BLUE}>>>${UI_COL_RESET} ${STYLE_BOLD}Diagnose für: $u${UI_COL_RESET}"

        if [[ "$action" == "health" || "$action" == "doctor" ]]; then
            ret=0; checks_health "$h" "$u" "$REPO_ROOT" || ret=$?
            update_counters "$ret"
            [[ "$action" == "doctor" && "$ret" -eq "$EXIT_FATAL" ]] && return 0
        fi

        if [[ "$action" == "checksymlinks" || "$action" == "doctor" ]]; then
            ret=0; checks_check_symlinks "$h" "$u" "$REPO_ROOT" || ret=$?
            update_counters "$ret"
        fi
    }

    local target_users=()
    if [[ "$os" == "linux" ]]; then
        if [[ "$all" -eq 1 ]]; then
            mapfile -t target_users < <(platform_linux_list_target_users)
        elif [[ -n "$user" ]]; then
            platform_linux_validate_user "$user" && target_users+=("$user") || die "User '$user' ungültig."
        else
            target_users+=("$USER")
        fi
    else
        target_users+=("$USER")
    fi

    for u in "${target_users[@]}"; do
        local h
        h=$([[ "$os" == "linux" ]] && getent passwd "$u" | cut -d: -f6 || echo "$HOME")
        run_check_single "$u" "$h"
    done

    echo -e "\n${STYLE_HEADER_BG} ZUSAMMENFASSUNG ${UI_COL_RESET}"
    if [[ $total_errors -gt 0 ]]; then
        log_error "Fehlgeschlagen mit ${total_errors} Fehlern."
        exit "$EXIT_FATAL"
    fi

    if [[ $total_warns -gt 0 ]]; then
        log_warn "Beendet mit ${total_warns} Warnungen."
        [[ "${STRICT_MODE_INTERNAL:-0}" -eq 1 ]] && exit "$EXIT_FATAL" || exit "$EXIT_WARN"
    fi

    log_info "Keine Probleme gefunden."
    exit "$EXIT_OK"
}

# ──────────────────────────────────────────────────────────────
# 4. MAIN ENTRY POINT
# ──────────────────────────────────────────────────────────────

main() {
    DRY_RUN=0
    STRICT_MODE_INTERNAL=0
    TARGET_USER=""
    ALL_USERS=0
    CMD=""

    [[ $# -eq 0 ]] && { usage; exit "$EXIT_OK"; }

    CMD="$1"
    shift

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)   DRY_RUN=1; shift ;;
            --strict)    STRICT_MODE_INTERNAL=1; shift ;;
            --all-users) ALL_USERS=1; shift ;;
            --user)      [[ -z "${2:-}" ]] && die "--user erfordert Argument."; TARGET_USER="$2"; shift 2 ;;
            --help)      usage; exit "$EXIT_OK" ;;
            *)           die "Unbekannte Option: $1" ;;
        esac
    done

    readonly DRY_RUN STRICT_MODE_INTERNAL

    local os_type="$(uname -s)"
    local os="unknown"
    case "$os_type" in
        Linux*) os="linux" ;;
        MINGW*|MSYS*|CYGWIN*) os="windows" ;;
        *) die "Betriebssystem nicht unterstützt: ${os_type}" ;;
    esac

    # Initialisierung der Plattform-spezifischen Bibliotheken
    case "$os" in
        linux)   platform_linux_init ;;
        windows) platform_windows_init ;;
    esac

    case "$CMD" in
        install|uninstall)
            cmd_install_uninstall "$CMD" "$os" "$ALL_USERS" "$TARGET_USER"
            ;;
        health|checksymlinks|doctor)
            cmd_health_checks "$CMD" "$os" "$ALL_USERS" "$TARGET_USER"
            ;;
        update)
            log_info "Aktualisiere Repository..."
            [[ "$os" == "linux" ]] && platform_linux_require_root
            run git -C "$REPO_ROOT" pull --ff-only || exit "$EXIT_FATAL"
            exit "$EXIT_OK"
            ;;
        *)
            usage; exit "$EXIT_FATAL"
            ;;
    esac
}

main "$@"
