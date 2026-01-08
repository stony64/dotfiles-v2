#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: dotfilesctl.sh                                                      │
# │ ZWECK: Zentraler Orchestrator (v1.2.3 - Master Guard Edition)             │
# │ STANDARDS: set -euo pipefail, Bash >= 4.0                                 │
# └───────────────────────────────────────────────────────────────────────────┘

set -euo pipefail

# ──────────────────────────────────────────────────────────────
# 1. MASTER GUARD & PFAD-AUFLÖSUNG
# ──────────────────────────────────────────────────────────────

# Diese Variable verhindert Mehrfach-Sourcing in den Bibliotheken
# Wir verzichten auf 'readonly', damit 'source ~/.bashrc' fehlerfrei bleibt.
DOTFILES_CORE_LOADED=1
export DOTFILES_CORE_LOADED

# Ermittlung des absoluten Repo-Roots (Symlink-aware)
SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
readonly REPO_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# ──────────────────────────────────────────────────────────────
# 2. MODULARES LADEN DER BIBLIOTHEKEN
# ──────────────────────────────────────────────────────────────

LIB_FILES=(
    "libcolors.sh"
    "libconstants.sh"
    "libcommon.sh"
    "libplatform_linux.sh"
    "libplatform_windows.sh"
    "libengine.sh"
    "libchecks.sh"
)

for lib in "${LIB_FILES[@]}"; do
    lib_path="${REPO_ROOT}/lib/$lib"
    if [[ -f "$lib_path" ]]; then
        # shellcheck disable=SC1090
        source "$lib_path"
    else
        echo -e "\e[31m[ X ] KRITISCH: Bibliothek nicht gefunden: $lib_path\e[0m" >&2
        exit 1
    fi
done

# ──────────────────────────────────────────────────────────────
# 3. CLI LOGIK (Gekürzt für Übersicht)
# ──────────────────────────────────────────────────────────────

# ... (Hier folgen die Funktionen wie usage, cmd_install_uninstall, cmd_health_checks) ...
# Diese bleiben identisch zur v1.2.2, da sie bereits auf REPO_ROOT basieren.

main() {
    # ... (Deine bestehende Main-Logik) ...
    echo "Dotfiles v1.2.3 aktiv. Root: $REPO_ROOT"
}

# Starte nur, wenn das Skript direkt aufgerufen wird (nicht beim Sourcing)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
