#!/usr/bin/env bash
#
# FILE: lib/libconstants.sh
# ──────────────────────────────────────────────────────────────
# ZENTRALE KONFIGURATION UND DATENMODELL (v1.2.1)
# ──────────────────────────────────────────────────────────────

# 1. INCLUDE GUARD (Verhindert "readonly variable" Fehler bei Double-Sourcing)
[[ -n "${_LIB_CONSTANTS_LOADED:-}" ]] && return
readonly _LIB_CONSTANTS_LOADED=1

# 2. LOCALE FIX (Verhindert setlocale Warnungen in Test-Umgebungen)
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# @section Exit Codes
readonly EXIT_OK=0
readonly EXIT_FATAL=1
readonly EXIT_WARN=2

# @section UI / Symbole (ASCII-safe)
readonly SYMBOL_OK="[ OK ]"
readonly SYMBOL_ERROR="[  X  ]"
readonly SYMBOL_WARN="[  i  ]"

# @section CLI-Farben (Finalisierte Sequenzen)
# HINWEIS: Wir nutzen hier UI_ Präfixe, um Konflikte mit libcolors.sh
# (den Rohdaten) zu vermeiden und das "readonly" Problem zu lösen.
readonly UI_COL_RED="${ESC_START}${COL_RED}${ESC_END}"
readonly UI_COL_GREEN="${ESC_START}${COL_GREEN}${ESC_END}"
readonly UI_COL_YELLOW="${ESC_START}${COL_YELLOW}${ESC_END}"
readonly UI_COL_BLUE="${ESC_START}${COL_BLUE}${ESC_END}"
readonly UI_COL_MAGENTA="${ESC_START}${COL_MAGENTA}${ESC_END}"
readonly UI_COL_CYAN="${ESC_START}${COL_CYAN}${ESC_END}"
readonly UI_COL_RESET="${ESC_START}${ATTR_RESET}${ESC_END}"

# @section Log-Formatierung
readonly LOG_PREFIX_INFO="${UI_COL_GREEN}${SYMBOL_OK}${UI_COL_RESET}"
readonly LOG_PREFIX_WARN="${UI_COL_YELLOW}${SYMBOL_WARN}${UI_COL_RESET}"
readonly LOG_PREFIX_ERROR="${UI_COL_RED}${SYMBOL_ERROR}${UI_COL_RESET}"

# @section Erweiterte Stile
readonly STYLE_BOLD="${ESC_START}${ATTR_BOLD}${ESC_END}"
readonly STYLE_DIM="${ESC_START}${ATTR_DIM}${ESC_END}"
readonly STYLE_BOLD_YELLOW="${ESC_START}${ATTR_BOLD};33${ESC_END}"
readonly STYLE_UNDERLINE_GREEN="${ESC_START}${ATTR_UNDERLINE};32${ESC_END}"
readonly STYLE_HEADER_BG="${ESC_START}${ATTR_BOLD};${BG_BLUE};33${ESC_END}"

# @section Pfade & Repo-Struktur
readonly REPO_HOME_DIR="home"
readonly REPO_CONFIG_DIR="config"

# @section Home-Dotfiles (Symlink Whitelist)
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

# @section Shell-Verhalten
readonly SHELL_TMOUT_SSH=0
readonly HIST_SIZE_INTERNAL=8192
readonly HIST_FILE_SIZE_INTERNAL=16384

# @section Runtime-Configs (Copy Whitelist)
readonly RUNTIME_CONFIGS=(
    "mc"
    "micro"
)

true
