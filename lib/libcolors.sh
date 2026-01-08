#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: lib/libcolors.sh                                                    │
# │ ZWECK: Definition atomarer ANSI-Werte und Text-Attribute (v1.2.3)         │
# │ INFO: 'readonly' entfernt, um Shell-Reloads zu ermöglichen.               │
# └───────────────────────────────────────────────────────────────────────────┘

# Master-Guard: Verhindert direktes Ausführen ohne Controller
[[ -n "${DOTFILES_CORE_LOADED:-}" ]] || return

# @section Steuerzeichen
# ESC-Sequenz-Begrenzer
UI_ESC_START='\e['
UI_ESC_END='m'

# @section Text-Attribute (Rohwerte)
UI_ATTR_RESET_VAL='0'
UI_ATTR_BOLD_VAL='1'
UI_ATTR_DIM_VAL='2'
UI_ATTR_ITALIC_VAL='3'
UI_ATTR_UNDERLINE_VAL='4'
UI_ATTR_BLINK_VAL='5'
UI_ATTR_REVERSE_VAL='7'
UI_ATTR_HIDDEN_VAL='8'

# @section Vordergrund-Farben (Rohwerte)
UI_COL_BLACK_VAL='30'
UI_COL_RED_VAL='31'
UI_COL_GREEN_VAL='32'
UI_COL_YELLOW_VAL='33'
UI_COL_BLUE_VAL='34'
UI_COL_MAGENTA_VAL='35'
UI_COL_CYAN_VAL='36'
UI_COL_WHITE_VAL='37'

# @section Hintergrund-Farben (Rohwerte)
UI_BG_BLACK_VAL='40'
UI_BG_RED_VAL='41'
UI_BG_GREEN_VAL='42'
UI_BG_YELLOW_VAL='43'
UI_BG_BLUE_VAL='44'
UI_BG_MAGENTA_VAL='45'
UI_BG_CYAN_VAL='46'
UI_BG_WHITE_VAL='47'

# @section Bright-Varianten (Rohwerte)
UI_COL_BRIGHT_BLACK_VAL='90'
UI_COL_BRIGHT_WHITE_VAL='97'

# @section Dynamische Variablen (Export für Subshells/Prompts)
# Hier werden die Rohwerte zu nutzbaren ANSI-Codes kombiniert.
UI_COL_RED="${UI_ESC_START}${UI_COL_RED_VAL}${UI_ESC_END}"
UI_COL_GREEN="${UI_ESC_START}${UI_COL_GREEN_VAL}${UI_ESC_END}"
UI_COL_YELLOW="${UI_ESC_START}${UI_COL_YELLOW_VAL}${UI_ESC_END}"
UI_COL_BLUE="${UI_ESC_START}${UI_COL_BLUE_VAL}${UI_ESC_END}"
UI_COL_RESET="${UI_ESC_START}${UI_ATTR_RESET_VAL}${UI_ESC_END}"

true
