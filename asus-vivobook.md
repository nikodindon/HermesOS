# HermesOS sur ASUS Vivobook

Notes de compatibilité et configurations spécifiques pour les laptops ASUS Vivobook.

> **Testé sur :** ASUS Vivobook S series (contribution bienvenue pour d'autres modèles)

## Points d'attention

### Son
Le codec audio Realtek fonctionne bien avec ALSA et PulseAudio/Pipewire. Si tu n'as pas de son après installation :

```bash
# Vérifier les modules audio chargés
lsmod | grep snd

# Si le codec n'est pas reconnu automatiquement
echo "options snd-hda-intel model=asus" | sudo tee /etc/modprobe.d/alsa.conf
sudo reboot
```

### Batterie et gestion de l'énergie
Pour maximiser l'autonomie en mode console :

```bash
sudo apt install -y tlp tlp-rdw
sudo tlp start
sudo systemctl enable tlp

# Vérifier l'état
tlp-stat -b
```

Hermes peut surveiller la batterie automatiquement :
```
hermes, surveille la batterie et préviens-moi si elle passe sous 20%
```

### Touchpad
En mode console pur, le touchpad n'est pas nécessaire. Si tu lances X avec i3, installe :

```bash
sudo apt install -y xserver-xorg-input-synaptics
```

### Écran 1080p
La plupart des modèles Vivobook récents ont un écran 1080p natif. La configuration GRUB incluse dans `install-hermes-os.sh` devrait fonctionner directement.

Si la résolution ne s'applique pas au boot :

```bash
# Vérifier les résolutions disponibles
sudo hwinfo --framebuffer

# Mode KMS (à ajouter dans GRUB_CMDLINE_LINUX)
# video=eDP-1:1920x1080@60
```

### Wi-Fi
Les Vivobook récents utilisent généralement des puces Intel ou Mediatek qui fonctionnent out-of-the-box avec Ubuntu.

```bash
# Vérifier
nmcli device status
nmcli radio wifi on
nmcli device wifi list
nmcli device wifi connect "MON_RESEAU" password "MON_MOT_DE_PASSE"
```

### Webcam
Non nécessaire pour HermesOS, mais fonctionne avec uvcvideo :

```bash
lsmod | grep uvcvideo
```

## Configuration recommandée pour Vivobook

Dans `~/.hermes/config.yaml`, ajuste selon ton CPU :

```yaml
# Pour Vivobook avec processeur Intel Core i5/i7/i9
provider: ollama
model: qwen2.5-coder:14b   # Bon équilibre vitesse/qualité sur 16GB RAM
# ou
model: gemma3:12b           # Si tu préfères des réponses plus créatives
```

Pour les modèles avec GPU discret (NVIDIA) :

```bash
# Installer CUDA pour Ollama
# Voir: https://github.com/ollama/ollama#nvidia
ollama run qwen2.5-coder:32b   # Modèle plus puissant possible avec GPU
```

## Raccourcis clavier console utiles

Une fois HermesOS installé, tu peux ajouter ces bindings dans `~/.bashrc` :

```bash
# Navigation rapide
bind '"\e[A": history-search-backward'  # Flèche haut = recherche dans l'historique
bind '"\e[B": history-search-forward'

# Raccourcis HermesOS
alias h='hermes'
alias hm='hermes, montre-moi la musique en cours'
alias hb='hermes, quel est l état de la batterie ?'
```

## Problèmes connus

| Problème | Solution |
|---|---|
| Écran noir au boot après GRUB | Ajoute `nomodeset` en paramètre GRUB temporairement, puis configure KMS correctement |
| Son grésillant | `echo 0 > /sys/module/snd_hda_intel/parameters/power_save` |
| Wi-Fi lent | Désactive le power management : `sudo iwconfig wlan0 power off` |

## Contribuer

Si tu as un modèle de Vivobook spécifique (S15, S16, 16X, Pro, etc.) et que tu as des configs supplémentaires à partager, ouvre une PR en ajoutant une section dans ce fichier !
