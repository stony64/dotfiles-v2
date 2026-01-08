#!/usr/bin/env bash
#
# FILE: lib/libchecks.sh
# ──────────────────────────────────────────────────────────────
# SYSTEM-DIAGNOSEN UND INTEGRITÄTSPRÜFUNGEN (v1.2.1)
# ──────────────────────────────────────────────────────────────
# Zweck:     Validierung der Systemumgebung und Symlink-Check.
# Korrektur: Namespace-Sync (UI_COL_) & Include-Guards.
# ──────────────────────────────────────────────────────────────

# 1. INCLUDE GUARD
[[ -n "${_LIB_CHECKS_LOADED:-}" ]] && return
readonly _LIB_CHECKS_LOADED=1

# @description Ermittelt den absoluten Zielpfad einer Datei oder eines Symlinks.
# @param $1 Pfad, der aufgelöst werden soll.
canon_path() {
    local p="$1"

    # 1. Falls Pfad ein Link ist, Ziel auslesen (rekursiv auflösen)
    if [[ -L "$p" ]]; then
        p=$(readlink -f "$p" 2>/dev/null || realpath "$p" 2>/dev/null || echo "$p")
    fi

    # 2. Absoluten Pfad sicherstellen
    if command -v readlink >/dev/null 2>&1 && readlink -f / >/dev/null 2>&1; then
        readlink -f "$p" 2>/dev/null
    elif command -v realpath >/dev/null 2>&1; then
        realpath "$p" 2>/dev/null
    else
        printf '%s\n' "$p"
    fi
}

# @description Prüft das System auf notwendige Abhängigkeiten.
checks_health() {
    local home_dir="$1" user_name="$2" repo_root="$3"
    local fatal_errors=0

    log_info "Health Check für $user_name ($home_dir):"

    # Benötigte CLI-Tools verifizieren
    local cmd
    for cmd in git ln rm mkdir cp; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo -e "    ${UI_COL_GREEN}${SYMBOL_OK}${UI_COL_RESET} Befehl '$cmd' gefunden."
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
            echo -e "    ${UI_COL_YELLOW}${SYMBOL_WARN}${UI_COL_RESET} Quelle fehlt im Repo: ${file}"
            ((warnings++))
            continue
        fi

        # 2. Verknüpfungs-Status im Home prüfen
        if [[ -L "$dest" ]]; then
            local canon_dest_target
            local canon_src
            canon_dest_target="$(canon_path "$dest")"
            canon_src="$(canon_path "$src")"

            if [[ "$canon_dest_target" == "$canon_src" ]]; then
                echo -e "    ${UI_COL_GREEN}${SYMBOL_OK}${UI_COL_RESET} ${file}: Korrekt verlinkt."
            else
                echo -e "    ${UI_COL_YELLOW}${SYMBOL_WARN}${UI_COL_RESET} ${file}: Zeigt auf falsches Ziel."
                ((warnings++))
            fi
        elif [[ -e "$dest" ]]; then
            echo -e "    ${UI_COL_YELLOW}${SYMBOL_WARN}${UI_COL_RESET} ${file}: Reale Datei blockiert Link."
            ((warnings++))
        else
            echo -e "    ${UI_COL_RED}${SYMBOL_ERROR}${UI_COL_RESET} ${file}: Link fehlt."
            ((warnings++))
        fi
    done

    [[ $warnings -gt 0 ]] && return "$EXIT_WARN"
    return "$EXIT_OK"
}

true
