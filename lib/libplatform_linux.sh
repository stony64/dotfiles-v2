#!/usr/bin/env bash
#
# FILE: lib/libplatform_linux.sh
# ──────────────────────────────────────────────────────────────
# LINUX-SPEZIFISCHE IMPLEMENTIERUNGEN (v1.2.1)
# ──────────────────────────────────────────────────────────────
# Zweck:     Benutzerverwaltung und Root-Validierung für Linux.
# ──────────────────────────────────────────────────────────────

# 1. INCLUDE GUARD
[[ -n "${_LIB_PLATFORM_LINUX_LOADED:-}" ]] && return
readonly _LIB_PLATFORM_LINUX_LOADED=1

# @description Initialisiert Linux-spezifische Anforderungen.
platform_linux_init() {
    # Validierung der für die Benutzerauflösung kritischen Tools
    require_cmd getent
    require_cmd id
    return "$EXIT_OK"
}

# @description Erzwingt Root-Rechte für administrative Aufgaben.
platform_linux_require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        # Nutzt die() aus libcommon.sh, die nun UI_COL_RED nutzt
        die "Dieses Kommando erfordert Root-Rechte (sudo)."
    fi
    return "$EXIT_OK"
}

# @description Identifiziert relevante Benutzer für die Installation.
# Filterkriterien: UID 0, UIDs >= 1000, Ausschluss UID 65534.
platform_linux_list_target_users() {
    # Nutzt getent für Kompatibilität mit LDAP/AD-Benutzern
    getent passwd | awk -F: '($3 == 0 || ($3 >= 1000 && $3 != 65534)) {print $1}'
    return "$EXIT_OK"
}

# @description Prüft, ob ein spezifischer Benutzer im System existiert.
platform_linux_validate_user() {
    local user="$1"

    if getent passwd "$user" >/dev/null 2>&1; then
        return "$EXIT_OK"
    else
        return "$EXIT_FATAL"
    fi
}

true
