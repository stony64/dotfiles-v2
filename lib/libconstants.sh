#!/usr/bin/env bash
#
# FILE: lib/libconstants.sh
# ──────────────────────────────────────────────────────────────
# ZENTRALE KONFIGURATION UND DATENMODELL
# ──────────────────────────────────────────────────────────────
# Zweck:    Definiert Exit-Codes, UI-Elemente, Pfade und Whitelists.
#           Dient als Single Source of Truth für das Repository.
# Abhängigkeiten: libcolors.sh (muss geladen sein).
# ──────────────────────────────────────────────────────────────

# @section Exit Codes
# Standardisierte Rückgabewerte für alle Funktionen.
readonly EXIT_OK=0
readonly EXIT_FATAL=1
readonly EXIT_WARN=2

# @section UI / Symbole (ASCII-safe)
# Status-Indikatoren für maximale Kompatibilität in TTY/SSH.
readonly SYMBOL_OK="[ OK ]"
readonly SYMBOL_ERROR="[  X  ]"
readonly SYMBOL_WARN="[  i  ]"

# @section CLI-Farben
# Zusammenbau der ANSI-Escapesequenzen aus libcolors.sh Bausteinen.
# Nutzt die atomaren COL_ Variablen aus der Basis-Bibliothek.
readonly COL_RED="${ESC_START}${COL_RED}${ESC_END}"
readonly COL_GREEN="${ESC_START}${COL_GREEN}${ESC_END}"
readonly COL_YELLOW="${ESC_START}${COL_YELLOW}${ESC_END}"
readonly COL_BLUE="${ESC_START}${COL_BLUE}${ESC_END}"
readonly COL_MAGENTA="${ESC_START}${COL_MAGENTA}${ESC_END}"
readonly COL_CYAN="${ESC_START}${COL_CYAN}${ESC_END}"
readonly COL_RESET="${ESC_START}${ATTR_RESET}${ESC_END}"

# @section Log-Formatierung
# Präfixe für die Logging-Funktionen in libcommon.sh.
readonly LOG_PREFIX_INFO="${COL_GREEN}${SYMBOL_OK}${COL_RESET}"
readonly LOG_PREFIX_WARN="${COL_YELLOW}${SYMBOL_WARN}${COL_RESET}"
readonly LOG_PREFIX_ERROR="${COL_RED}${SYMBOL_ERROR}${COL_RESET}"

# @section Erweiterte Stile
# Komplexe UI-Elemente für Header und Hervorhebungen.
readonly STYLE_BOLD="${ESC_START}${ATTR_BOLD}${ESC_END}"
readonly STYLE_DIM="${ESC_START}${ATTR_DIM}${ESC_END}"
readonly STYLE_BOLD_YELLOW="${ESC_START}${ATTR_BOLD};33${ESC_END}"
readonly STYLE_UNDERLINE_GREEN="${ESC_START}${ATTR_UNDERLINE};32${ESC_END}"
readonly STYLE_HEADER_BG="${ESC_START}${ATTR_BOLD};${BG_BLUE};33${ESC_END}"

# @section Pfade & Repo-Struktur
# Interne Verzeichnisnamen des Projekts.
readonly REPO_HOME_DIR="home"
readonly REPO_CONFIG_DIR="config"

# @section Home-Dotfiles (Symlink Whitelist)
# Dateien in 'home/', die in das User-Home verlinkt werden.
readonly DOTFILES_WHITELIST=(
    ".bashrc"
    ".bashexports"
    ".bashenv"
    ".bashprompt"
    ".bashaliases"
    ".bashfunctions"
    ".bashwartung"
    ".dircolors"
    ".nanorc"
)

# @section Shell-Verhalten
# Standardkonfiguration für die Ziel-Umgebung.
readonly SHELL_TMOUT_SSH=0
readonly HIST_SIZE_INTERNAL=8192
readonly HIST_FILE_SIZE_INTERNAL=16384

# @section Runtime-Configs (Copy Whitelist)
# Verzeichnisse in 'config/', die nach ~/.config/ kopiert werden.
readonly RUNTIME_CONFIGS=(
    "mc"
    "micro"
)

true
