# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: libengine.sh                                                        │
# │ ZWECK: Kern-Logik für Installation und Benutzerverwaltung                 │
# └───────────────────────────────────────────────────────────────────────────┘

[[ -n "${DOTFILES_CORE_LOADED:-}" ]] || return

# Installiert oder deinstalliert Dotfiles für einen spezifischen User
engine_setup_user() {
    local user="$1"
    local action="$2" # "install" oder "uninstall"

    # Nutzer-Validierung und Home-Ermittlung (via libplatform/common)
    local user_home
    user_home=$(get_user_home "$user")

    if [[ -z "$user_home" || ! -d "$user_home" ]]; then
        echo -e "${UI_COL_RED:-}[ X ] Fehler:${UI_COL_RESET:-} Home-Verzeichnis für '$user' nicht gefunden."
        return 1
    fi

    echo -e "${UI_COL_BLUE:-}ℹ Verarbeite Benutzer: $user ($user_home)${UI_COL_RESET:-}"

    # Iteriere über die Whitelist (aus libconstants.sh)
    for file in "${DOTFILES_WHITELIST[@]}"; do
        case "$action" in
            install)
                # Funktion aus libcommon.sh
                create_symlink "$file" "$user_home"
                ;;
            uninstall)
                remove_symlink "$file" "$user_home"
                ;;
        esac
    done
}

# Verarbeitet alle menschlichen Benutzer (ID >= 1000 + root)
engine_process_all_users() {
    local action="$1"

    # Root immer mitnehmen
    engine_setup_user "root" "$action"

    # Andere User via /etc/passwd ermitteln (Linux Standard)
    local extra_users
    extra_users=$(awk -F: '$3 >= 1000 && $3 < 60000 { print $1 }' /etc/passwd)

    for u in $extra_users; do
        engine_setup_user "$u" "$action"
    done
}
