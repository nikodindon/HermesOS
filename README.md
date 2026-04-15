# HermesOS

> *"Retrouver la magie pure de MS-DOS 3.3–6.22, mais en 2026 avec un agent IA qui grandit vraiment avec toi."*

**HermesOS** est un système d'exploitation minimaliste basé sur Ubuntu Server, où [Hermes Agent](https://github.com/NousResearch/hermes-agent) (Nous Research) remplace complètement l'interface graphique traditionnelle. Au démarrage, tu arrives directement dans une **console magnifique en 1080p**. Pas de GNOME, pas de KDE, pas de bureau. Tu parles à Hermes en langage naturel, et il devient ton shell, ton assistant, ton gestionnaire de fichiers, ton lecteur média, ton développeur, et surtout **ton partenaire qui apprend avec toi** au fil du temps.

C'est le retour aux sources : clavier uniquement, tout en texte, ultra direct. Comme `dir`, `cd` et `edit` d'antan. Mais cette fois, l'ordinateur **pense avec toi**.

---

## L'Expérience HermesOS

**Voici ce que nous voulons accomplir. C'est notre premier objectif.**

### 7h32 — Boot instantané

Tu appuies sur power. **3 secondes plus tard**, tu es devant :

```
  ██╗  ██╗███████╗██████╗ ███╗   ███╗███████╗███████╗ ██████╗ ███████╗
  ██║  ██║██╔════╝██╔══██╗████╗ ████║██╔════╝██╔════╝██╔═══██╗██╔════╝
  ███████║█████╗  ██████╔╝██╔████╔██║█████╗  ███████╗██║   ██║███████╗
  ██╔══██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══╝  ╚════██║██║   ██║╚════██║
  ██║  ██║███████╗██║  ██║██║ ╚═╝ ██║███████╗███████║╚██████╔╝███████║
  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚══════╝

  hermes@hermes-os ~ $ 
```

Pas de login. Pas de "Démarrage de Windows". Pas de mise à jour forcée. Juste **toi et ta machine**.

### 7h33 — Première interaction

```
hermes, bonjour. Résume-moi ma journée.
```

Hermes répond :

```
Salut. Tu as 3 commits en attente sur le projet api-rest.
Ta batterie est à 94%. 
Tu as écouté 47 morceaux cette semaine, beaucoup de Stevie Ray Vaughan.
Hier tu travaillais sur le fichier auth.py, tu avais laissé un TODO ligne 142.
Veux-tu que je l'ouvre ?
```

```
oui, ouvre-le
```

Hermes lance Neovim directement sur la ligne. Tu continues ton code.

### 8h15 — Musique de fond

```
hermes, lance l'album Texas Flood
```

```
[mpd] Ajouté 10 pistes à la queue
[mpd] Lecture: Stevie Ray Vaughan - Love Struck Baby
```

La musique démarre. Pas de Spotify. Pas de publicités. **Tes fichiers. Ta bibliothèque.** Le cover de l'album s'affiche en ASCII art grâce à chafa.

### 9h00 — Développement

```
hermes, crée une API FastAPI avec auth JWT et tests
```

Hermes :

```
Je vais créer:
  ~/Projects/api-auth/
  ├── app/
  │   ├── main.py
  │   ├── auth.py
  │   └── models.py
  ├── tests/
  │   └── test_auth.py
  ├── requirements.txt
  └── Dockerfile

Confirme ? [y/n]
```

```
y
```

```
[+] Création de la structure...
[+] main.py avec endpoints /login, /register, /me
[+] auth.py avec JWT handling
[+] test_auth.py avec pytest fixtures
[+] Dockerfile multi-stage
[+] requirements.txt

Projet prêt. Lancer docker compose up ?
```

```
oui et lance les tests
```

```
[docker] Building...
[pytest] 12 tests passed ✓

API dispo sur http://localhost:8000
```

### 11h30 — Un problème

```
hermes, j'ai une erreur sur le endpoint /login, erreur 500
```

Hermes lit les logs, analyse le code :

```
Problème identifié: app/auth.py:47
Le token expire dans -1 seconde (timestamp incorrect)

Correction suggérée:
  - expires_delta=timedelta(hours=1)  # pas minutes=-1

Appliquer ? [y/n]
```

```
y
```

```
Corrigé. Redémarre le conteneur ? [y/n]
```

### 14h00 — Pause vidéo

