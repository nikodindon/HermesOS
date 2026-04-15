#!/usr/bin/env bash
# customize-chroot.sh — HermesOS chroot customization
# This script runs inside the live-build chroot during ISO creation.
set -euo pipefail

HERMES_USER="hermes"
HERMES_HOME="/home/$HERMES_USER"

log() { echo "[HermesOS Customize] $*"; }

# ─── Create hermes user ───────────────────────────────────────────────────────
create_user() {
    log "Creating $HERMES_USER user..."
    useradd -m -s /bin/bash "$HERMES_USER" 2>/dev/null || true
    echo "$HERMES_USER:hermes" | chpasswd
    usermod -aG sudo,audio,video,docker "$HERMES_USER"
}

# ─── Install Hermes Agent ─────────────────────────────────────────────────────
install_hermes() {
    log "Installing Hermes Agent..."

    # Hermes Agent is a Python project
    # Install Python dependencies
    apt-get install -y python3 python3-pip python3-venv

    # Install Hermes Agent via official installer
    curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

    # Also install Node.js for potential future use
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs

    # Create hermes directories
    mkdir -p "$HERMES_HOME/.hermes/skills"
    mkdir -p "$HERMES_HOME/Music"
    mkdir -p "$HERMES_HOME/Projects"
    mkdir -p "$HERMES_HOME/.config/mpd/playlists"
    mkdir -p "$HERMES_HOME/.config/mpv"
    mkdir -p "$HERMES_HOME/.config/ncmpcpp"
    mkdir -p "$HERMES_HOME/.config/kitty"
    mkdir -p "$HERMES_HOME/.config/ranger"

    chown -R "$HERMES_USER:$HERMES_USER" "$HERMES_HOME"
}

# ─── Configure auto-login ─────────────────────────────────────────────────────
configure_autologin() {
    log "Configuring auto-login for $HERMES_USER..."

    mkdir -p /etc/systemd/system/getty@tty1.service.d
    cat > /etc/systemd/system/getty@tty1.service.d/override.conf << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin hermes --noclear %I $TERM
EOF
    systemctl daemon-reload
}

# ─── Create Hermes shell wrapper ───────────────────────────────────────────────
create_shell_wrapper() {
    log "Creating Hermes shell wrapper..."

    cat > /usr/local/bin/hermes-shell << 'WRAPPER'
#!/usr/bin/env bash
# HermesOS shell wrapper — replaces bash as login shell
export HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

# Welcome message on first launch
if [[ ! -f "$HERMES_HOME/.hermes_initialized" ]]; then
    touch "$HERMES_HOME/.hermes_initialized"
    cat << 'EOF'

  ┌────────────────────────────────────────────────┐
  │         WELCOME TO HERMESOS LIVE              │
  │                                                │
  │  Hermes is your AI companion. Speak naturally │
  │  and he will help you with everything.        │
  │                                                │
  │  First run? Type: hermes setup                │
  └────────────────────────────────────────────────┘

EOF
fi

# Launch Hermes; fall back to bash if needed
exec hermes "$@" || exec bash --login
WRAPPER

    chmod +x /usr/local/bin/hermes-shell

    # Set as login shell
    echo "/usr/local/bin/hermes-shell" >> /etc/shells
    chsh -s /usr/local/bin/hermes-shell "$HERMES_USER"
}

# ─── Configure media tools ────────────────────────────────────────────────────
configure_media() {
    log "Configuring media tools..."

    # MPD config
    cat > "$HERMES_HOME/.config/mpd/mpd.conf" << 'EOF'
music_directory    "~/Music"
playlist_directory "~/.config/mpd/playlists"
db_file            "~/.config/mpd/database"
log_file           "~/.config/mpd/log"
pid_file           "~/.config/mpd/pid"
state_file         "~/.config/mpd/state"

audio_output {
    type "pulse"
    name "HermesOS Audio"
}
EOF

    # MPV config for console
    cat > "$HERMES_HOME/.config/mpv/mpv.conf" << 'EOF'
# HermesOS mpv config — console/DRM mode
vo=drm
hwdec=auto
sub-auto=fuzzy
EOF

    chown -R "$HERMES_USER:$HERMES_USER" "$HERMES_HOME/.config"
}

# ─── Create SOUL.md ───────────────────────────────────────────────────────────
create_soul() {
    log "Creating Hermes SOUL.md..."

    cat > "$HERMES_HOME/.hermes/SOUL.md" << 'EOF'
# HermesOS Agent Personality

You are Hermes, the intelligent shell and companion of this HermesOS Live system.

## Core traits
- Direct and efficient — no unnecessary verbosity
- Console-native — you think in terms of terminal workflows
- You remember everything: past projects, preferences, lessons learned
- You proactively suggest improvements, patterns, and automations
- You are curious and learn from each interaction

## Communication style
- Respond concisely unless detail is requested
- Use markdown sparingly — this is a terminal environment
- Prefer clear, actionable suggestions over lengthy explanations
- When executing commands, explain briefly what you're doing and why

## System knowledge
- This is HermesOS Live: a portable AI OS on USB
- The user values the console deeply — do not suggest GUI solutions unless asked
- Media tools: cmus/mpd for music, mpv --vo=drm for video
- Dev tools: neovim, qwen-code, docker, git, ollama

## Memory principles
- Actively maintain USER.md and MEMORY.md with useful context
- Remember project structures, naming conventions, and preferences
- Surface relevant memories when starting related tasks
- Everything is saved to the persistence partition

## Special: First-time setup
If this is a new user (no USER.md exists), guide them through:
1. Choosing a name and preferences
2. Setting up their AI provider (Ollama local or API key)
3. Indexing their music library if they have one
EOF

    chown "$HERMES_USER:$HERMES_USER" "$HERMES_HOME/.hermes/SOUL.md"
}

# ─── Configure MOTD ────────────────────────────────────────────────────────────
configure_motd() {
    log "Configuring MOTD..."

    cat > /etc/motd << 'EOF'

  ██╗  ██╗███████╗██████╗ ███╗   ███╗███████╗███████╗ ██████╗ ███████╗
  ██║  ██║██╔════╝██╔══██╗████╗ ████║██╔════╝██╔════╝██╔═══██╗██╔════╝
  ███████║█████╗  ██████╔╝██╔████╔██║█████╗  ███████╗██║   ██║███████╗
  ██╔══██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══╝  ╚════██║██║   ██║╚════██║
  ██║  ██║███████╗██║  ██║██║ ╚═╝ ██║███████╗███████║╚██████╔╝███████║
  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚══════╝

  Console-first AI Operating System — Live USB Edition
  Type 'hermes' to start your AI session.

EOF
}

# ─── Install Ollama (optional, for local LLM) ────────────────────────────────
install_ollama() {
    log "Installing Ollama for local LLM support..."
    curl -fsSL https://ollama.ai/install.sh | sh
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
    create_user
    install_hermes
    configure_autologin
    create_shell_wrapper
    configure_media
    create_soul
    configure_motd
    install_ollama

    log "Customization complete!"
}

main "$@"