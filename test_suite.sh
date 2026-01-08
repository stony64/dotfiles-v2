#!/usr/bin/env bash
#
# FILE: test_suite.sh
# ──────────────────────────────────────────────────────────────
# AUTOMATISIERTE VALIDIERUNG (v1.2.1)
# ──────────────────────────────────────────────────────────────
# Zweck:       Prüft die Integrität der Dotfiles und Skripte.
#              Stellt sicher, dass v1.2.1 Standards eingehalten werden.
# ──────────────────────────────────────────────────────────────

# 1. Globale Einstellungen (Sicherheit geht vor)
set -o errexit  # Abbruch bei Fehlern
set -o nounset  # Abbruch bei nicht definierten Variablen (unbound variable fix)
set -o pipefail # Fehler in Pipes erkennen

# 2. Umgebung fixen (Locale & Pfade)
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export PATH="$(pwd):$PATH"

# 3. Bibliotheken laden
# Wichtig: Die Reihenfolge muss stimmen (Basis -> Konstanten)
LIB_DIR="./lib"
if [[ -f "$LIB_DIR/libcolors.sh" && -f "$LIB_DIR/libconstants.sh" ]]; then
    source "$LIB_DIR/libcolors.sh"
    source "$LIB_DIR/libconstants.sh"
else
    echo "[!] Fehler: Bibliotheken in $LIB_DIR nicht gefunden."
    exit 1
fi

# ──────────────────────────────────────────────────────────────
# TEST-FUNKTIONEN
# ──────────────────────────────────────────────────────────────

log_test() {
    local status=$1
    local message=$2
    if [[ "$status" -eq 0 ]]; then
        echo -e "${UI_COL_GREEN}${SYMBOL_OK}${UI_COL_RESET} $message"
    else
        echo -e "${UI_COL_RED}${SYMBOL_ERROR}${UI_COL_RESET} $message"
        return 1
    fi
}

# @test: Prüfung der Repository-Struktur
test_structure() {
    echo -e "\n${STYLE_BOLD}>>> Test 1: Verzeichnis-Struktur${UI_COL_RESET}"
    [[ -d "home" ]] && log_test 0 "home/ Verzeichnis existiert."
    [[ -d "lib" ]]  && log_test 0 "lib/ Verzeichnis existiert."
    [[ -f "dotfilesctl.sh" ]] && log_test 0 "Controller-Skript vorhanden."
}

# @test: Prüfung der Bibliotheken (Double-Sourcing Test)
test_libraries() {
    echo -e "\n${STYLE_BOLD}>>> Test 2: Bibliotheken & Namespace${UI_COL_RESET}"
    # Versuche Double-Sourcing (darf dank Include-Guard nicht crashen)
    if source "$LIB_DIR/libconstants.sh"; then
        log_test 0 "Library Include-Guards arbeiten korrekt (keine Redefinition)."
    fi
    [[ -n "${UI_COL_RED:-}" ]] && log_test 0 "Namespace UI_COL_ korrekt initialisiert."
}

# @test: Doctor-Kommando des Controllers
test_controller_doctor() {
    echo -e "\n${STYLE_BOLD}>>> Test 3: Controller Logik (Doctor)${UI_COL_RESET}"
    if ./dotfilesctl.sh doctor > /dev/null 2>&1; then
        log_test 0 "Command 'doctor' liefert EXIT_OK."
    else
        log_test 1 "Command 'doctor' fehlgeschlagen."
    fi
}

# ──────────────────────────────────────────────────────────────
# HAUPT-EXECUTION
# ──────────────────────────────────────────────────────────────

echo -e "${STYLE_HEADER_BG}   DOTFILES v1.2.1 VALIDIERUNG   ${UI_COL_RESET}"
echo -e "Datum: $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "System: $PLATFORM"

# Tests in Subshell ausführen, um Haupt-Shell sauber zu halten
(
    test_structure
    test_libraries
    test_controller_doctor
)

TEST_RESULT=$?

echo -e "\n──────────────────────────────────────────────────────────────"
if [[ $TEST_RESULT -eq 0 ]]; then
    echo -e "${UI_COL_GREEN}ERGEBNIS: Alle Tests erfolgreich bestanden!${UI_COL_RESET}"
    exit 0
else
    echo -e "${UI_COL_RED}ERGEBNIS: Validierung fehlgeschlagen.${UI_COL_RESET}"
    exit 1
fi