```
hermes, joue le dernier épisode de la série que je regardais
```

```
Dernière session: Severance S02E07 - 42:15 / 58:00
Reprendre ? [y/n]
```

```
y
```

mpv démarre **en console** avec `--vo=drm`. 1080p. Pas de X. Pas de GUI. Juste la vidéo, les sous titres, et toi.

Contrôle vocal :
```
hermes, pause
hermes, avance de 2 minutes
hermes, sous-titres en français
```

### 16h00 — Maintenance système

```
hermes, état du système ?
```

```
┌─────────────────────────────────────┐
│ CPU:     12% (idle)                 │
│ RAM:     2.1 / 8 GB                 │
│ Disk:    45 / 250 GB                │
│ Temp:    48°C                       │
│ Battery: 67% (est. 3h45 restantes) │
│ Uptime:  8h 27m                     │
└─────────────────────────────────────┘

3 mises à jour disponibles (linux-firmware, neovim, mpd)
Mettre à jour ? [y/n]
```

```
plus tard
```

```
Ok. Je te rappellerai ce soir.
```

### 19h00 — Backup automatique

Hermes a créé un skill "daily-backup" après avoir remarqué que tu sauvegardes toujours à 19h :

```
[auto] Backup en cours...
  ~/Projects → /backup/projects-2026-04-15.tar.gz (234 MB)
  ~/.hermes → /backup/hermes-memory-2026-04-15.tar.gz (12 MB)

Rotation: suppression des backups de plus de 7 jours.
Terminé ✓
```

### 21h00 — Fin de journée

```
hermes, bonne nuit. Sauvegarde ma session.
```

```
Session "mercredi-dev" sauvegardée.
  - Projet actif: api-auth
  - Fichier ouvert: app/auth.py:47
  - Musique: SRV - Lenny (pause à 2:34)
  - 3 nouveaux skills appris aujourd'hui

À demain. Je serai là.
```

Tu éteins. **5 secondes.**

---

## Pourquoi HermesOS ?

| Windows / macOS | HermesOS |
|-----------------|----------|
| Click → Click → Click | `hermes, fais ça` |
| GUI lourd, 2 Go RAM au repos | Console directe, 200 Mo |
| "Mise à jour et redémarrage" (30 min) | Boot en 3 secondes |
| Spotify avec publicités | Ta musique, tes fichiers |
| VS Code (2 Go RAM) | Neovim (50 Mo) |
| Oublie ce que tu faisais | Hermes se souvient de tout |
| Recherche Google → Stack Overflow | Hermes comprend ton code |
| 47 processus en arrière plan | 0 superflu |
| Souris nécessaire | Clavier uniquement |

---

## Philosophie

**Console first** : aucun serveur X ne tourne par défaut. La console EST l'OS.

**Agent first** : Hermes n'est pas un outil parmi d'autres, c'est l'interface principale.

**Persistant** : grâce à la mémoire de Hermes (USER.md, MEMORY.md, SOUL.md), le système apprend vraiment tes habitudes, tes projets, ton style de travail.

**Portable** : la version Live USB persistante te permet d'emporter ton "cerveau" numérique partout.

**Minimaliste** : chaque outil installé a une raison d'être. Rien de superflu.

**Ouvert** : tout est déclaratif, versionné, modifiable. Pas de magie noire.

---

## Vision : Une IA Portable dans ta Poche

**HermesOS ne sera pas seulement installable, il sera bootable.**

L'objectif final est de produire une **ISO Live USB persistante** que tu peux :

* **Booter sur n'importe quel PC** : insère la clé, démarre, et HermesOS apparaît
* **Emporter ton cerveau partout** : skills, mémoire (USER.md, MEMORY.md), bibliothèque musicale, projets, configs. Tout persiste sur la clé.
* **Installer si tu veux** : comme n'importe quelle distro Linux, tu peux choisir d'installer HermesOS sur le disque dur

C'est un **AI Companion portable**. Ton agent qui te connaît vraiment, que tu peux brancher sur n'importe quelle machine.

```
┌─────────────────────────────────────────────────────────────┐
│                    HERMESOS LIVE USB                        │
├─────────────────────────────────────────────────────────────┤
│  Ta musique indexée                                          │
│  Ta mémoire (ce que Hermes a appris sur toi)                │
│  Tes skills personnalisés                                   │
│  Tes projets en cours                                        │
│  Tes configs (neovim, mpd, aliases...)                       │
├─────────────────────────────────────────────────────────────┤
│  Boot sur n'importe quel PC → Ton environnement t'attend     │
└─────────────────────────────────────────────────────────────┘
```

