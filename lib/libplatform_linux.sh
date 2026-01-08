#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: lib/libplatform_linux.sh                                            │
# │ ZWECK: Linux-spezifische Benutzerverwaltung und System-Validierung        │
# │ STANDARDS: set -euo pipefail, Bash >= 4.0, Google Shell Style Guide       │
# └───────────────────────────────────────────────────────────────────────────┘

# @description Initialisiert Linux-spezifische Anforderungen.
# Prüft auf Verfügbarkeit essentieller System-Tools.
# @return EXIT_OK oder bricht via die() ab.
platform_linux_init() {
    require_cmd getent
    require_cmd id
    return "${EXIT_OK:-0}"
}

# @description Erzwingt Root-Rechte für administrative Aufgaben.
# Verwendet die effektive User-ID (EUID) für maximale Sicherheit.
# @return EXIT_OK oder bricht via die() ab.
platform_linux_require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        die "Sicherheitsstopp: Diese Aktion erfordert administrative Privilegien (sudo)."
    fi
    return "${EXIT_OK:-0}"
}

# @description Identifiziert relevante Benutzer für die Dotfiles-Verteilung.
# Filtert nach Standard-Linux-Konventionen (Root + Human Users).
# @return Liste der Benutzernamen auf stdout.
platform_linux_list_target_users() {
    # Filter-Logik:
    # UID 0 (root)
    # UIDs >= 1000 (normale Benutzer)
    # Ausschluss von 65534 (nobody/nfsnobaody)
    getent passwd | awk -F: '($3 == 0 || ($3 >= 1000 && $3 != 65534)) {print $1}'
    return "${EXIT_OK:-0}"
}

# @description Validiert die Existenz eines spezifischen Benutzers.
# @param $1 Benutzername.
# @return EXIT_OK oder EXIT_FATAL.
platform_linux_validate_user() {
    local user="${1:-}"

    [[ -z "$user" ]] && return "${EXIT_FATAL:-1}"

    if getent passwd "$user" >/dev/null 2>&1; then
        return "${EXIT_OK:-0}"
    else
        log_error "Benutzer-Validierung fehlgeschlagen: '$user' nicht gefunden."
        return "${EXIT_FATAL:-1}"
    fi
}

true
