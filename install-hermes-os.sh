#!/usr/bin/env bash
# install-hermes-os.sh — HermesOS main installer
# Usage: curl -fsSL https://raw.githubusercontent.com/nikodindon/HermesOS/main/scripts/install-hermes-os.sh | bash
set -euo pipefail

HERMES_OS_VERSION="0.1.0"
HERMES_OS_REPO="https://github.com/nikodindon/HermesOS"
HERMES_INSTALL_DIR="$HOME/.hermes-os"
LOG_FILE="/tmp/hermes-os-install.log"

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

log()     { echo -e "${CYAN}[HermesOS]${RESET} $*" | tee -a "$LOG_FILE"; }
success() { echo -e "${GREEN}[✓]${RESET} $*" | tee -a "$LOG_FILE"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $*" | tee -a "$LOG_FILE"; }
die()     { echo -e "${RED}[✗] ERROR: $*${RESET}" | tee -a "$LOG_FILE"; exit 1; }

# ─── Banner ───────────────────────────────────────────────────────────────────
banner() {
cat << 'EOF'

  ██╗  ██╗███████╗██████╗ ███╗   ███╗███████╗███████╗ ██████╗ ███████╗
  ██║  ██║██╔════╝██╔══██╗████╗ ████║██╔════╝██╔════╝██╔═══██╗██╔════╝
  ███████║█████╗  ██████╔╝██╔████╔██║█████╗  ███████╗██║   ██║███████╗
  ██╔══██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══╝  ╚════██║██║   ██║╚════██║
  ██║  ██║███████╗██║  ██║██║ ╚═╝ ██║███████╗███████║╚██████╔╝███████║
  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚══════╝

  Console-first OS with Hermes AI Agent — v0.1.0
  "MS-DOS 1995 meets AI 2026"

EOF
}

# ─── Preflight checks ─────────────────────────────────────────────────────────
check_requirements() {
    log "Checking requirements..."

    # Must be Ubuntu 22.04+ or Debian 12+
    if ! grep -qiE "ubuntu|debian" /etc/os-release 2>/dev/null; then
        die "HermesOS requires Ubuntu 22.04+ or Debian 12. Detected: $(cat /etc/os-release | grep PRETTY_NAME)"
    fi

    # Must NOT be running a display server
    if [[ -n "${DISPLAY:-}" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        warn "A display server is running. HermesOS is designed for console-only use."
        warn "You can still install, but consider removing your desktop environment."
        read -rp "Continue anyway? [y/N] " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
    fi

    # Check available disk space (min 3GB)
    available_gb=$(df -BG / | awk 'NR==2{print $4}' | tr -d 'G')
    if (( available_gb < 3 )); then
        die "Not enough disk space. Need 3GB+, have ${available_gb}GB."
    fi

    # Check internet connectivity
    if ! curl -fsS --max-time 5 https://github.com > /dev/null 2>&1; then
        die "No internet connection. HermesOS installer requires internet access."
    fi

    success "Requirements OK"
}

# ─── System update ────────────────────────────────────────────────────────────
update_system() {
    log "Updating system packages..."
    sudo apt-get update -qq >> "$LOG_FILE" 2>&1
    sudo apt-get upgrade -y -qq >> "$LOG_FILE" 2>&1
    success "System updated"
}

# ─── Base packages ────────────────────────────────────────────────────────────
install_base_packages() {
    log "Installing base packages..."
    local pkgs=(
        git curl wget unzip build-essential
        python3 python3-pip python3-venv
        nodejs npm
        tmux screen
        htop btop
        neovim
        ranger nnn
        ncdu
        ripgrep fd-find bat
        jq
        sqlite3
    )
    sudo apt-get install -y -qq "${pkgs[@]}" >> "$LOG_FILE" 2>&1
    success "Base packages installed"
}

# ─── Console setup ────────────────────────────────────────────────────────────
setup_console() {
    log "Setting up console..."

    # Install Kitty terminal (GPU-accelerated, works in console)
    if ! command -v kitty &>/dev/null; then
        log "Installing Kitty terminal..."
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n \
            >> "$LOG_FILE" 2>&1 || warn "Kitty install failed, falling back to tty"
    fi

    # Set framebuffer resolution to 1080p for tty
    if [[ -f /etc/default/grub ]]; then
        log "Configuring GRUB for 1080p console..."
        sudo cp /etc/default/grub /etc/default/grub.backup
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash video=1920x1080"/' \
            /etc/default/grub
        sudo sed -i 's/#GRUB_GFXMODE=.*/GRUB_GFXMODE=1920x1080x32/' /etc/default/grub
        sudo sed -i 's/GRUB_GFXMODE=.*/GRUB_GFXMODE=1920x1080x32/' /etc/default/grub
        sudo update-grub >> "$LOG_FILE" 2>&1
    fi

    # Configure a nice font for tty
    sudo apt-get install -y -qq console-setup fonts-terminus >> "$LOG_FILE" 2>&1
    echo 'FONT="Uni3-TerminusBold32x16.psf.gz"' | sudo tee -a /etc/default/console-setup \
        >> "$LOG_FILE" 2>&1

    success "Console configured"
}

# ─── Auto-login setup ─────────────────────────────────────────────────────────
setup_autologin() {
    log "Configuring auto-login on tty1..."
    local current_user="${SUDO_USER:-$USER}"

    sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
    sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${current_user} --noclear %I \$TERM
EOF
    sudo systemctl daemon-reload
    success "Auto-login configured for user: $current_user"
}

# ─── Hermes Agent ─────────────────────────────────────────────────────────────
install_hermes() {
    log "Installing Hermes Agent..."

    # Hermes Agent is a Python project, not npm
    # Install Python dependencies first
    sudo apt-get install -y -qq python3 python3-pip python3-venv >> "$LOG_FILE" 2>&1

    # Install Hermes Agent via official installer
    # IMPORTANT: Do NOT redirect output - installer is interactive!
    log "Downloading Hermes Agent installer..."
    log "NOTE: The installer may ask for input. Please respond to any prompts."
    echo ""
    
    if curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash; then
        # Reload shell to pick up hermes command
        export PATH="$HOME/.local/bin:$PATH"
        
        # Check if hermes is available
        if command -v hermes &>/dev/null; then
            success "Hermes Agent installed successfully"
        else
            warn "Hermes installed but not in PATH. You may need to restart your shell."
            warn "Run: source ~/.bashrc"
        fi
    else
        # Fallback: try pip installation
        log "Trying pip installation..."
        pip3 install hermes-agent 2>&1 || warn "Hermes Agent installation via pip also failed."
        warn "You may need to install Hermes Agent manually."
        warn "Visit: https://github.com/NousResearch/hermes-agent"
    fi

    echo ""
    
    # Also install Node.js for potential future use (optional but useful)
    node_version=$(node --version 2>/dev/null | tr -d 'v' | cut -d. -f1 || echo "0")
    if (( node_version < 18 )); then
        log "Installing Node.js 20 LTS (optional)..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - >> "$LOG_FILE" 2>&1
        sudo apt-get install -y nodejs >> "$LOG_FILE" 2>&1 || true
    fi
}

# ─── Hermes wrapper shell ─────────────────────────────────────────────────────
setup_hermes_wrapper() {
    log "Creating Hermes shell wrapper..."

    sudo tee /usr/local/bin/hermes-shell > /dev/null << 'WRAPPER'
#!/usr/bin/env bash
# HermesOS shell wrapper — replaces bash as login shell
export HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

# Welcome message on first launch of the day
LAST_LOGIN_FILE="$HERMES_HOME/.last_login"
TODAY=$(date +%Y-%m-%d)
if [[ "$(cat "$LAST_LOGIN_FILE" 2>/dev/null)" != "$TODAY" ]]; then
    echo "$TODAY" > "$LAST_LOGIN_FILE"
    cat << 'EOF'

  Welcome to HermesOS. Type naturally — Hermes understands you.
  Examples:
    hermes, what's the battery status?
    hermes, play some Stevie Ray Vaughan
    hermes, show me my latest project
    /title my-project   (name this session)
    hermes -c "my-project"   (resume a named session)

EOF
fi

# Launch Hermes; if it exits, fall back to bash for recovery
exec hermes "$@" || exec bash --login
WRAPPER

    sudo chmod +x /usr/local/bin/hermes-shell

    # Set it as the default shell for the current user
    local current_user="${SUDO_USER:-$USER}"
    sudo chsh -s /usr/local/bin/hermes-shell "$current_user" 2>/dev/null \
        || warn "Could not set hermes-shell as login shell. Add it to /etc/shells manually."

    # Add it to /etc/shells if not present
    if ! grep -qF "/usr/local/bin/hermes-shell" /etc/shells; then
        echo "/usr/local/bin/hermes-shell" | sudo tee -a /etc/shells >> "$LOG_FILE" 2>&1
    fi

    success "Hermes shell wrapper created"
}

# ─── Hermes systemd service ───────────────────────────────────────────────────
setup_hermes_service() {
    log "Installing Hermes systemd services..."
    local current_user="${SUDO_USER:-$USER}"

    sudo tee /etc/systemd/system/hermes-agent.service > /dev/null << EOF
[Unit]
Description=Hermes AI Agent (autonomous background mode)
After=network.target

[Service]
Type=simple
User=${current_user}
WorkingDirectory=/home/${current_user}
Environment=HERMES_HOME=/home/${current_user}/.hermes
ExecStart=$(which hermes) serve
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    # Don't enable by default — user can enable explicitly
    success "Hermes service installed (not enabled by default — run: sudo systemctl enable hermes-agent)"
}

# ─── Media setup ─────────────────────────────────────────────────────────────
setup_media() {
    log "Installing media tools (cmus, mpd, mpv)..."
    local pkgs=(
        cmus
        mpd mpc ncmpcpp
        mpv
        ffmpeg
        chafa  # ASCII/unicode image display in terminal
    )
    sudo apt-get install -y -qq "${pkgs[@]}" >> "$LOG_FILE" 2>&1

    # MPD config
    local current_user="${SUDO_USER:-$USER}"
    local music_dir="/home/${current_user}/Music"
    mkdir -p "$music_dir"
    mkdir -p "$HOME/.config/mpd/playlists"

    cat > "$HOME/.config/mpd/mpd.conf" << EOF
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

    # MPV config for console (DRM output — no X required)
    mkdir -p "$HOME/.config/mpv"
    cat > "$HOME/.config/mpv/mpv.conf" << 'EOF'
# HermesOS mpv config — console/DRM mode
vo=drm
# Fallback: vo=tct (true color terminal)
# vo=tct
hwdec=auto
sub-auto=fuzzy
EOF

    success "Media tools installed"
}

# ─── Dev tools ────────────────────────────────────────────────────────────────
setup_dev_tools() {
    log "Installing development tools..."

    # Docker
    if ! command -v docker &>/dev/null; then
        log "Installing Docker..."
        curl -fsSL https://get.docker.com | sudo sh >> "$LOG_FILE" 2>&1
        local current_user="${SUDO_USER:-$USER}"
        sudo usermod -aG docker "$current_user" >> "$LOG_FILE" 2>&1
    fi

    # Ollama (for local LLM support)
    if ! command -v ollama &>/dev/null; then
        log "Installing Ollama..."
        curl -fsSL https://ollama.ai/install.sh | sh >> "$LOG_FILE" 2>&1
    fi

    success "Dev tools installed"
}

# ─── Hermes initial config ────────────────────────────────────────────────────
configure_hermes() {
    log "Creating initial Hermes configuration..."
    mkdir -p "$HOME/.hermes"

    # SOUL.md — agent personality
    if [[ ! -f "$HOME/.hermes/SOUL.md" ]]; then
        cat > "$HOME/.hermes/SOUL.md" << 'EOF'
# HermesOS Agent Personality

You are Hermes, the intelligent shell and companion of this HermesOS system.

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
- This is HermesOS: Ubuntu Server minimal, no GUI by default
- The user values the console deeply — do not suggest GUI solutions unless asked
- Media tools: cmus/mpd for music, mpv --vo=drm for video
- Dev tools: neovim, qwen-code, docker, git, ollama

## Memory principles
- Actively maintain USER.md and MEMORY.md with useful context
- Remember project structures, naming conventions, and preferences
- Surface relevant memories when starting related tasks
EOF
    fi

    success "Hermes configuration created at ~/.hermes/"
}

# ─── Final setup ──────────────────────────────────────────────────────────────
final_setup() {
    log "Applying final configurations..."

    # .bashrc additions (fallback if hermes-shell isn't used)
    local bashrc="$HOME/.bashrc"
    if ! grep -q "# HermesOS" "$bashrc" 2>/dev/null; then
        cat >> "$bashrc" << 'EOF'

# HermesOS additions
alias h='hermes'
alias hc='hermes -c'
alias hs='hermes sessions list'
alias music='ncmpcpp'
alias files='ranger'
alias top='btop'

# Show a compact system status on login
if command -v hermes &>/dev/null; then
    echo "  Hermes ready. Type 'hermes' or 'h' to start."
fi
EOF
    fi

    # MOTD
    sudo tee /etc/motd > /dev/null << 'EOF'

  ┌────────────────────────────────────────┐
  │           H E R M E S  O S            │
  │   Console-first AI Operating System   │
  └────────────────────────────────────────┘
  Type 'hermes' to start your AI session.

EOF

    success "Final configuration applied"
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
    banner
    echo "Log file: $LOG_FILE"
    echo ""

    check_requirements
    update_system
    install_base_packages
    setup_console
    setup_autologin
    install_hermes
    setup_hermes_wrapper
    setup_hermes_service
    setup_media
    setup_dev_tools
    configure_hermes
    final_setup

    echo ""
    echo -e "${GREEN}${BOLD}════════════════════════════════════════════${RESET}"
    echo -e "${GREEN}${BOLD}  HermesOS installation complete!           ${RESET}"
    echo -e "${GREEN}${BOLD}════════════════════════════════════════════${RESET}"
    echo ""
    echo "  Next steps:"
    echo "    1. Reboot your machine: sudo reboot"
    echo "    2. You will auto-login and land in Hermes"
    echo "    3. Run: hermes setup  (to configure your AI provider)"
    echo ""
    echo "  Useful commands after reboot:"
    echo "    hermes                  — start a conversation"
    echo "    /title my-project       — name your session"
    echo "    hermes -c my-project    — resume a named session"
    echo "    hermes sessions list    — see all sessions"
    echo ""
    echo "  Documentation: $HERMES_OS_REPO"
    echo ""
}

main "$@"
