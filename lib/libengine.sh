#!/usr/bin/env bash
#
# FILE: lib/libengine.sh
# ──────────────────────────────────────────────────────────────
# KERN-LOGIK FÜR INSTALLATION UND DEINSTALLATION (v1.2.1)
# ──────────────────────────────────────────────────────────────
# Zweck:     Verwaltung von Symlinks (Home) und Kopien (Config).
#            Implementiert Idempotenz und Sicherheits-Backups.
# ──────────────────────────────────────────────────────────────

# 1. INCLUDE GUARD
[[ -n "${_LIB_ENGINE_LOADED:-}" ]] && return
readonly _LIB_ENGINE_LOADED=1

# @description Installiert Dotfiles als Symlinks im Home-Verzeichnis des Users.
engine_install_home() {
    local home_dir="$1" user_name="$2" repo_root="$3"
    local errors=0

    log_info "Starte Home-Installation für ${UI_COL_CYAN}${user_name}${UI_COL_RESET} in ${home_dir}"

    local file src dest
    for file in "${DOTFILES_WHITELIST[@]}"; do
        src="${repo_root}/${REPO_HOME_DIR}/${file}"
        dest="${home_dir}/${file}"

        # 1. Quell-Validierung
        if [[ ! -e "$src" ]]; then
            log_warn "SKIP ${file}: Quelle fehlt im Repo"
            continue
        fi

        # 2. Idempotenz-Prüfung: Ist der Link bereits korrekt?
        if [[ -L "$dest" ]]; then
            if [[ "$(canon_path "$dest")" == "$(canon_path "$src")" ]]; then
                log_info "OK ${file}: Symlink bereits korrekt"
                continue
            else
                log_warn "SKIP ${file}: Symlink zeigt auf fremdes Ziel"
                continue
            fi
        fi

        # 3. Sicherheits-Check: Keine echten Dateien/Verzeichnisse überschreiben
        if [[ -e "$dest" ]]; then
            log_warn "SKIP ${file}: Ziel existiert bereits als echte Datei/Dir"
            continue
        fi

        # 4. Verknüpfung erstellen
        run ln -sf "$src" "$dest" || ((errors++))
    done

    # Anschluss: Installation der Runtime-Configs (z.B. mc, micro)
    engine_install_runtime_configs "$home_dir" "$repo_root" || ((errors++))

    [[ $errors -gt 0 ]] && return "$EXIT_FATAL"
    return "$EXIT_OK"
}

# @description Entfernt Symlinks, die auf das Repository zeigen.
engine_uninstall_home() {
    local home_dir="$1" user_name="$2" repo_root="$3"
    local errors=0

    log_info "Starte Deinstallation für ${UI_COL_CYAN}${user_name}${UI_COL_RESET}"

    local file src dest
    for file in "${DOTFILES_WHITELIST[@]}"; do
        src="${repo_root}/${REPO_HOME_DIR}/${file}"
        dest="${home_dir}/${file}"

        # Nur Symlinks entfernen, die nachweislich auf dieses Repo zeigen
        if [[ -L "$dest" ]]; then
            if [[ "$(canon_path "$dest")" == "$(canon_path "$src")" ]]; then
                run rm -- "$dest" || ((errors++))
            else
                log_warn "SKIP ${file}: Symlink zeigt auf fremdes Ziel"
            fi
        elif [[ -e "$dest" ]]; then
            log_warn "SKIP ${file}: Echte Datei/Dir wird nicht automatisch entfernt"
        fi
    done

    # Runtime-Konfigurationen im .config Verzeichnis entfernen
    local tool target
    for tool in "${RUNTIME_CONFIGS[@]}"; do
        target="${home_dir}/.config/${tool}"
        if [[ -e "$target" || -L "$target" ]]; then
            run rm -rf -- "$target" || ((errors++))
        fi
    done

    [[ $errors -gt 0 ]] && return "$EXIT_FATAL"
    return "$EXIT_OK"
}

# @description Kopiert Verzeichnisse aus config/ nach ~/.config/ inklusive Backup-Logik.
engine_install_runtime_configs() {
    local home_dir="$1" repo_root="$2"
    local config_dest="${home_dir}/.config"
    local error_count=0

    # Sicherstellen, dass der .config Zielordner existiert
    if [[ ! -d "$config_dest" ]]; then
        run mkdir -p "$config_dest" || return "$EXIT_FATAL"
    fi

    local tool
    for tool in "${RUNTIME_CONFIGS[@]}"; do
        local src="${repo_root}/${REPO_CONFIG_DIR}/${tool}"
        local dest="${config_dest}/${tool}"

        if [[ -d "$src" ]]; then
            # Backup-Logik: Falls Zielordner existiert, verschieben statt löschen
            if [[ -e "$dest" && ! -L "$dest" ]]; then
                log_warn "Backup: Verschiebe existierenden Ordner ${tool} nach .bak"
                [[ -e "${dest}.bak" ]] && run rm -rf "${dest}.bak"
                run mv "$dest" "${dest}.bak" || ((error_count++))
            elif [[ -L "$dest" ]]; then
                # Existierende Links im .config-Ordner werden entfernt
                run rm "$dest" || ((error_count++))
            fi

            # Kopier-Vorgang
            run cp -r "$src" "$config_dest/" || ((error_count++))
        else
            log_warn "SKIP '${tool}': Quelle fehlt in ${REPO_CONFIG_DIR}/"
        fi
    done

    [[ $error_count -gt 0 ]] && return "$EXIT_FATAL"
    return "$EXIT_OK"
}

true
