# Contributing to HermesOS

Bienvenue ! HermesOS est un projet communautaire. Toute contribution est la bienvenue, qu'il s'agisse d'un script, d'une config, d'un skill Hermes, ou d'un simple retour d'expérience.

## Ce dont le projet a le plus besoin

- **Testeurs** : essaye le script d'installation sur ton matériel et ouvre une issue
- **Scripts hardware** : notes de compatibilité pour ton laptop / mini-PC / Raspberry Pi
- **Skills Hermes** : skills utiles à partager dans `hermes-profiles/`
- **Configs console** : thèmes ncmpcpp, configs mpv, setups neovim qui fonctionnent bien
- **Documentation** : améliorer les guides, ajouter des exemples concrets

## Comment contribuer

### 1. Fork et clone

```bash
git clone https://github.com/TON_PSEUDO/HermesOS.git
cd HermesOS
git checkout -b feature/ma-contribution
```

### 2. Structure des contributions

| Type | Où ça va |
|---|---|
| Script d'installation | `scripts/` |
| Config d'outil | `config/<nom-outil>/` |
| Note hardware | `docs/hardware/<machine>.md` |
| Skill Hermes | `hermes-profiles/<profil>/skills/` |
| Documentation | `docs/` |

### 3. Conventions

- Les scripts bash doivent commencer par `set -euo pipefail`
- Les scripts doivent être commentés en anglais (commentaires de code) ou en français (README)
- Teste ton script sur une installation fraîche avant de soumettre
- Pour les configs, indique clairement le matériel sur lequel elles ont été testées

### 4. Ouvrir une Pull Request

- Décris brièvement ce que tu changes et pourquoi
- Si tu corriges un bug, référence l'issue correspondante
- Les PRs sont mergées dès qu'elles sont revues — pas de process lourd ici

## Rapporter un problème

Utilise les templates d'issues disponibles :
- **Bug report** : quelque chose ne fonctionne pas
- **Hardware support** : ton matériel a besoin de configurations spécifiques
- **Feature request** : une idée pour améliorer le projet

## Partager un skill Hermes

Un "skill" HermesOS est un fichier Markdown dans `hermes-profiles/` qui décrit une procédure que Hermes apprend à exécuter. Format recommandé :

```markdown
# Nom du skill

## Contexte
Quand utiliser ce skill.

## Étapes
1. Étape 1
2. Étape 2

## Vérifications
- Que vérifier après exécution

## Pièges connus
- Ce qui peut mal se passer
```

## Code de conduite

Ce projet est un espace de partage technique et de passion. Sois respectueux, constructif, et garde l'esprit "bidouilleur" qui fait l'âme du projet.

---

Merci de contribuer à HermesOS !
