# HermesOS Project Context

## Project Overview

**HermesOS** is a console-first, AI-powered operating system concept based on Ubuntu Server. It replaces traditional graphical interfaces with Hermes Agent (from Nous Research) as the primary user interface. The philosophy is inspired by MS-DOS 3.3–6.22 — keyboard-only, text-based, ultra-direct computing — enhanced with modern AI capabilities.

**Core Philosophy:**
- **Console-first**: No X server by default; the console IS the OS
- **Agent-first**: Hermes is the primary interface, not just a tool
- **Persistent memory**: The agent learns user habits via USER.md, MEMORY.md, SOUL.md
- **Minimalist**: Every installed tool has a purpose; nothing superfluous

## Project Type

This is a **documentation and configuration repository**, not a traditional code project. It contains:
- Shell scripts for automated installation
- Configuration files for various tools (mpd, mpv, kitty, ranger, etc.)
- Documentation in French
- Hardware-specific notes
- Example "skills" for Hermes Agent

## Key Files

| File | Purpose |
|------|---------|
| `README.md` | Main project documentation (French) |
| `install-hermes-os.sh` | Main installation script for Ubuntu/Debian |
| `config.yaml` | Hermes Agent configuration template |
| `installation.md` | Detailed installation guide |
| `skills-examples.md` | Examples of Hermes skills |
| `asus-vivobook.md` | Hardware-specific notes for ASUS Vivobook |
| `CONTRIBUTING.md` | Contribution guidelines |

## Installation

The project is designed to be installed via a one-liner curl command:

```bash
curl -fsSL https://raw.githubusercontent.com/nikodindon/HermesOS/main/scripts/install-hermes-os.sh | bash
```

**Requirements:**
- Ubuntu Server 24.04 LTS or Debian 12
- 3GB+ disk space (8GB recommended)
- 4GB+ RAM (8GB for local LLM models)
- No GUI environment (console-only)

## Key Technologies

- **Hermes Agent**: AI agent from Nous Research (npm package)
- **Ollama**: Local LLM runtime for privacy-first AI
- **Media tools**: cmus, mpd, ncmpcpp (music); mpv --vo=drm (video in console)
- **Terminal**: Kitty (GPU-accelerated) or framebuffer tty
- **Dev tools**: Neovim, Docker, Git, Node.js

## Configuration Structure

The expected configuration hierarchy (after installation):

```
~/.hermes/
├── config.yaml      # Hermes Agent configuration
├── SOUL.md          # Agent personality/identity
├── USER.md          # User preferences (auto-generated)
├── MEMORY.md        # Cross-session memory (auto-generated)
└── skills/          # Auto-created skills directory
```

## Skills System

Hermes automatically creates "skills" (reusable procedures) after complex tasks. Skills are stored as Markdown files in `~/.hermes/skills/` and contain:
- Context for when to use the skill
- Step-by-step procedure
- Verification checks
- Known pitfalls

## Development Conventions

When contributing to this project:

1. **Scripts**: Must start with `set -euo pipefail` and be well-commented
2. **Comments**: English for code comments, French for user-facing documentation
3. **Testing**: Test scripts on a fresh installation before submitting
4. **Hardware notes**: Add to `docs/hardware/<machine>.md` with tested configurations

## Target Audience

- Linux enthusiasts who miss the simplicity of MS-DOS
- Developers who prefer terminal-centric workflows
- Users seeking a privacy-first AI computing experience
- Minimalist computing advocates

## Project Status

Current version: **0.1.0** (MVP phase)

The project is in early development with a working installation script and basic documentation. See `README.md` for the full roadmap.