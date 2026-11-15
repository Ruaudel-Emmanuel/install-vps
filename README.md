# install-vps

Script d'installation d'un VPS (Ubuntu) : système, Docker, pare-feu UFW, fail2ban et proxy Caddy.

## Contenu

- `install.sh` — script principal (119 lignes), exécuté en root. Sections : mise à jour système et paquets de base, installation Docker, réseau Docker, déploiement, UFW, fail2ban, Caddy, affichage du résultat.
- `.env.example` — template de configuration à copier en `.env` : domaine, email, mots de passe n8n, tokens API (GITHUB_PAT, OPENROUTER_API_KEY, BROWSERLESS_TOKEN).
- `.gitignore` — ignore notamment `.env`.
- `README.md` — ce fichier.

## Usage

```bash
cp .env.example .env   # puis remplir les valeurs
sudo bash install.sh
```

Le script exige les droits root et un fichier `.env` présent à côté de lui (sinon il s'arrête avec une erreur).
