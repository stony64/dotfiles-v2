#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: test_suite.sh                                                       │
# │ ZWECK: Automatisierte Validierung (v1.2.2 - /opt & Multi-User aware)      │
# │ STANDARDS: set -euo pipefail, Bash >= 4.0, Modulares Design               │
# └───────────────────────────────────────────────────────────────────────────┘

set -euo pipefail

# ──────────────────────────────────────────────────────────────
# 1. INITIALISIERUNG & BOOTSTRAP (v1.2.2 Pfad-Logik)
# ──────────────────────────────────────────────────────────────

# Ermittlung des absoluten Pfads (Symlink-aware)
SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
readonly REPO_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
cd "$REPO_ROOT"

# Lokalisierung fixen
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# Basis-Bibliotheken laden
LIB_DIR="$REPO_ROOT/lib"
if [[ -f "$LIB_DIR/libcolors.sh" && -f "$LIB_DIR/libconstants.sh" ]]; then
    # shellcheck disable=SC1090
    source "$LIB_DIR/libcolors.sh"
    # shellcheck disable=SC1090
    source "$LIB_DIR/libconstants.sh"
else
    echo -e "\e[31m[!] Kritisch: Test-Abhängigkeiten in $LIB_DIR nicht gefunden.\e[0m" >&2
    exit 1
fi

# ──────────────────────────────────────────────────────────────
# 2. TEST-HILFSFUNKTIONEN
# ──────────────────────────────────────────────────────────────

log_test_result() {
    local status=$1
    local message=$2
    if [[ "$status" -eq 0 ]]; then
        echo -e "    ${UI_COL_GREEN:-}${SYMBOL_OK:-}${UI_COL_RESET:-} $message"
    else
        echo -e "    ${UI_COL_RED:-}${SYMBOL_ERROR:-}${UI_COL_RESET:-} $message"
        return 1
    fi
}

# ──────────────────────────────────────────────────────────────
# 3. TEST-DEFINITIONEN
# ──────────────────────────────────────────────────────────────

# @test Validiert die physische Struktur des Repositories.
test_structure() {
    echo -e "\n${UI_ATTR_BOLD:-}>>> Test 1: Verzeichnis-Struktur & Rechte${UI_COL_RESET:-}"
    local err=0
    [[ -d "home" ]] || { log_test_result 1 "home/ fehlt"; err=1; }
    [[ -d "lib" ]] || { log_test_result 1 "lib/ fehlt"; err=1; }
    [[ -f "dotfilesctl.sh" ]] || { log_test_result 1 "dotfilesctl.sh fehlt"; err=1; }
    [[ -x "dotfilesctl.sh" ]] || { log_test_result 1 "dotfilesctl.sh ist nicht ausführbar"; err=1; }

    [[ $err -eq 0 ]] && log_test_result 0 "Repository-Struktur und Berechtigungen sind integer."
    return $err
}

# @test Prüft die Integrität der Bibliotheken (Include-Guards & Namespace v1.2.2).
test_libraries() {
    echo -e "\n${UI_ATTR_BOLD:-}>>> Test 2: Bibliotheken & Namespace (v1.2.2)${UI_COL_RESET:-}"

    # Test auf Double-Sourcing (Prüfung der Include-Guards)
    # Wir unterdrücken stderr, um die erwarteten 'readonly' Warnungen bei Fehlern zu fangen
    if ( source "$LIB_DIR/libconstants.sh" && source "$LIB_DIR/libconstants.sh" ) 2>/tmp/test_err; then
        log_test_result 0 "Include-Guards verhindern Redefinition erfolgreich."
    else
        log_test_result 1 "Kollision bei Double-Sourcing festgestellt (Check Guards!)."
        return 1
    fi

    # Namespace Check für das neue v1.2.2 Schema (_VAL vs Sequenz)
    local ns_err=0
    [[ -n "${UI_COL_RED_VAL:-}" ]] || { log_test_result 1 "UI_COL_RED_VAL (Rohwert) fehlt"; ns_err=1; }
    [[ -n "${UI_COL_RED:-}" ]]     || { log_test_result 1 "UI_COL_RED (Sequenz) fehlt"; ns_err=1; }

    [[ $ns_err -eq 0 ]] && log_test_result 0 "Namespace-Validierung (_VAL & Sequenzen) erfolgreich."
    return $ns_err
}

# @test Führt eine Trockenübung des Controllers aus.
test_controller_integration() {
    echo -e "\n${UI_ATTR_BOLD:-}>>> Test 3: Controller-Integration (Health Check)${UI_COL_RESET:-}"

    # Wir führen den echten Health-Check im Dry-Run Modus aus
    if ./dotfilesctl.sh health --dry-run > /dev/null 2>&1; then
        log_test_result 0 "Controller 'health' Lauf erfolgreich validiert."
    else
        log_test_result 1 "Controller meldet Inkonsistenzen im System."
        return 1
    fi
}

# ──────────────────────────────────────────────────────────────
# 4. EXECUTION
# ──────────────────────────────────────────────────────────────

echo -e "${UI_ATTR_BOLD:-}${UI_COL_WHITE:-}${UI_BG_BLUE:-}   DOTFILES v1.2.2 - AUTOMATED TEST SUITE   ${UI_COL_RESET:-}"
echo -e "Laufzeit: $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "Repo:     $REPO_ROOT"
echo -e "──────────────────────────────────────────────────────────────"

FAILED_TESTS=0

test_structure || ((FAILED_TESTS++))
test_libraries || ((FAILED_TESTS++))
test_controller_integration || ((FAILED_TESTS++))

echo -e "\n──────────────────────────────────────────────────────────────"

if [[ $FAILED_TESTS -eq 0 ]]; then
    echo -e "${UI_COL_GREEN:-}${UI_ATTR_BOLD:-}ERGEBNIS: Alle Validierungen erfolgreich bestanden!${UI_COL_RESET:-}"
    exit "${EXIT_OK:-0}"
else
    echo -e "${UI_COL_RED:-}${UI_ATTR_BOLD:-}ERGEBNIS: Validierung fehlgeschlagen ($FAILED_TESTS Fehler).${UI_COL_RESET:-}"
    exit "${EXIT_FATAL:-1}"
fi
