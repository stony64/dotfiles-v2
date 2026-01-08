#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: lib/libcolors.sh                                                    │
# │ ZWECK: Definition atomarer ANSI-Werte und Text-Attribute (v1.2.1)         │
# │ STANDARDS: set -euo pipefail, Bash >= 4.0, Google Shell Style Guide       │
# └───────────────────────────────────────────────────────────────────────────┘

# @section Steuerzeichen
# ESC-Sequenz-Begrenzer für den dynamischen Zusammenbau in libconstants.sh
readonly UI_ESC_START='\e['
readonly UI_ESC_END='m'

# @section Text-Attribute (Rohwerte)
# Steuerung der Formatierung (Reset, Fett, Kursiv etc.)
readonly UI_ATTR_RESET_VAL='0'
readonly UI_ATTR_BOLD_VAL='1'
readonly UI_ATTR_DIM_VAL='2'
readonly UI_ATTR_ITALIC_VAL='3'
readonly UI_ATTR_UNDERLINE_VAL='4'
readonly UI_ATTR_BLINK_VAL='5'
readonly UI_ATTR_REVERSE_VAL='7'
readonly UI_ATTR_HIDDEN_VAL='8'

# @section Vordergrund-Farben (Rohwerte)
# Standard-Farbpalette (30-37)
readonly UI_COL_BLACK_VAL='30'
readonly UI_COL_RED_VAL='31'
readonly UI_COL_GREEN_VAL='32'
readonly UI_COL_YELLOW_VAL='33'
readonly UI_COL_BLUE_VAL='34'
readonly UI_COL_MAGENTA_VAL='35'
readonly UI_COL_CYAN_VAL='36'
readonly UI_COL_WHITE_VAL='37'

# @section Hintergrund-Farben (Rohwerte)
# Hintergrund-Palette (40-47) für Statuszeilen und Header
readonly UI_BG_BLACK_VAL='40'
readonly UI_BG_RED_VAL='41'
readonly UI_BG_GREEN_VAL='42'
readonly UI_BG_YELLOW_VAL='43'
readonly UI_BG_BLUE_VAL='44'
readonly UI_BG_MAGENTA_VAL='45'
readonly UI_BG_CYAN_VAL='46'
readonly UI_BG_WHITE_VAL='47'

# @section Bright-Varianten (Rohwerte)
readonly UI_COL_BRIGHT_BLACK_VAL='90'
readonly UI_COL_BRIGHT_WHITE_VAL='97'

true