---

## Architecture

```
hermes-os/
├── docs/
│   ├── installation.md          # Guide d'installation complet
│   ├── configuration.md         # Personnalisation de Hermes et des outils
│   ├── skills-examples.md       # Exemples de skills utiles
│   ├── media-setup.md           # Configuration cmus / mpd / mpv
│   └── hardware/
│       └── asus-vivobook.md     # Notes spécifiques ASUS Vivobook
├── iso-builder/                 # Construction de l'ISO Live USB
│   ├── config/                  # seed, packages, casper, grub, persistence
│   ├── scripts/
│   │   ├── build-iso.sh         # Script principal de génération ISO
│   │   └── customize-chroot.sh  # Personnalisation du système live
│   └── README-iso.md            # Documentation build ISO
├── scripts/
│   ├── install-hermes-os.sh     # Script d'installation principal (curl | bash)
│   ├── setup-console.sh         # Configuration console 1080p / Kitty
│   ├── setup-media.sh           # Installation et config cmus + mpd + mpv
│   ├── setup-hermes.sh          # Installation et configuration Hermes Agent
│   └── systemd/
│       ├── hermes-agent.service
│       ├── hermes-gateway.service
│       └── mpd.service
├── config/
│   ├── hermes/
│   │   ├── config.yaml          # Config principale de Hermes
│   │   └── SOUL.md              # Personnalité / identité de l'agent
│   ├── kitty/
│   │   └── kitty.conf           # Terminal GPU accelerated
│   ├── ncmpcpp/
│   │   └── config               # Interface musique ncurses
│   ├── mpv/
│   │   └── mpv.conf             # Lecture vidéo en console (vo=drm)
│   └── ranger/
│       └── rc.conf              # Gestionnaire de fichiers console
├── overlays/
│   ├── etc/
│   │   └── motd                 # Message d'accueil au boot
│   └── home/
│       └── .bashrc              # Aliases et wrapper Hermes
├── hermes-profiles/
│   ├── dev/                     # Profil développement
│   ├── media/                   # Profil média
│   └── personal/                # Profil usage quotidien
├── .github/
│   ├── workflows/
│   │   └── test-install.yml     # CI : teste le script d'installation
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md
│       └── hardware_support.md
├── LICENSE
├── README.md
└── CONTRIBUTING.md
```

---

## Installation

> Testé sur Ubuntu Server 24.04 LTS. Nécessite une connexion internet et environ 2 Go d'espace libre.

### Option 1 : Installation sur disque (pour adopter HermesOS)

```bash
# Sur une machine fraîche ou une VM
curl -fsSL https://raw.githubusercontent.com/nikodindon/HermesOS/main/install-hermes-os.sh | bash
```

Le script effectue automatiquement :

1. Mise à jour du système et installation des dépendances
2. Configuration de la console 1080p (framebuffer ou Kitty)
3. Auto login sur tty1
4. Installation de Hermes Agent et configuration initiale
5. Setup des outils média (cmus, mpd, mpv)
6. Création du wrapper shell et service systemd
7. Configuration de ranger, neovim et des outils de base

### Option 2 : Live USB Persistante (en développement)

```bash
# Télécharger l'ISO (disponible prochainement)
# Graver sur une clé USB de 8 Go minimum
# Booter dessus et choisir "Live Mode" ou "Install to Disk"
```

**Avantages de la Live USB :**

* Aucune installation requise, boot direct
* Persistance complète : tout est sauvegardé sur la clé
* Portable : emmène ton "cerveau" IA sur n'importe quel PC
* Installable : option d'installation sur disque dur

### Installation manuelle (étape par étape)

Pour les utilisateurs qui préfèrent contrôler chaque étape :

```bash
git clone https://github.com/nikodindon/HermesOS.git
cd HermesOS
bash scripts/setup-console.sh
bash scripts/setup-hermes.sh
bash scripts/setup-media.sh
```

---

## Premiers pas après installation

