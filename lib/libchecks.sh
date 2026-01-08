#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: lib/libchecks.sh                                                    │
# │ ZWECK: System-Diagnosen, Integritätsprüfungen und Plattform-Validierung   │
# │ STANDARDS: set -euo pipefail, Bash >= 4.0, Google Shell Style Guide       │
# └───────────────────────────────────────────────────────────────────────────┘

# INCLUDE GUARD
[[ -n "${_LIB_CHECKS_LOADED:-}" ]] && return
readonly _LIB_CHECKS_LOADED=1

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

# @description Prüft die Plattform-Sicherheit und notwendige Abhängigkeiten.
# Validiert MSYS-Umgebung unter Windows und Root/User-Kontext unter Linux.
# @param $1 Home-Verzeichnis, $2 User-Name, $3 Repo-Root.
# @return EXIT_OK oder EXIT_FATAL.
checks_health() {
    local home_dir="$1" user_name="$2" repo_root="$3"
    local fatal_errors=0

    log_info "Health Check für $user_name ($home_dir):"

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
            echo -e "    ${UI_COL_GREEN}${SYMBOL_OK}${UI_COL_RESET} Befehl '$cmd' gefunden."
        else
            log_error "Kritische Abhängigkeit fehlt: '$cmd'."
            ((fatal_errors++))
        fi
    done

    # 4. Pfad-Integrität
    [[ ! -d "$repo_root" ]] && { log_error "Repo fehlt: $repo_root"; ((fatal_errors++)); }
    [[ ! -d "$home_dir" ]] && { log_error "Home fehlt: $home_dir"; ((fatal_errors++)); }

    [[ $fatal_errors -gt 0 ]] && return "$EXIT_FATAL"
    return "$EXIT_OK"
}

# @description Prüft den Status der Symlinks (Idempotenz-Check).
# Vergleicht nicht nur die Existenz, sondern das tatsächliche Ziel der Links.
# @param $1 Home-Verzeichnis, $2 User-Name, $3 Repo-Root.
# @return EXIT_OK oder EXIT_WARN.
checks_check_symlinks() {
    local home_dir="$1" user_name="$2" repo_root="$3"
    local warnings=0

    log_info "Integritätsprüfung der Symlinks für $user_name:"

    local file src dest
    for file in "${DOTFILES_WHITELIST[@]}"; do
        src="${repo_root}/home/${file}"
        dest="${home_dir}/${file}"

        # Prüfung 1: Quelle vorhanden?
        if [[ ! -e "$src" ]]; then
            echo -e "    ${UI_COL_YELLOW}${SYMBOL_WARN}${UI_COL_RESET} Quelle im Repo fehlt: ${file}"
            ((warnings++))
            continue
        fi

        # Prüfung 2: Ziel-Status (Idempotenz-Check via Pfad-Vergleich)
        if [[ -L "$dest" ]]; then
            local canon_dest_target canon_src
            canon_dest_target="$(canon_path "$dest")"
            canon_src="$(canon_path "$src")"

            if [[ "$canon_dest_target" == "$canon_src" ]]; then
                echo -e "    ${UI_COL_GREEN}${SYMBOL_OK}${UI_COL_RESET} ${file}: Korrekt verlinkt."
            else
                echo -e "    ${UI_COL_YELLOW}${SYMBOL_WARN}${UI_COL_RESET} ${file}: Falsches Ziel -> $canon_dest_target"
                ((warnings++))
            fi
        elif [[ -e "$dest" ]]; then
            echo -e "    ${UI_COL_YELLOW}${SYMBOL_WARN}${UI_COL_RESET} ${file}: Blockiert durch reale Datei/Ordner."
            ((warnings++))
        else
            echo -e "    ${UI_COL_RED}${SYMBOL_ERROR}${UI_COL_RESET} ${file}: Link nicht vorhanden."
            ((warnings++))
        fi
    done

    [[ $warnings -gt 0 ]] && return "$EXIT_WARN"
    return "$EXIT_OK"
}

true
