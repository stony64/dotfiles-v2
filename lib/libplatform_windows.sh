#!/usr/bin/env bash
#
# FILE: lib/libplatform_windows.sh
# ──────────────────────────────────────────────────────────────
# WINDOWS-SPEZIFISCHE IMPLEMENTIERUNGEN (v1.2.1)
# ──────────────────────────────────────────────────────────────
# Zweck:     Konfiguration nativer Windows-Symlinks und Validierung
#            von Berechtigungen (Entwicklermodus).
# ──────────────────────────────────────────────────────────────

# 1. INCLUDE GUARD
[[ -n "${_LIB_PLATFORM_WINDOWS_LOADED:-}" ]] && return
readonly _LIB_PLATFORM_WINDOWS_LOADED=1

# @description Initialisiert die Windows-Umgebung für native Symlinks.
platform_windows_init() {
    # Erzwingt native Windows-Symlinks anstelle von MSYS-Emulationen (Kopien).
    export MSYS="winsymlinks:nativestrict"

    if [[ "${MSYS:-}" != *"winsymlinks:nativestrict"* ]]; then
        die "Konnte MSYS=winsymlinks:nativestrict nicht setzen."
    fi
    return "$EXIT_OK"
}

# @description Verifiziert proaktiv, ob der User Symlinks erstellen darf.
platform_windows_require_symlink_rights() {
    log_info "Prüfe Windows Symlink-Berechtigungen..."

    local tmp_dir test_target test_link
    tmp_dir="$(mktemp -d 2>/dev/null || echo "")"
    [[ -z "$tmp_dir" || ! -d "$tmp_dir" ]] && die "Konnte temporäres Verzeichnis für Test nicht erstellen."

    test_target="${tmp_dir}/target_file"
    test_link="${tmp_dir}/test_link"

    # 'nativestrict' erfordert zwingend die Existenz der Quelldatei.
    printf '%s\n' "symlink-test" >"$test_target" || die "Konnte Test-Datei nicht erstellen."

    # 1. Test: Versuche einen symbolischen Link zu erstellen
    if ln -s "$test_target" "$test_link" 2>/dev/null; then
        # Erfolg: Aufräumen und fortfahren
        rm -f "$test_link" "$test_target" 2>/dev/null || true
        rmdir "$tmp_dir" 2>/dev/null || true

        echo -e "    ${UI_COL_GREEN}${SYMBOL_OK}${UI_COL_RESET} Symlink-Rechte erfolgreich verifiziert."
        return "$EXIT_OK"
    fi

    # 2. Fehlerfall: Aufräumen und Benutzer informieren
    rm -f "$test_link" "$test_target" 2>/dev/null || true
    rmdir "$tmp_dir" 2>/dev/null || true

    echo -e "${UI_COL_RED}${SYMBOL_ERROR} FEHLER: Native Symlinks konnten nicht erstellt werden.${UI_COL_RESET}" >&2
    cat <<EOF >&2

Mögliche Ursachen:
1) Der 'Entwicklermodus' (Developer Mode) ist in den Windows-Einstellungen NICHT aktiviert.
2) Die Sicherheitsrichtlinie 'Erstellen symbolischer Verknüpfungen' fehlt für Ihren Account.
3) Git Bash wurde nicht mit ausreichenden Rechten gestartet.

Maßnahme: Aktivieren Sie den Entwicklermodus in den Windows 10/11 Einstellungen, um
Symlinks ohne Administratorrechte zu ermöglichen.
EOF
    exit "$EXIT_FATAL"
}

# @description Identifiziert den aktuellen Windows-Benutzer.
platform_windows_list_target_users() {
    whoami
    return "$EXIT_OK"
}

true
