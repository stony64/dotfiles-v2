#!/usr/bin/env bash
#
# FILE: lib/libplatform_linux.sh
# ──────────────────────────────────────────────────────────────
# LINUX-SPEZIFISCHE IMPLEMENTIERUNGEN
# ──────────────────────────────────────────────────────────────
# Zweck:    Benutzerverwaltung, Root-Validierung und System-Checks
#           speziell für Linux-Umgebungen (Debian/Ubuntu/etc.).
# Abhängigkeiten: libcommon.sh, libconstants.sh
# ──────────────────────────────────────────────────────────────

# @description Initialisiert Linux-spezifische Anforderungen.
# @stdout Keine (Fehler führen zum Abbruch).
# @return EXIT_OK oder bricht via require_cmd ab.
platform_linux_init() {
    # Validierung der für die Benutzerauflösung kritischen Tools
    require_cmd getent
    require_cmd id
    return "$EXIT_OK"
}

# @description Erzwingt Root-Rechte für administrative Aufgaben.
# @stdout Keine.
# @return EXIT_OK oder bricht via die() ab (EXIT_FATAL).
platform_linux_require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        die "Dieses Kommando erfordert Root-Rechte (sudo)."
    fi
    return "$EXIT_OK"
}

# @description Identifiziert relevante Benutzer für die Installation.
# Filterkriterien:
# 1. UID 0 (Root) für administrative Umgebungen.
# 2. UIDs >= 1000 (Reguläre Benutzer laut Linux-Standard).
# 3. Ausschluss von 'nobody' (UID 65534).
# @stdout Liste der Benutzernamen (einer pro Zeile).
# @return EXIT_OK
platform_linux_list_target_users() {
    # Nutzt getent für Kompatibilität mit LDAP/AD-Benutzern
    # Filtert UIDs basierend auf Standard-Systemgrenzen
    getent passwd | awk -F: '($3 == 0 || ($3 >= 1000 && $3 != 65534)) {print $1}'
    return "$EXIT_OK"
}

# @description Prüft, ob ein spezifischer Benutzer im System existiert.
# @param $1 Der zu prüfende Benutzername.
# @stdout Keine.
# @return EXIT_OK (0) bei Erfolg, EXIT_FATAL (1) wenn nicht gefunden.
platform_linux_validate_user() {
    local user="$1"

    # getent prüft lokal (/etc/passwd) und über konfigurierte Name-Services
    if getent passwd "$user" >/dev/null 2>&1; then
        return "$EXIT_OK"
    else
        return "$EXIT_FATAL"
    fi
}

true
