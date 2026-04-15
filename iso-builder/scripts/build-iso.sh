#!/usr/bin/env bash
# build-iso.sh — HermesOS Live ISO Builder
# Usage: sudo ./build-iso.sh [options]
#
# This script uses live-build to create a bootable HermesOS ISO
# with persistence support for USB drives.
#
# Requirements:
#   - Ubuntu 24.04 LTS or Debian 12+
#   - live-build package installed
#   - ~10GB free disk space
#   - Root/sudo access
#
set -euo pipefail

# ─── Configuration ────────────────────────────────────────────────────────────
HERMES_VERSION="${HERMES_VERSION:-0.1.0}"
HERMES_CODENAME="helios"
BUILD_DIR="${BUILD_DIR:-$(pwd)/build}"
ISO_NAME="hermes-os-${HERMES_VERSION}-${HERMES_CODENAME}-amd64.iso"
ARCH="amd64"

# Distro base (Ubuntu 24.04 LTS)
LB_DISTRO="ubuntu"
LB_RELEASE="noble"
LB_MIRROR="http://archive.ubuntu.com/ubuntu/"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

log()     { echo -e "${CYAN}[HermesOS Builder]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $*"; }
die()     { echo -e "${RED}[✗] ERROR: $*${RESET}"; exit 1; }

# ─── Preflight checks ─────────────────────────────────────────────────────────
check_requirements() {
    log "Checking build requirements..."

    # Must run as root
    if [[ $EUID -ne 0 ]]; then
        die "This script must be run as root. Use: sudo $0"
    fi

    # Check for live-build
    if ! command -v lb &>/dev/null; then
        log "Installing live-build..."
        apt-get update -qq
        apt-get install -y live-build debian-archive-keyring ubuntu-keyring
    fi

    # Check disk space (need ~10GB)
    available_gb=$(df -BG / | awk 'NR==2{print $4}' | tr -d 'G')
    if (( available_gb < 10 )); then
        die "Not enough disk space. Need 10GB+, have ${available_gb}GB."
    fi

    success "Requirements OK"
}

# ─── Initialize live-build ─────────────────────────────────────────────────────
init_lb() {
    log "Initializing live-build configuration..."

    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    # Initialize if not already done
    if [[ ! -f "config/build" ]]; then
        lb config \
            --architecture "$ARCH" \
            --distribution "$LB_RELEASE" \
            --parent-distribution "$LB_DISTRO" \
            --mirror-bootstrap "$LB_MIRROR" \
            --mirror-chroot "$LB_MIRROR" \
            --mirror-binary "$LB_MIRROR" \
            --archive-areas "main restricted universe multiverse" \
            --apt-recommends false \
            --apt-secure true \
            --bootappend-live "boot=live components persistence persistence-label=hermes-persist" \
            --iso-application "HermesOS" \
            --iso-publisher "nikodindon" \
            --iso-volume "HERMESOS_${HERMES_VERSION}" \
            --binary-images iso-hybrid \
            --memtest none \
            --win32-loader false \
            --backports false \
            --security true \
            --updates true \
            --firmware-binary true \
            --firmware-chroot true
    fi

    success "Live-build initialized"
}

# ─── Copy custom configurations ───────────────────────────────────────────────
copy_configs() {
    log "Copying HermesOS configurations..."

    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    local config_dir="$BUILD_DIR/config"

    # Package lists
    mkdir -p "$config_dir/package-lists"
    if [[ -f "$script_dir/config/package-lists/hermes.list.chroot" ]]; then
        cp "$script_dir/config/package-lists/hermes.list.chroot" "$config_dir/package-lists/"
    fi

    # Includes (files to copy into chroot)
    mkdir -p "$config_dir/includes.chroot"
    if [[ -d "$script_dir/config/includes.chroot" ]]; then
        cp -r "$script_dir/config/includes.chroot/"* "$config_dir/includes.chroot/" 2>/dev/null || true
    fi

    # Hooks (scripts to run during build)
    mkdir -p "$config_dir/hooks/live"
    if [[ -f "$script_dir/scripts/customize-chroot.sh" ]]; then
        cp "$script_dir/scripts/customize-chroot.sh" "$config_dir/hooks/live/0100-customize.hook.chroot"
        chmod +x "$config_dir/hooks/live/0100-customize.hook.chroot"
    fi

    success "Configurations copied"
}

# ─── Build the ISO ─────────────────────────────────────────────────────────────
build_iso() {
    log "Building HermesOS ISO (this may take 30-60 minutes)..."

    cd "$BUILD_DIR"

    # Run live-build
    lb build 2>&1 | tee build.log

    # Find the generated ISO
    local iso_path=$(find . -maxdepth 1 -name "*.iso" -type f | head -1)

    if [[ -n "$iso_path" ]]; then
        # Rename to our convention
        mv "$iso_path" "../$ISO_NAME"
        success "ISO created: ../$ISO_NAME"
        success "Size: $(du -h "../$ISO_NAME" | cut -f1)"
    else
        die "ISO build failed. Check build.log for details."
    fi
}

# ─── Create persistence partition template ─────────────────────────────────────
create_persistence_template() {
    log "Creating persistence partition template..."

    local persist_img="${BUILD_DIR}/../hermes-persistence.img"

    # Create a 4GB ext4 image for persistence
    dd if=/dev/zero of="$persist_img" bs=1M count=4096 2>/dev/null
    mkfs.ext4 -L "hermes-persist" "$persist_img" 2>/dev/null

    success "Persistence template created: $persist_img"
    success "Write this to a USB drive alongside the ISO for persistence"
}

# ─── Clean build artifacts ─────────────────────────────────────────────────────
clean_build() {
    log "Cleaning build artifacts..."
    cd "$BUILD_DIR"
    lb clean
    success "Clean complete"
}

# ─── Help ─────────────────────────────────────────────────────────────────────
show_help() {
    cat << 'EOF'
HermesOS Live ISO Builder

Usage: sudo ./build-iso.sh [command]

Commands:
  build       Build the ISO (default)
  clean       Clean build artifacts
  full        Clean and rebuild from scratch
  help        Show this help message

Environment variables:
  HERMES_VERSION   Version number (default: 0.1.0)
  BUILD_DIR        Build directory (default: ./build)

Examples:
  sudo ./build-iso.sh build
  sudo HERMES_VERSION=0.2.0 ./build-iso.sh full

Output:
  hermes-os-<version>-helios-amd64.iso

Requirements:
  - Ubuntu 24.04 LTS host
  - live-build package
  - 10GB+ disk space
  - Root access

EOF
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
    local command="${1:-build}"

    case "$command" in
        build)
            check_requirements
            init_lb
            copy_configs
            build_iso
            ;;
        clean)
            clean_build
            ;;
        full)
            check_requirements
            clean_build
            init_lb
            copy_configs
            build_iso
            ;;
        help|--help|-h)
            show_help
            exit 0
            ;;
        *)
            die "Unknown command: $command. Use 'help' for usage."
            ;;
    esac
}

main "$@"