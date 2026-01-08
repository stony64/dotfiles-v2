#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: lib/libchecks.sh                                                    │
# │ ZWECK: System-Diagnosen, Integritätsprüfungen und Plattform-Validierung   │
# │ STANDARDS: set -euo pipefail, Bash >= 4.0, Google Shell Style Guide       │
# └───────────────────────────────────────────────────────────────────────────┘

# Master-Guard: Verhindert direktes Ausführen ohne Controller
[[ -n "${DOTFILES_CORE_LOADED:-}" ]] || return

# ──────────────────────────────────────────────────────────────
# 1. HILFSFUNKTIONEN (PFAD-AUFLÖSUNG)
# ──────────────────────────────────────────────────────────────

# @description Ermittelt den absoluten Zielpfad einer Datei oder eines Symlinks.
# Implementiert eine plattformübergreifende Pfadauflösung (Linux/Windows).
# @param $1 Pfad, der aufgelöst werden soll.
# @return Absoluter, kanonischer Pfad.
canon_path() {
    local p="$1"

    # Plattformspezifische Auflösung für Windows (Git Bash / MSYS)
    if [[ "${OSTYPE}" == "msys" || "${OSTYPE}" == "cygwin" ]]; then
        if command -v cygpath >/dev/null 2>&1; then
            cygpath -aw "$p" 2>/dev/null && return
        fi
    fi

    # Standard Linux/Unix Auflösung
    if command -v readlink >/dev/null 2>&1; then
        readlink -f "$p" 2>/dev/null
    elif command -v realpath >/dev/null 2>&1; then
        realpath "$p" 2>/dev/null
    else
        # Fallback: Falls keine Tools vorhanden, zumindest absoluten Pfad via cd
        (cd "$(dirname "$p")" &>/dev/null && echo "$(pwd)/$(basename "$p")")
    fi
}

# ──────────────────────────────────────────────────────────────
# 2. CORE CHECKS
# ──────────────────────────────────────────────────────────────

# @description Prüft die Plattform-Sicherheit und notwendige Abhängigkeiten.
# Validiert MSYS-Umgebung unter Windows und Root/User-Kontext unter Linux.
# @param $1 Home-Verzeichnis
# @param $2 User-Name
# @param $3 Repo-Root
# @return EXIT_OK oder EXIT_FATAL.
checks_health() {
    local home_dir="$1" user_name="$2" repo_root="$3"
    local fatal_errors=0

    echo -e "${UI_ATTR_BOLD:-}System-Health Check für:${UI_COL_RESET:-} $user_name ($home_dir)"

    # 1. Plattform-Sicherheit: Windows/MSYS Validierung
    if [[ "${OSTYPE}" == "msys" ]]; then
        if [[ "${MSYS:-}" != *"winsymlinks:nativestrict"* ]]; then
            log_error "Sicherheitsverstoß: MSYS=winsymlinks:nativestrict ist nicht gesetzt!"
            log_error "Native Windows-Symlinks sind für die Idempotenz zwingend erforderlich."
            ((fatal_errors++))
        fi
    fi

    # 2. Plattform-Sicherheit: Linux/Root & User Validierung
    if [[ "${OSTYPE}" == "linux-gnu"* ]]; then
        if ! getent passwd "$user_name" >/dev/null 2>&1; then
            log_error "Sicherheitsrisiko: User '$user_name' existiert nicht im System (getent failed)."
            ((fatal_errors++))
        fi
    fi

    # 3. Binär-Abhängigkeiten prüfen
    local cmd
    for cmd in git ln rm mkdir cp; do
        if command -v "$cmd" >/dev/null 2>&1; then
            # Optional: Verbose Output unterdrücken, nur bei Fehler meckern
            true
        else
            log_error "Kritische Abhängigkeit fehlt: '$cmd'."
            ((fatal_errors++))
        fi
    done

    # 4. Pfad-Integrität
    if [[ ! -d "$repo_root" ]]; then
        log_error "Repo-Root nicht gefunden: $repo_root"
        ((fatal_errors++))
    fi
    if [[ ! -d "$home_dir" ]]; then
        log_error "Home-Verzeichnis nicht gefunden: $home_dir"
        ((fatal_errors++))
    fi

    if [[ $fatal_errors -gt 0 ]]; then
        return "${EXIT_FATAL:-1}"
    fi

    echo -e "    ${UI_COL_GREEN:-}${SYMBOL_OK:-}${UI_COL_RESET:-} Basissystem ist gesund."
    return "${EXIT_OK:-0}"
}

