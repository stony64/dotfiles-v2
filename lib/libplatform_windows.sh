#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: lib/libplatform_windows.sh                                          │
# │ ZWECK: Windows-spezifische Symlink-Validierung und MSYS-Konfiguration     │
# │ STANDARDS: set -euo pipefail, Bash >= 4.0, Google Shell Style Guide       │
# └───────────────────────────────────────────────────────────────────────────┘

# INCLUDE GUARD
[[ -n "${_LIB_PLATFORM_WINDOWS_LOADED:-}" ]] && return
readonly _LIB_PLATFORM_WINDOWS_LOADED=1

# @description Initialisiert die Windows-Umgebung für native Symlinks.
# Erzwingt MSYS-Verhalten, das echte NTFS-Symlinks statt Kopien erstellt.
# @return EXIT_OK oder bricht via die() ab.
platform_windows_init() {
    # WICHTIG: Erfordert Git Bash / MSYS2.
    # 'nativestrict' bricht ab, wenn der Symlink nicht erstellt werden kann.
    export MSYS="winsymlinks:nativestrict"

    if [[ "${MSYS:-}" != *"winsymlinks:nativestrict"* ]]; then
        die "Kritischer Fehler: MSYS=winsymlinks:nativestrict konnte nicht exportiert werden."
    fi
    return "${EXIT_OK:-0}"
}

# @description Verifiziert proaktiv die Berechtigung zum Erstellen von Symlinks.
# Führt einen realen Schreibtest durch, um den Entwicklermodus zu prüfen.
# @return EXIT_OK oder bricht mit ausführlicher Diagnose ab.
platform_windows_require_symlink_rights() {
    log_info "Prüfe Windows Symlink-Berechtigungen (Entwicklermodus)..."

    local tmp_dir test_target test_link
    tmp_dir="$(mktemp -d 2>/dev/null || echo "")"

    [[ -z "$tmp_dir" || ! -d "$tmp_dir" ]] && die "Konnte temporäres Verzeichnis für Sicherheitscheck nicht erstellen."

    test_target="${tmp_dir}/target_file"
    test_link="${tmp_dir}/test_link"

    # 'nativestrict' benötigt eine existierende Quelle für den Test
    printf 'test' > "$test_target" || die "Schreibzugriff im Temp-Verzeichnis verweigert."

    # 1. Test: Proaktive Symlink-Erstellung
    if ln -s "$test_target" "$test_link" 2>/dev/null; then
        # Erfolg: Aufräumen
        rm -rf "$tmp_dir"
        echo -e "    ${UI_COL_GREEN:-}${SYMBOL_OK:-} Symlink-Rechte verifiziert (Native NTFS-Links aktiv).${UI_COL_RESET:-}"
        return "${EXIT_OK:-0}"
    fi

    # 2. Fehlerfall: Diagnose-Ausgabe
    rm -rf "$tmp_dir"

    log_error "Native Symlinks werden vom System blockiert."
    echo -e "${UI_COL_YELLOW:-}HINTERGRUND:${UI_COL_RESET:-}"
    echo "Windows erfordert für Symlinks Administratorrechte ODER den 'Entwicklermodus'."
    echo ""
    echo "LÖSUNG:"
    echo "1. Öffnen Sie die Windows-Einstellungen (Win+I)."
    echo "2. Datenschutz & Sicherheit -> Für Entwickler."
    echo "3. Aktivieren Sie den 'Entwicklermodus'."
    echo ""

    die "Plattform-Validierung fehlgeschlagen. Installation abgebrochen."
}

# @description Identifiziert den aktuellen Windows-Benutzer (Git Bash Kontext).
# @return Aktueller Benutzername.
platform_windows_list_target_users() {
    whoami
    return "${EXIT_OK:-0}"
}

true
