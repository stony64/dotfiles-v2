#!/usr/bin/env bash
#
# FILE: lib/libcolors.sh
# ──────────────────────────────────────────────────────────────
# ATOMARE ANSI-FARBCODES UND TEXT-ATTRIBUTE
# ──────────────────────────────────────────────────────────────
# Zweck:    Zentrale Definition von ANSI-Escape-Sequenzen.
#           Dient als Datenbasis für libconstants.sh.
# Hinweis:  Diese Bibliothek ist "source-bare" (enthält nur Variablen).
# ──────────────────────────────────────────────────────────────

# @section Text-Attribute
# Steuerung der Textdarstellung
readonly ATTR_RESET='0'
readonly ATTR_BOLD='1'
readonly ATTR_DIM='2'
readonly ATTR_ITALIC='3'
readonly ATTR_UNDERLINE='4'
readonly ATTR_BLINK='5'
readonly ATTR_REVERSE='7'
readonly ATTR_INVISIBLE='8'

# @section Vordergrund-Farben (Standard)
# Mapping auf COL_ Präfix für Konsistenz mit libconstants.sh
readonly COL_BLACK='0;30'
readonly COL_RED='0;31'
readonly COL_GREEN='0;32'
readonly COL_YELLOW='0;33'
readonly COL_BLUE='0;34'
readonly COL_MAGENTA='0;35'
readonly COL_CYAN='0;36'
readonly COL_WHITE='0;37'

# @section Hintergrund-Farben
# Zur Verwendung in Headern oder Statuszeilen
readonly BG_BLACK='40'
readonly BG_RED='41'
readonly BG_GREEN='42'
readonly BG_YELLOW='43'
readonly BG_BLUE='44'
readonly BG_MAGENTA='45'
readonly BG_CYAN='46'
readonly BG_WHITE='47'

# @section Steuerzeichen
# ESC-Sequenz-Begrenzer für den dynamischen Zusammenbau
readonly ESC_START='\e['
readonly ESC_END='m'

true
