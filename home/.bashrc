#!/usr/bin/env bash
#
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ FILE: home/.bashrc                                                        │
# │ ZWECK: Haupt-Konfigurationsfile für interaktive Shells (v1.2.1)           │
# │ STANDARDS: set -u (optional), Bash >= 4.0, Google Shell Style Guide       │
# └───────────────────────────────────────────────────────────────────────────┘

# ──────────────────────────────────────────────────────────────
# 0. INTERAKTIVITÄTS-CHECK
# ──────────────────────────────────────────────────────────────
# Verhindert Ausführung bei nicht-interaktiven Aufrufen (scp, rsync).
case "$-" in
    *i*) ;; # Interaktiv -> Fortfahren
    *) return ;;
esac

# ──────────────────────────────────────────────────────────────
# 1. PLATTFORM-DETEKTION & INITIALISIERUNG
# ──────────────────────────────────────────────────────────────

# Windows-spezifische Vorbereitung für native NTFS-Symlinks.
if [[ "$OSTYPE" == msys* || "$OSTYPE" == cygwin* ]]; then
    export MSYS="winsymlinks:nativestrict"
fi

# Zentrale Plattformvariable (v1.2.1 Standard)
case "$(uname -s)" in
    Linux*)                export PLATFORM="linux" ;;
    MINGW*|MSYS*|CYGWIN*)  export PLATFORM="windows" ;;
    *)                     export PLATFORM="unknown" ;;
esac

# ──────────────────────────────────────────────────────────────
# 2. MODUL-ORCHESTRIERUNG (BOOTSTRAP)
# ──────────────────────────────────────────────────────────────
# Die Reihenfolge ist kritisch: Erst Basis-Umgebung, dann UI/Aliase.

readonly BASH_MODULES=(
    "$HOME/.bashenv"        # 1. Pfade & Shell-Optionen
    "$HOME/.bashexports"    # 2. Tool-Exporte & Editoren
    "$HOME/.bashprompt"     # 3. PS1-Konfiguration
    "$HOME/.bashaliases"    # 4. Abkürzungen
    "$HOME/.bashfunctions"  # 5. Erweiterte Logik
)

for module in "${BASH_MODULES[@]}"; do
    if [[ -f "$module" ]]; then
        # shellcheck disable=SC1090
        if ! source "$module"; then
            # Fehlermeldung mit rotem Fallback, falls libcolors noch nicht geladen
            echo -e "\e[31m[!] Fehler beim Laden des Moduls: ${module##*/}\e[0m" >&2
        fi
    fi
done

# ──────────────────────────────────────────────────────────────
# 3. PROMPT-AKTIVIERUNG
# ──────────────────────────────────────────────────────────────

if command -v set_bash_prompt >/dev/null 2>&1; then
    set_bash_prompt
else
    # Minimalistischer Fallback-Prompt für den Havariefall
    PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '
fi

# ──────────────────────────────────────────────────────────────
# 4. AUTO-COMPLETION (BASH & GIT)
# ──────────────────────────────────────────────────────────────
# Aktiviert die intelligente Tab-Vervollständigung für Befehle und Git.

if ! shopt -oq posix; then
    _BC_PATHS=(
        "/usr/share/bash-completion/bash_completion"
        "/etc/bash_completion"
        "/usr/local/etc/bash_completion"
        "/usr/share/git/completion/git-completion.bash"
        "/usr/share/bash-completion/completions/git"
    )

    for bc_path in "${_BC_PATHS[@]}"; do
        if [[ -f "$bc_path" ]]; then
            # shellcheck disable=SC1090
            source "$bc_path"
        fi
    done
    unset _BC_PATHS
fi

# ──────────────────────────────────────────────────────────────
# 5. TERMINAL-OPTIMIERUNG & LOKALE ANPASSUNGEN
# ──────────────────────────────────────────────────────────────

# Deaktiviert XON/XOFF Flow Control.
# Dies ermöglicht die Nutzung von Ctrl+S (Save) in Editoren wie Micro oder Nano.
if [[ -t 0 ]]; then
    stty -ixon 2>/dev/null
fi

# Lädt optionale, systemspezifische Anpassungen (nicht im Git/Whitelist).
# Hier können private Aliase oder experimentelle Funktionen stehen.
[[ -f "$HOME/.bashrc_local" ]] && source "$HOME/.bashrc_local"

# ──────────────────────────────────────────────────────────────
# ABSCHLUSS
# ──────────────────────────────────────────────────────────────

# Erfolgreicher Exit-Status für das Sourcing
true