# @description Prüft den Status der Symlinks (Idempotenz-Check).
# Vergleicht nicht nur die Existenz, sondern das tatsächliche Ziel der Links.
# @param $1 Home-Verzeichnis
# @param $2 User-Name
# @param $3 Repo-Root
# @return EXIT_OK oder EXIT_WARN.
checks_check_symlinks() {
    local home_dir="$1" user_name="$2" repo_root="$3"
    local warnings=0

    echo -e "${UI_ATTR_BOLD:-}Symlink-Validierung:${UI_COL_RESET:-}"

    local file src dest
    # Nutzt die Whitelist aus libconstants.sh
    for file in "${DOTFILES_WHITELIST[@]}"; do
        src="${repo_root}/home/${file}"
        dest="${home_dir}/${file}"

        # Prüfung 1: Quelle vorhanden?
        if [[ ! -e "$src" ]]; then
            echo -e "    ${UI_COL_YELLOW:-}${SYMBOL_WARN:-}${UI_COL_RESET:-} SKIP: Quelle im Repo fehlt ($file)"
            ((warnings++))
            continue
        fi

        # Prüfung 2: Ziel-Status (Idempotenz-Check via Pfad-Vergleich)
        if [[ -L "$dest" ]]; then
            local canon_dest_target canon_src
            canon_dest_target="$(canon_path "$dest")"
            canon_src="$(canon_path "$src")"

            if [[ "$canon_dest_target" == "$canon_src" ]]; then
                echo -e "    ${UI_COL_GREEN:-}${SYMBOL_OK:-}${UI_COL_RESET:-} $file: OK"
            else
                echo -e "    ${UI_COL_RED:-}${SYMBOL_ERROR:-}${UI_COL_RESET:-} $file: Falsches Ziel -> $canon_dest_target"
                ((warnings++))
            fi
        elif [[ -e "$dest" ]]; then
            echo -e "    ${UI_COL_YELLOW:-}${SYMBOL_WARN:-}${UI_COL_RESET:-} $file: Blockiert durch echte Datei (kein Link)."
            ((warnings++))
        else
            echo -e "    ${UI_COL_RED:-}${SYMBOL_ERROR:-}${UI_COL_RESET:-} $file: Fehlt komplett."
            ((warnings++))
        fi
    done

    [[ $warnings -gt 0 ]] && return "${EXIT_WARN:-2}"
    return "${EXIT_OK:-0}"
}

# ──────────────────────────────────────────────────────────────
# 3. CLI HANDLER (DIE BRÜCKE ZUM CONTROLLER)
# ──────────────────────────────────────────────────────────────

# @description Verarbeitet Diagnose-Befehle vom Controller.
# @param $@ Argumente (z.B. --user root).
cmd_diagnosis_handler() {
    local target_user=""
    local all_users=false

    # Argument Parsing
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --user) target_user="$2"; shift 2 ;;
            --all-users) all_users=true; shift ;;
            *) shift ;;
        esac
    done

    # Default: Aktueller User
    if [[ -z "$target_user" && "$all_users" == false ]]; then
        target_user="$(whoami)"
    fi

    # Hilfsfunktion für einen einzelnen Check
    perform_check() {
        local u="$1"
        local h
        # get_user_home kommt aus libcommon.sh
        h=$(get_user_home "$u")

        log_section "Diagnose für User: $u"

        # 1. Health Check
        checks_health "$h" "$u" "$REPO_ROOT" || return 1

        # 2. Symlink Check
        checks_check_symlinks "$h" "$u" "$REPO_ROOT"
    }

    # Ausführung
    if [[ "$all_users" == true ]]; then
        # Nur Linux: Iteriere über alle relevanten User
        if [[ -f /etc/passwd ]]; then
            local extra_users
            extra_users=$(awk -F: '$3 >= 1000 && $3 < 60000 { print $1 }' /etc/passwd)
            perform_check "root"
            for u in $extra_users; do
                perform_check "$u"
            done
        else
            log_error "--all-users wird auf dieser Plattform nicht unterstützt."
            return 1
        fi
    else
        perform_check "$target_user"
    fi
}

true