```
# Lancer Hermes (automatique au boot, mais aussi manuellement)
hermes

# Donner un nom à ta session de travail
/title mon-projet-principal

# Reprendre cette session au prochain démarrage
hermes -c "mon-projet-principal"

# Lister toutes tes sessions
hermes sessions list

# Exemples de commandes naturelles
hermes, indexe ma bibliothèque musicale dans ~/Music
hermes, lance du Stevie Ray Vaughan
hermes, quel est l'état de la batterie ?
hermes, crée un projet Python avec virtualenv et git
hermes, montre-moi les 10 plus gros fichiers dans mon home
```

---

## Roadmap

### Phase 1 — MVP Console Pure (en cours)

* Script `install-hermes-os.sh` complet et testé
* Boot direct dans Hermes (auto login + wrapper shell)
* Musique locale complète (cmus + mpd + indexation automatique)
* Vidéo console (mpv --vo=drm)
* Intégration Qwen Code / Neovim
* Documentation d'installation complète
* Support ASUS Vivobook (notes hardware)

### Phase 2 — Expérience Raffinée (1 mois)

* Thèmes visuels console (Kitty + ncurses personnalisés)
* Gestion intelligente de la bibliothèque média (tags, recherche sémantique)
* Automations avancées (cron intégré dans Hermes)
* Profils multiples (Dev / Personal / Media) avec switch rapide
* Mode Focus (désactive tout sauf l'essentiel)
* Covers d'albums et miniatures vidéo via kitty graphics protocol

### Phase 3 — Live ISO & Distribution Portable (2-3 mois)

* Construction automatisée d'une ISO bootable (live build)
* Support persistence USB complète (casper-rw / overlay)
* Premier boot wizard (configuration modèle, clé API, nom utilisateur)
* Image hybride : bootable en live + installable sur disque
* Détection hardware automatique (Wi Fi, GPU, audio)
* Script `build-iso.sh` pour régénérer l'ISO facilement
* Tests sur hardware varié (laptops, desktops, mini PC)

### Phase 4 — Intelligence et Communauté (2-3 mois)

* Skill store communautaire (partage de skills Hermes)
* Support hardware étendu (Framework Laptop, Raspberry Pi, mini PC)
* Intégration voix optionnelle (Whisper STT + TTS en console)
* Mode multi machine (contrôle de plusieurs PC depuis Hermes)
* Documentation vidéo et tutoriels

### Phase 5 — Ambitions Long Terme

* Version "HermesOS Light" pour vieux matériel (512 Mo RAM)
* Support Raspberry Pi / mini PC (serveur domestique)
* Live USB multi architectures (x86_64 + ARM)
* Intégration avec d'autres agents (chaîne OpenClaw → Hermes)
* Image cloud (VPS pré configuré HermesOS)

---

## Matériel testé

| Matériel | Statut | Notes |
|----------|--------|-------|
| ASUS Vivobook (série S) | ✅ Principal | Configuration de référence |
| VM VirtualBox / VMware | 🧪 En test | Pour développement du projet |

Tu as testé sur un autre matériel ? Ouvre une issue avec le template "hardware support" !

---

## Contribuer

Ce projet est né d'une conversation passionnée sur l'idée de retrouver la pureté de MS DOS, mais en 2026 avec un agent IA.

**Toutes les contributions sont bienvenues :**

* Scripts d'installation pour nouveau matériel
* Configurations d'outils console supplémentaires
* Skills Hermes utiles à partager
* Documentation et traductions
* Rapports de bugs et retours d'expérience
* **Aide sur l'ISO Live USB** : c'est un gros chantier !

Consulte [CONTRIBUTING.md](CONTRIBUTING.md) pour commencer.

---

## Inspiration

* **MS-DOS 3.3 → 6.22** : la nostalgie pure, le clavier comme seul outil
* **Plan 9 / Acme** : tout est texte, tout est composable
* **Hermes Agent (Nous Research)** : l'IA qui grandit vraiment avec toi
* **Suckless philosophy** : logiciels simples, clairs, audacieux
* **Tails OS** : pour l'inspiration Live USB persistante

> *"The computer should be an extension of your mind, not a series of menus."*

---

## Licence

MIT — voir [LICENSE](LICENSE)

---

Créé avec ❤️ par [nikodindon](https://github.com/nikodindon) — Avril 2026.

Ce projet n'est pas qu'un OS. C'est une déclaration : on peut encore utiliser un ordinateur comme en 1995, mais avec l'intelligence de 2026.

**Prêt à booter dans le futur ? Bienvenue dans HermesOS.**