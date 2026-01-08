#!/usr/bin/env bash
#
# FILE: test_suite.sh
# ──────────────────────────────────────────────────────────────
# AUTOMATISIERTE TEST-SUITE FÜR DAS DOTFILES-PROJEKT
# ──────────────────────────────────────────────────────────────
# Zweck:    Validierung der Kern-Logik (Installation, Idempotenz)
#           in einer isolierten Sandbox-Umgebung (/tmp).
# Standards: set -euo pipefail, Bash >= 4.0, Modulares Design.
# ──────────────────────────────────────────────────────────────

set -euo pipefail

# ──────────────────────────────────────────────────────────────
# 1. INITIALISIERUNG & KONSTANTEN
# ──────────────────────────────────────────────────────────────

# @description Pfade für die isolierte Test-Umgebung.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TEST_SANDBOX="/tmp/dotfiles_test_env"
readonly TEST_HOME="${TEST_SANDBOX}/home_dir"
readonly TEST_REPO="${TEST_SANDBOX}/repo"

# Laden der Kern-Bibliotheken für konsistente Farbausgaben und Exit-Codes.
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/libcolors.sh"
source "${SCRIPT_DIR}/lib/libconstants.sh"

# ──────────────────────────────────────────────────────────────
# 2. HILFSFUNKTIONEN (TEST-FRAMEWORK)
# ──────────────────────────────────────────────────────────────

# @description Gibt eine formatierte Header-Nachricht aus.
# @param $1 Nachrichtentext.
# @stdout Formatiertes Header-Präfix.
msg() {
    echo -e "\n${COL_BLUE}>>>${COL_RESET} ${STYLE_BOLD}$1${COL_RESET}"
}

# @description Gibt eine positive Bestätigung aus.
# @param $1 Nachrichtentext.
# @stdout Formatiertes Erfolgs-Symbol mit Nachricht.
success() {
    echo -e "    ${COL_GREEN}${SYMBOL_OK}${COL_RESET} $1"
}

# @description Gibt eine Fehlermeldung aus und bricht den Testlauf ab.
# @param $1 Fehlermeldung.
# @stdout Fehlermeldung auf stderr.
# @return EXIT_FATAL (via exit).
error() {
    echo -e "    ${COL_RED}${SYMBOL_ERROR}${COL_RESET} $1" >&2
    exit "$EXIT_FATAL"
}

# ──────────────────────────────────────────────────────────────
# 3. TEST-DEFINITIONEN
# ──────────────────────────────────────────────────────────────

# @description Bereitet die Sandbox-Umgebung vor.
# @stdout Status der Verzeichniserstellung und Kopiervorgänge.
# @return EXIT_OK oder bricht via error() ab.
setup_test_env() {
    msg "Initialisiere Test-Umgebung in ${TEST_SANDBOX}"
    rm -rf "$TEST_SANDBOX"
    mkdir -p "$TEST_HOME"
    mkdir -p "$TEST_REPO"

    # Kopiere das gesamte Projekt in die Sandbox für isolierte Ausführung.
    cp -r "${SCRIPT_DIR}/"* "$TEST_REPO/"
    success "Test-Umgebung bereitgestellt."
    return "$EXIT_OK"
}

# @description Führt eine Simulation der Installation durch.
# @stdout Output des dotfilesctl.sh im Dry-Run Modus.
# @return EXIT_OK oder bricht via error() ab.
test_install_dry_run() {
    msg "Test: Install Dry-Run"
    (
        cd "$TEST_REPO"
        # Simulation der Umgebungsvariablen für Portabilität
        HOME="$TEST_HOME" USER="$(whoami)" ./dotfilesctl.sh install --dry-run --user "$(whoami)"
    ) || error "Dry-Run Befehl ist mit Fehlern abgebrochen."
    success "Dry-Run erfolgreich durchgelaufen."
    return "$EXIT_OK"
}

# @description Führt eine tatsächliche Installation in der Sandbox aus.
# @stdout Output der Installation.
# @return EXIT_OK oder bricht via error() ab.
test_actual_install() {
    msg "Test: Echte Installation"
    (
        cd "$TEST_REPO"
        HOME="$TEST_HOME" USER="$(whoami)" ./dotfilesctl.sh install --user "$(whoami)"
    ) || error "Die Installation in der Sandbox ist fehlgeschlagen."

    # Validierung: Prüft ob .bashrc als Symlink im Test-Home existiert.
    if [[ -L "${TEST_HOME}/.bashrc" ]]; then
        success "Symlink .bashrc wurde korrekt erstellt."
    else
        error ".bashrc Symlink fehlt nach Installation."
    fi
    return "$EXIT_OK"
}

# @description Prüft, ob mehrfache Ausführung den Systemzustand nicht verändert (Idempotenz).
# @stdout Bestätigung der Idempotenz basierend auf Log-Output.
# @return EXIT_OK oder bricht via error() ab.
test_idempotency() {
    msg "Test: Idempotenz (Mehrfache Ausführung)"
    local output
    # Abfangen des Outputs, um auf die "bereits korrekt" Meldung zu prüfen.
    output=$(cd "$TEST_REPO" && HOME="$TEST_HOME" USER="$(whoami)" ./dotfilesctl.sh install --user "$(whoami)")

    if echo "$output" | grep -q "bereits korrekt"; then
        success "Idempotenz bestätigt: Link erkannt und nicht unnötig überschrieben."
    else
        error "Idempotenz-Check fehlgeschlagen (Erneute Installation trotz Existenz)."
    fi
    return "$EXIT_OK"
}

# @description Bereinigt die Test-Umgebung.
# @stdout Status der Bereinigung.
test_cleanup() {
    msg "Räume Test-Umgebung auf"
    rm -rf "$TEST_SANDBOX"
    success "Cleanup abgeschlossen."
}

# ──────────────────────────────────────────────────────────────
# 4. EXECUTION
# ──────────────────────────────────────────────────────────────

# @description Hauptprozess zur Ausführung der Test-Suiten.
# @param $@ Kommandozeilenargumente (derzeit nicht genutzt).
main() {
    # Sicherheitsprüfung: Skript-Lokalisierung verifizieren.
    if [[ ! -f "${SCRIPT_DIR}/dotfilesctl.sh" ]]; then
        echo -e "${COL_RED}${SYMBOL_ERROR}${COL_RESET} Fehler: Test-Suite muss im Root des Dotfiles-Repos liegen." >&2
        exit "$EXIT_FATAL"
    fi

    setup_test_env

    # Ausführung der Test-Cases
    test_install_dry_run
    test_actual_install
    test_idempotency

    echo -e "\n${COL_GREEN}${STYLE_BOLD}ALLE TESTS ERFOLGREICH BESTANDEN!${COL_RESET} ${SYMBOL_OK}"

    test_cleanup
}

main "$@"
