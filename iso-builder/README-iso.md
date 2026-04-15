# HermesOS ISO Builder

This directory contains everything needed to build the HermesOS Live ISO.

## Requirements

- **Host OS**: Ubuntu 24.04 LTS (recommended) or Debian 12+
- **Disk space**: 10GB+ free
- **RAM**: 4GB+ recommended
- **Root access**: Required for building

## Quick Start

```bash
# Install dependencies
sudo apt install live-build debian-archive-keyring ubuntu-keyring

# Build the ISO
cd iso-builder/scripts
sudo ./build-iso.sh build

# Output: hermes-os-0.1.0-helios-amd64.iso
```

## Directory Structure

```
iso-builder/
├── config/
│   ├── package-lists/
│   │   └── hermes.list.chroot    # Packages to install
│   └── includes.chroot/          # Files to copy into the ISO
│       ├── etc/
│       │   └── hermes/           # System configs
│       └── home/hermes/.hermes/  # Hermes user configs
├── scripts/
│   ├── build-iso.sh              # Main build script
│   └── customize-chroot.sh      # Customization hook
└── README-iso.md                # This file
```

## Build Commands

```bash
# Standard build
sudo ./build-iso.sh build

# Clean and rebuild from scratch
sudo ./build-iso.sh full

# Clean build artifacts only
sudo ./build-iso.sh clean

# Show help
./build-iso.sh help
```

## Customization

### Adding Packages

Edit `config/package-lists/hermes.list.chroot` and add package names (one per line).

### Adding Configuration Files

Place files in `config/includes.chroot/` mirroring the target filesystem:

```
config/includes.chroot/
├── etc/
│   ├── motd                     → /etc/motd
│   └── hermes/config.yaml       → /etc/hermes/config.yaml
└── home/hermes/
    └── .bashrc                  → /home/hermes/.bashrc
```

### Customizing the Build Process

Edit `scripts/customize-chroot.sh` to add custom logic that runs during the build.

## Persistence

The ISO is configured with persistence support. When writing to USB:

1. **Using Ventoy (recommended)**:
   - Install Ventoy on USB
   - Copy ISO to USB
   - Create a persistence.dat file
   - Boot with persistence

2. **Using dd + manual partition**:
   ```bash
   # Write ISO
   sudo dd if=hermes-os-*.iso of=/dev/sdX bs=4M status=progress && sync

   # Create persistence partition (requires repartitioning)
   # See: https://live-team.pages.debian.net/live-manual/html/live-manual.en.html#555
   ```

## Testing the ISO

### In QEMU (recommended for testing)

```bash
# Install QEMU
sudo apt install qemu-system-x86 qemu-utils

# Create a virtual disk for persistence (optional)
qemu-img create -f raw persistence.img 4G

# Boot the ISO
qemu-system-x86_64 \
    -m 4G \
    -cdrom hermes-os-*.iso \
    -drive file=persistence.img,format=raw \
    -boot d \
    -enable-kvm
```

### In VirtualBox

1. Create new VM (Linux, Ubuntu 64-bit)
2. Mount ISO as live CD
3. Boot and test

## Release Checklist

- [ ] Update `HERMES_VERSION` in `build-iso.sh`
- [ ] Update `README.md` roadmap
- [ ] Test ISO in QEMU
- [ ] Test ISO on real hardware (USB boot)
- [ ] Test persistence functionality
- [ ] Test installation to disk
- [ ] Check all packages are included
- [ ] Verify hardware detection (Wi-Fi, audio, etc.)

## Troubleshooting

### Build fails

```bash
# Check build log
cat build/build.log

# Clean and retry
sudo ./build-iso.sh full
```

### ISO too large

- Remove unnecessary packages from `hermes.list.chroot`
- Consider splitting into "full" and "minimal" variants

### Boot issues

- Ensure UEFI support is enabled in BIOS
- Try legacy boot mode if UEFI fails
- Check ISO integrity: `sha256sum hermes-os-*.iso`

## Resources

- [live-build manual](https://live-team.pages.debian.net/live-manual/)
- [Debian Live Wiki](https://wiki.debian.org/DebianLive)
- [Ubuntu Live ISO customization](https://help.ubuntu.com/community/LiveCDCustomization)