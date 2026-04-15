# Installation HermesOS

Ce guide couvre l'installation complète de HermesOS, de la préparation de la machine jusqu'aux premiers pas avec Hermes.

## Prérequis

- Machine physique ou VM avec Ubuntu Server 24.04 LTS (recommandé) ou Debian 12
- 3 Go d'espace disque minimum (8 Go recommandés)
- 4 Go de RAM minimum (8 Go recommandés pour les modèles LLM locaux)
- Connexion internet pour l'installation
- Accès root ou sudo

## Option 1 : Installation automatique

Sur une machine fraîche avec Ubuntu Server 24.04 :

```bash
curl -fsSL https://raw.githubusercontent.com/nikodindon/HermesOS/main/scripts/install-hermes-os.sh | bash
```

Le script installe et configure automatiquement l'ensemble du système. Redémarre ensuite avec `sudo reboot`.

## Option 2 : Installation manuelle étape par étape

### Étape 1 — Préparer Ubuntu Server

Installe Ubuntu Server 24.04 LTS en mode minimal (sans interface graphique). Lors de l'installation, ne sélectionne aucun "snap" supplémentaire.

Une fois installé et connecté :

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget build-essential
```

### Étape 2 — Configurer la console 1080p

Pour une belle console haute résolution, configure GRUB :

```bash
sudo nano /etc/default/grub
# Modifie ces lignes :
# GRUB_CMDLINE_LINUX_DEFAULT="quiet splash video=1920x1080"
# GRUB_GFXMODE=1920x1080x32

sudo update-grub
```

Pour une police agréable en tty :

```bash
sudo apt install -y console-setup fonts-terminus
sudo dpkg-reconfigure console-setup
# Sélectionne : UTF-8 → Latin → Terminus → 32x16 (ou 16x32)
```

### Étape 3 — Configurer l'auto-login

Pour arriver directement dans Hermes au démarrage :

```bash
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin TON_USERNAME --noclear %I \$TERM
EOF
sudo systemctl daemon-reload
```

Remplace `TON_USERNAME` par ton nom d'utilisateur.

### Étape 4 — Installer Node.js et Hermes Agent

```bash
# Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Hermes Agent
npm install -g @nousresearch/hermes-agent

# Vérifie l'installation
hermes --version
```

### Étape 5 — Configurer Hermes

```bash
# Configuration initiale
hermes setup

# Copie la configuration HermesOS
mkdir -p ~/.hermes
cp /chemin/vers/HermesOS/config/hermes/config.yaml ~/.hermes/config.yaml
cp /chemin/vers/HermesOS/config/hermes/SOUL.md ~/.hermes/SOUL.md

# Édite config.yaml pour choisir ton provider LLM
nano ~/.hermes/config.yaml
```

### Étape 6 — Créer le wrapper shell

```bash
sudo cp /chemin/vers/HermesOS/scripts/hermes-shell /usr/local/bin/hermes-shell
sudo chmod +x /usr/local/bin/hermes-shell

# Ajouter aux shells autorisés
echo "/usr/local/bin/hermes-shell" | sudo tee -a /etc/shells

# Définir comme shell de login
chsh -s /usr/local/bin/hermes-shell
```

### Étape 7 — Installer les outils média

```bash
sudo apt install -y cmus mpd mpc ncmpcpp mpv ffmpeg chafa

# Configuration MPD
mkdir -p ~/.config/mpd/playlists
cp /chemin/vers/HermesOS/config/ncmpcpp/config ~/.config/ncmpcpp/config

# Créer le dossier Music
mkdir -p ~/Music
```

### Étape 8 — Redémarrer

```bash
sudo reboot
```

Au redémarrage, tu seras automatiquement connecté et dans Hermes.

## Configuration du provider LLM

### Ollama (local, recommandé)

```bash
# Installer Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Télécharger un modèle (exemples)
ollama pull qwen2.5-coder:32b   # Excellent pour le code
ollama pull llama3.1:70b         # Polyvalent
ollama pull gemma3:27b           # Bon équilibre

# Dans ~/.hermes/config.yaml :
# provider: ollama
# model: qwen2.5-coder:32b
```

### API externe (Anthropic, OpenAI, GLM...)

```bash
# Exporte ta clé API
export ANTHROPIC_API_KEY="sk-..."
# ou
export OPENAI_API_KEY="sk-..."

# Dans ~/.hermes/config.yaml, décommente la section correspondante
```

## Premiers pas

```bash
# Lancer Hermes
hermes

# Nommer ta session
/title ma-premiere-session

# Tester quelques commandes
hermes, dis-moi bonjour et présente-toi
hermes, quel est l'état du système ?
hermes, liste mes fichiers dans le dossier courant

# Indexer ta bibliothèque musicale
hermes, indexe ma bibliothèque dans ~/Music

# Reprendre une session nommée
hermes -c "ma-premiere-session"
```

## Dépannage courant

### Hermes ne démarre pas

```bash
# Vérifier la version Node.js (doit être 18+)
node --version

# Vérifier l'installation de Hermes
which hermes
hermes --version

# Voir les logs
hermes --debug
```

### Pas de son

```bash
# Vérifier que le service audio fonctionne
systemctl --user status pipewire
# ou
pulseaudio --check

# Relancer mpd
systemctl --user restart mpd
mpc status
```

### Résolution console incorrecte

```bash
# Vérifier la résolution actuelle
fbset  # (fbset doit être installé)

# Reconfigurer GRUB et redémarrer
sudo update-grub
sudo reboot
```

## Notes hardware

Consulte `docs/hardware/` pour les notes spécifiques à certaines machines. Si ton matériel n'y est pas, ouvre une issue !
