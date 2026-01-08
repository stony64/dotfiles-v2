#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: lib/libcolors.sh                                                    │
# │ ZWECK: Definition atomarer ANSI-Escape-Sequenzen und Text-Attribute       │
# │ STANDARDS: set -euo pipefail, Bash >= 4.0, Google Shell Style Guide       │
# └───────────────────────────────────────────────────────────────────────────┘

# INCLUDE GUARD
# Verhindert mehrfaches Laden und Kollisionen mit readonly Variablen.
[[ -n "${_LIB_COLORS_LOADED:-}" ]] && return
readonly _LIB_COLORS_LOADED=1

# @section Steuerzeichen
# ESC-Sequenz-Begrenzer für den dynamischen Zusammenbau in libconstants.sh
readonly UI_ESC_START='\e['
readonly UI_ESC_END='m'

# @section Text-Attribute
# Steuerung der Formatierung (Reset, Fett, Kursiv etc.)
readonly UI_ATTR_RESET='0'
readonly UI_ATTR_BOLD='1'
readonly UI_ATTR_DIM='2'
readonly UI_ATTR_ITALIC='3'
readonly UI_ATTR_UNDERLINE='4'
readonly UI_ATTR_BLINK='5'
readonly UI_ATTR_REVERSE='7'
readonly UI_ATTR_HIDDEN='8'

# @section Vordergrund-Farben
# Standard-Farbpalette (30-37)
readonly UI_COL_BLACK='30'
readonly UI_COL_RED='31'
readonly UI_COL_GREEN='32'
readonly UI_COL_YELLOW='33'
readonly UI_COL_BLUE='34'
readonly UI_COL_MAGENTA='35'
readonly UI_COL_CYAN='36'
readonly UI_COL_WHITE='37'

# @section Hintergrund-Farben
# Hintergrund-Palette (40-47) für Statuszeilen und Header
readonly UI_BG_BLACK='40'
readonly UI_BG_RED='41'
readonly UI_BG_GREEN='42'
readonly UI_BG_YELLOW='43'
readonly UI_BG_BLUE='44'
readonly UI_BG_MAGENTA='45'
readonly UI_BG_CYAN='46'
readonly UI_BG_WHITE='47'

# @section Bright-Varianten (Optionaler Bonus für Modern Terminals)
readonly UI_COL_BRIGHT_BLACK='90'
readonly UI_COL_BRIGHT_WHITE='97'

true
