# Skills HermesOS — Exemples

Les skills sont des procédures que Hermes mémorise et réutilise. Ils sont créés automatiquement après des tâches complexes, mais tu peux aussi en créer manuellement.

## Comment créer un skill manuellement

Dis simplement à Hermes :
```
hermes, crée un skill pour [ce que tu veux mémoriser]
```

Ou crée le fichier directement dans `~/.hermes/skills/`.

---

## Skill : Lancer de la musique

**Fichier** : `~/.hermes/skills/play-music.md`

```markdown
# Lancer de la musique avec mpd/mpc

## Contexte
Quand l'utilisateur veut écouter de la musique en spécifiant un artiste ou un album.

## Étapes
1. Vérifier que mpd est lancé : `mpc status`
2. Si arrêté : `systemctl --user start mpd`
3. Chercher dans la bibliothèque : `mpc search artist "NOM_ARTISTE"`
4. Vider la queue et ajouter : `mpc clear && mpc findadd artist "NOM_ARTISTE"`
5. Lancer la lecture : `mpc play`
6. Confirmer ce qui joue : `mpc current`

## Pour un album spécifique
`mpc clear && mpc findadd album "NOM_ALBUM" && mpc play`

## Vérifications
- `mpc status` doit montrer [playing]
- Si aucun résultat, relancer l'indexation : `mpc update`

## Pièges connus
- Les tags ID3 doivent être corrects pour que la recherche fonctionne
- Si la bibliothèque n'est pas indexée : `mpc update` et attendre
```

---

## Skill : Déployer un projet FastAPI

**Fichier** : `~/.hermes/skills/deploy-fastapi.md`

```markdown
# Déployer une API FastAPI avec Docker

## Contexte
Créer et déployer une nouvelle API FastAPI avec Docker Compose.

## Étapes
1. Créer la structure du projet
   ```
   mkdir nom-projet && cd nom-projet
   mkdir app tests
   ```
2. Créer `app/main.py` avec le code de base
3. Créer `requirements.txt` avec fastapi, uvicorn, pydantic
4. Créer `Dockerfile` multi-stage
5. Créer `docker-compose.yml` avec le service
6. Build et test : `docker compose up --build`

## Conventions du projet (mémorisées)
- Python 3.11+
- Pydantic v2 pour les modèles
- Tests avec pytest
- Linting avec ruff

## Vérifications
- L'API répond sur le port configuré
- Les tests passent : `docker compose run --rm app pytest`

## Commande de reprise rapide
`docker compose up -d && docker compose logs -f`
```

---

## Skill : Backup quotidien

**Fichier** : `~/.hermes/skills/daily-backup.md`

```markdown
# Backup des projets importants

## Contexte
Sauvegarde automatique des dossiers importants.

## Dossiers à sauvegarder (adapter selon l'utilisateur)
- ~/Projects
- ~/.hermes (mémoire et skills de l'agent)
- ~/.config

## Commande
```bash
tar -czf ~/backups/hermos-$(date +%Y%m%d).tar.gz \
    ~/Projects \
    ~/.hermes \
    ~/.config
```

## Rotation (garder les 7 derniers)
`find ~/backups -name "hermos-*.tar.gz" -mtime +7 -delete`

## Vérifications
- Vérifier la taille du backup (anomalie si < 1MB ou > 500MB)
- Tester la décompression périodiquement
```

---

## Skill : Optimiser la batterie

**Fichier** : `~/.hermes/skills/battery-optimize.md`

```markdown
# Optimisation de la batterie (ASUS Vivobook)

## Contexte
Maximiser l'autonomie quand on est sur batterie.

## Étapes
1. Vérifier l'état : `tlp-stat -b`
2. Mode économie d'énergie : `sudo tlp bat`
3. Réduire la luminosité de la console (si applicable)
4. Désactiver le Wi-Fi si non utilisé : `nmcli radio wifi off`
5. Vérifier les processus gourmands : `btop`

## Seuil d'alerte
Si batterie < 20% : notifier et proposer de sauvegarder le travail en cours.

## Commande rapide
`tlp-stat -b | grep -E "Charge|Status|Remaining"`
```

---

## Comment Hermes crée des skills automatiquement

Après une tâche complexe (5+ appels d'outils), Hermes génère automatiquement un skill avec :
- La procédure complète étape par étape
- Les pièges rencontrés et leurs solutions
- Les vérifications post-exécution
- Les conventions spécifiques à ton environnement

Ces skills s'améliorent à chaque réutilisation. Au bout de quelques semaines, Hermes connaît tes workflows mieux que n'importe quelle documentation.
