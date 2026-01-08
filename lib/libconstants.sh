#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: lib/libconstants.sh                                                 │
# │ ZWECK: Zentrale Konfiguration, UI-Definitionen und Datenmodell            │
# │ STANDARDS: set -euo pipefail, Bash >= 4.0, Google Shell Style Guide       │
# └───────────────────────────────────────────────────────────────────────────┘

# INCLUDE GUARD
[[ -n "${_LIB_CONSTANTS_LOADED:-}" ]] && return
readonly _LIB_CONSTANTS_LOADED=1

# 1. LOCALE FIX
# Erzwingt UTF-8 für konsistente Symbol-Darstellung und Sortierung.
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# 2. EXIT CODES
readonly EXIT_OK=0
readonly EXIT_FATAL=1
readonly EXIT_WARN=2

# 3. UI / SYMBOLE
# ASCII-Fallback-fähig, aber für moderne Terminals optimiert.
readonly SYMBOL_OK="✔"
readonly SYMBOL_ERROR="✘"
readonly SYMBOL_WARN="⚠"
readonly SYMBOL_INFO="ℹ"

# 4. CLI-FARBEN (Zusammengesetzt aus libcolors.sh)
# Wir nutzen die atomaren Werte aus libcolors.sh, um finale Sequenzen zu bilden.
# Fallback auf leere Strings, falls libcolors.sh nicht geladen ist.
readonly UI_COL_RED="${UI_ESC_START:-}${UI_VAL_RED:-}${UI_ESC_END:-}"
readonly UI_COL_GREEN="${UI_ESC_START:-}${UI_VAL_GREEN:-}${UI_ESC_END:-}"
readonly UI_COL_YELLOW="${UI_ESC_START:-}${UI_VAL_YELLOW:-}${UI_ESC_END:-}"
readonly UI_COL_BLUE="${UI_ESC_START:-}${UI_VAL_BLUE:-}${UI_ESC_END:-}"
readonly UI_COL_MAGENTA="${UI_ESC_START:-}${UI_VAL_MAGENTA:-}${UI_ESC_END:-}"
readonly UI_COL_CYAN="${UI_ESC_START:-}${UI_VAL_CYAN:-}${UI_ESC_END:-}"
readonly UI_COL_WHITE="${UI_ESC_START:-}${UI_VAL_WHITE:-}${UI_ESC_END:-}"
readonly UI_COL_RESET="${UI_ESC_START:-}${UI_ATTR_RESET:-}${UI_ESC_END:-}"

# 5. TEXT-STILE
readonly UI_ATTR_BOLD="${UI_ESC_START:-}${UI_ATTR_BOLD:-}${UI_ESC_END:-}"
readonly UI_ATTR_DIM="${UI_ESC_START:-}${UI_ATTR_DIM:-}${UI_ESC_END:-}"
readonly UI_ATTR_UNDERLINE="${UI_ESC_START:-}${UI_ATTR_UNDERLINE:-}${UI_ESC_END:-}"

# 6. LOG-FORMATIERUNG (Zusammengesetzte Präfixe)
readonly LOG_PREFIX_INFO="${UI_COL_CYAN}${SYMBOL_INFO}${UI_COL_RESET}"
readonly LOG_PREFIX_SUCCESS="${UI_COL_GREEN}${SYMBOL_OK}${UI_COL_RESET}"
readonly LOG_PREFIX_WARN="${UI_COL_YELLOW}${SYMBOL_WARN}${UI_COL_RESET}"
readonly LOG_PREFIX_ERROR="${UI_COL_RED}${SYMBOL_ERROR}${UI_COL_RESET}"

# 7. PFADE & REPO-STRUKTUR
readonly REPO_HOME_DIR="home"
readonly REPO_CONFIG_DIR="config"

# 8. DOTFILES_WHITELIST (Symlink-Zielobjekte)
# Dateien innerhalb von /home im Repo, die nach $HOME gelinkt werden.
readonly DOTFILES_WHITELIST=(
    ".bashrc"
    ".bashexports"
    ".bashenv"
    ".bashprompt"
    ".bashaliases"
    ".bashfunctions"
    ".dircolors"
    ".nanorc"
)

# 9. RUNTIME_CONFIGS (Directory Copy Whitelist)
# Verzeichnisse aus /config, die nach $XDG_CONFIG_HOME kopiert werden.
readonly RUNTIME_CONFIGS=(
    "mc"
    "micro"
)

# 10. SYSTEM-CONSTANTS
readonly HIST_SIZE_INTERNAL=8192
readonly HIST_FILE_SIZE_INTERNAL=16384

true
