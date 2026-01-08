#!/usr/bin/env bash
#
# FILE: lib/libchecks.sh
# ──────────────────────────────────────────────────────────────
# SYSTEM-DIAGNOSEN UND INTEGRITÄTSPRÜFUNGEN
# ──────────────────────────────────────────────────────────────
# Zweck:    Validierung der Systemumgebung, Pfadauflösung und
#           Überprüfung der Symlink-Integrität.
# Abhängigkeiten: libcolors.sh, libconstants.sh, libcommon.sh
# ──────────────────────────────────────────────────────────────

# @description Ermittelt den absoluten Zielpfad einer Datei oder eines Symlinks.
# @param $1 Pfad, der aufgelöst werden soll.
# @stdout Der kanonische (absolute) Pfad.
# @return EXIT_OK (0)
canon_path() {
    local p="$1"

    # 1. Falls Pfad ein Link ist, Ziel auslesen (rekursiv auflösen)
    if [[ -L "$p" ]]; then
        p=$(readlink -f "$p" 2>/dev/null || realpath "$p" 2>/dev/null || echo "$p")
    fi

    # 2. Absoluten Pfad sicherstellen (Portabilität für Linux/BSD/Windows)
    if has_cmd readlink && readlink -f / >/dev/null 2>&1; then
        readlink -f "$p" 2>/dev/null
    elif has_cmd realpath; then
        realpath "$p" 2>/dev/null
    else
        printf '%s\n' "$p"
    fi
    return "$EXIT_OK"
}

# @description Prüft das System auf notwendige Abhängigkeiten und Verzeichnisse.
# @param $1 Home-Verzeichnis des Ziel-Users.
# @param $2 Benutzername.
# @param $3 Root-Pfad des Repositories.
# @stdout Statusmeldungen zum Prüfprozess (Erfolg/Fehler).
# @return EXIT_OK oder EXIT_FATAL.
checks_health() {
    local home_dir="$1" user_name="$2" repo_root="$3"
    local fatal_errors=0

    log_info "Health Check für $user_name ($home_dir):"

    # Benötigte CLI-Tools verifizieren
    local cmd
    for cmd in git ln rm mkdir cp; do
        if has_cmd "$cmd"; then
            echo -e "    ${COL_GREEN}${SYMBOL_OK}${COL_RESET} Befehl '$cmd' gefunden."
        else
            log_error "Befehl '$cmd' fehlt auf dem System."
            ((fatal_errors++))
        fi
    done

    # Existenz der kritischen Pfade prüfen
    if [[ ! -d "$repo_root" ]]; then
        log_error "Repo-Verzeichnis nicht gefunden: $repo_root"
        ((fatal_errors++))
    fi

    if [[ ! -d "$home_dir" ]]; then
        log_error "Home-Verzeichnis nicht gefunden: $home_dir"
        ((fatal_errors++))
    fi

    [[ $fatal_errors -gt 0 ]] && return "$EXIT_FATAL"
    return "$EXIT_OK"
}

# @description Validiert den Status aller Symlinks gemäß der DOTFILES_WHITELIST.
# @param $1 Home-Verzeichnis des Ziel-Users.
# @param $2 Benutzername.
# @param $3 Root-Pfad des Repositories.
# @stdout Detaillierte Liste des Link-Status pro Datei.
# @return EXIT_OK oder EXIT_WARN.
checks_check_symlinks() {
    local home_dir="$1" user_name="$2" repo_root="$3"
    local warnings=0

    log_info "Symlink Check für $user_name:"

    local file src dest
    for file in "${DOTFILES_WHITELIST[@]}"; do
        src="${repo_root}/home/${file}"
        dest="${home_dir}/${file}"

        # 1. Existenz im Repo prüfen
        if [[ ! -e "$src" ]]; then
            echo -e "    ${COL_YELLOW}${SYMBOL_WARN}${COL_RESET} Quelle fehlt im Repo: ${file}"
            ((warnings++))
            continue
        fi

        # 2. Verknüpfungs-Status im Home prüfen
        if [[ -L "$dest" ]]; then
            # Pfadvergleich der kanonischen Ziele
            local canon_dest_target
            local canon_src
            canon_dest_target="$(canon_path "$dest")"
            canon_src="$(canon_path "$src")"

            if [[ "$canon_dest_target" == "$canon_src" ]]; then
                echo -e "    ${COL_GREEN}${SYMBOL_OK}${COL_RESET} ${file}: Korrekt verlinkt."
            else
                echo -e "    ${COL_YELLOW}${SYMBOL_WARN}${COL_RESET} ${file}: Zeigt auf falsches Ziel."
                ((warnings++))
            fi
        elif [[ -e "$dest" ]]; then
            echo -e "    ${COL_YELLOW}${SYMBOL_WARN}${COL_RESET} ${file}: Reale Datei blockiert Link."
            ((warnings++))
        else
            echo -e "    ${COL_RED}${SYMBOL_ERROR}${COL_RESET} ${file}: Link fehlt."
            ((warnings++))
        fi
    done

    [[ $warnings -gt 0 ]] && return "$EXIT_WARN"
    return "$EXIT_OK"
}

true
