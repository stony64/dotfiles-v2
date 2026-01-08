#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: home/.bashrc                                                        │
# │ ZWECK: Haupt-Konfigurationsfile (v1.2.3 - Centralized Edition)            │
# └───────────────────────────────────────────────────────────────────────────┘

# 1. INTERAKTIVITÄTS-CHECK
case "$-" in
    *i*) ;;
    *) return ;;
esac

# 2. MASTER-GUARD & PFADE (v1.2.3 Standard)
# Wir verwenden KEIN readonly, um Fehler beim Re-Sourcing zu vermeiden
DOTFILES_CORE_LOADED=1
export DOTFILES_CORE_LOADED
export REPO_ROOT="/opt/dotfiles"

# 3. ZENTRALE BIBLIOTHEKEN LADEN (Für Farben und Logik)
# Diese Dateien liegen jetzt in /opt/dotfiles/lib/
if [[ -d "$REPO_ROOT/lib" ]]; then
    source "$REPO_ROOT/lib/libcolors.sh"
    source "$REPO_ROOT/lib/libconstants.sh"
fi

# 4. MODUL-ORCHESTRIERUNG
# Wir nutzen ein normales Array statt readonly
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
        source "$module" || echo -e "${UI_COL_RED:-}[!] Fehler in: ${module##*/}${UI_COL_RESET:-}" >&2
    fi
done

# 5. PROMPT-AKTIVIERUNG (Farben für Root/User)
# Falls .bashprompt die Funktion set_bash_prompt bereitstellt:
if command -v set_bash_prompt >/dev/null 2>&1; then
    set_bash_prompt
else
    # Fallback mit v1.2.3 Farbvariablen
    if [[ $EUID -eq 0 ]]; then
        PS1='\[${UI_COL_RED:-}\]\u@\h\[${UI_COL_RESET:-}\]:\[${UI_COL_BLUE:-}\]\w\[${UI_COL_RESET:-}\]\$ '
    else
        PS1='\[${UI_COL_GREEN:-}\]\u@\h\[${UI_COL_RESET:-}\]:\[${UI_COL_BLUE:-}\]\w\[${UI_COL_RESET:-}\]\$ '
    fi
fi

# 6. AUTO-COMPLETION
if ! shopt -oq posix; then
    [[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion
    [[ -f /etc/bash_completion ]] && source /etc/bash_completion
fi

# 7. TERMINAL-FIX (Ctrl+S Support)
[[ -t 0 ]] && stty -ixon 2>/dev/null

# 8. LOKALE ANPASSUNGEN
[[ -f "$HOME/.bashrc_local" ]] && source "$HOME/.bashrc_local"

true
