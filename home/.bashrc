#!/usr/bin/env bash
#
# FILE: home/.bashrc
# ──────────────────────────────────────────────────────────────
# HAUPT-KONFIGURATIONSFILE FÜR INTERAKTIVE SHELLS (v1.2.1)
# ──────────────────────────────────────────────────────────────
# Zweck:       Zentrale Orchestrierung der Shell-Umgebung.
#              Erkennt Plattformen (Win/Lin) und lädt Module.
# Standards:   Shellcheck-konform, Idempotent, Sicher.
# ──────────────────────────────────────────────────────────────

# ──────────────────────────────────────────────────────────────
# 0. INTERAKTIVITÄTS-CHECK
# ──────────────────────────────────────────────────────────────
# Beendet die Ausführung sofort, wenn die Shell nicht interaktiv ist
# (wichtig für scp, rsync und automatisierte Skripte).
case "$-" in
    *i*) ;; # Interaktiv -> Fortfahren
    *) return ;;
esac

# ──────────────────────────────────────────────────────────────
# 1. PLATTFORM-SPEZIFIKATION & FIXES
# ──────────────────────────────────────────────────────────────
# Windows (Git Bash / MSYS2) spezifische Vorbereitung für Symlinks.
if [[ "$OSTYPE" == msys* || "$OSTYPE" == cygwin* ]]; then
    export MSYS="winsymlinks:nativestrict"
fi

# Zentrale Variable für plattformabhängige Logik in Untermodulen.
# v1.2.1 Sync: Identisch mit der Logik in .bashenv für Redundanz-Sicherheit.
case "$(uname -s)" in
    Linux*)                export PLATFORM="linux" ;;
    MINGW*|MSYS*|CYGWIN*)  export PLATFORM="windows" ;;
    *)                     export PLATFORM="unknown" ;;
esac

# ──────────────────────────────────────────────────────────────
# 2. MODUL-ORCHESTRIERUNG
# ──────────────────────────────────────────────────────────────
# Lädt die Teilkonfigurationen in einer logischen Reihenfolge.
# 1. Env/Path -> 2. Exports -> 3. Prompt -> 4. Aliase -> 5. Funktionen
readonly BASH_MODULES=(
    "$HOME/.bashenv"
    "$HOME/.bashexports"
    "$HOME/.bashprompt"
    "$HOME/.bashaliases"
    "$HOME/.bashfunctions"
)

for file in "${BASH_MODULES[@]}"; do
    if [[ -f "$file" ]]; then
        # shellcheck disable=SC1090
        if ! source "$file"; then
            # Fallback-Farbe (Rot), falls libcolors noch nicht geladen wurde
            echo -e "\e[31m[!] Fehler beim Laden von: $(basename "$file")\e[0m" >&2
        fi
    fi
done

# ──────────────────────────────────────────────────────────────
# 3. PROMPT-INITIALISIERUNG
# ──────────────────────────────────────────────────────────────
# Ruft die Prompt-Funktion aus .bashprompt auf.
if command -v set_bash_prompt >/dev/null 2>&1; then
    set_bash_prompt
else
    # Simpler Fallback-Prompt für den Notfall (ohne UI_COL_ Abhängigkeit)
    PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '
fi

# ──────────────────────────────────────────────────────────────
# 4. AUTO-COMPLETION (BASH & GIT)
# ──────────────────────────────────────────────────────────────
# Aktiviert die intelligente Befehlsvervollständigung.
if ! shopt -oq posix; then
    readonly BC_PATHS=(
        "/usr/share/bash-completion/bash_completion"
        "/etc/bash_completion"
        "/usr/local/etc/bash_completion"
        "/usr/share/git/completion/git-completion.bash"
        "/usr/share/bash-completion/completions/git"
    )

    for bc in "${BC_PATHS[@]}"; do
        if [[ -f "$bc" ]]; then
            # shellcheck disable=SC1090
            source "$bc"
        fi
    done
fi

# ──────────────────────────────────────────────────────────────
# 5. LOKALE ANPASSUNGEN & EDITOR-FIXES
# ──────────────────────────────────────────────────────────────
# Deaktiviert XON/XOFF Flow Control (erlaubt Ctrl+S in Nano/Micro).
[[ -t 0 ]] && stty -ixon 2>/dev/null

# Lädt optionale, systemspezifische Overrides (nicht im Git).
[[ -f "$HOME/.bashrc_local" ]] && source "$HOME/.bashrc_local"

# ──────────────────────────────────────────────────────────────
# ABSCHLUSS
# ──────────────────────────────────────────────────────────────
# Sicherstellen, dass die Datei immer mit Erfolg (0) endet.
true
