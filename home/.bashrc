#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: home/.bashrc                                                        │
# │ ZWECK: Haupt-Konfigurationsfile (v1.2.3 - Centralized Edition)             │
# └───────────────────────────────────────────────────────────────────────────┘

# 1. INTERAKTIVITÄTS-CHECK
case "$-" in
    *i*) ;;
    *) return ;;
esac

# 2. MASTER-GUARD & PFADE (v1.2.3 Standard)
DOTFILES_CORE_LOADED=1
export DOTFILES_CORE_LOADED
export REPO_ROOT="/opt/dotfiles"

# 3. ZENTRALE BIBLIOTHEKEN LADEN
# WICHTIG: libcolors.sh stellt die UI-Variablen bereit
if [[ -d "$REPO_ROOT/lib" ]]; then
    # shellcheck disable=SC1091
    source "$REPO_ROOT/lib/libcolors.sh"
    # shellcheck disable=SC1091
    source "$REPO_ROOT/lib/libconstants.sh"
fi

# 4. MODUL-ORCHESTRIERUNG
# Array ohne readonly, um Re-Sourcing zu erlauben
BASH_MODULES=(
    "$HOME/.bashenv"
    "$HOME/.bashexports"
    "$HOME/.bashprompt"
    "$HOME/.bashaliases"
    "$HOME/.bashfunctions"
)

for module in "${BASH_MODULES[@]}"; do
    if [[ -f "$module" ]]; then
        # shellcheck disable=SC1090
        source "$module" || echo -e "\e[31m[!] Fehler in: ${module##*/}\e[0m" >&2
    fi
done

# 5. PROMPT-AKTIVIERUNG (v1.2.3 Fix)
# Wir nutzen hier hartkodierte Escapes oder stellen sicher, dass libcolors
# für PS1 kompatibel ist (mit \[ \]).
if command -v set_bash_prompt >/dev/null 2>&1; then
    set_bash_prompt
else
    # Fallback: Wir nutzen \033 statt Variablen, falls libcolors keine
    # Prompt-Maskierung (\[ \]) enthält, um Cursor-Glitch zu vermeiden.
    _C_RED='\[\e[31m\]'
    _C_GRN='\[\e[32m\]'
    _C_BLU='\[\e[34m\]'
    _C_RST='\[\e[0m\]'

    if [[ $EUID -eq 0 ]]; then
        PS1="${_C_RED}\u@\h${_C_RST}:${_C_BLU}\w${_C_RST}\$ "
    else
        PS1="${_C_GRN}\u@\h${_C_RST}:${_C_BLU}\w${_C_RST}\$ "
    fi
    unset _C_RED _C_GRN _C_BLU _C_RST
fi

# 6. AUTO-COMPLETION
if ! shopt -oq posix; then
    for bc in "/usr/share/bash-completion/bash_completion" "/etc/bash_completion"; do
        [[ -f "$bc" ]] && source "$bc"
    done
fi

# 7. TERMINAL-FIX (Ctrl+S Support für Editoren)
[[ -t 0 ]] && stty -ixon 2>/dev/null

# 8. LOKALE ANPASSUNGEN
[[ -f "$HOME/.bashrc_local" ]] && source "$HOME/.bashrc_local"

true
