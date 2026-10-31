# Install-VPS — Déployez un serveur d'automatisation en 30 minutes

Ce script est l'industrialisation du socle que je déploie chez mes clients : un serveur d'automatisation souverain, prêt en 30 minutes.

---

> Script d'installation pour déployer un **VPS d'automatisation** clé en main :
> n8n + Ollama (IA locale) + monitoring + backups.
>
> **⚠️ Aucun secret dans ce repo** — juste un template. Vous remplissez vos propres clés.

---

## 🎯 Pourquoi ce repo existe

Vous avez besoin d'un **serveur personnel** pour :
- 🤖 Automatiser vos tâches (n8n)
- 🧠 Héberger une IA locale (Ollama) — **zéro abonnement, zéro data dans le cloud**
- 📊 Monitorer votre infra en temps réel
- 💾 Sauvegarder vos données automatiquement
- 🔒 Le tout **derrière Cloudflare**, SSL auto, pare-feu, anti-brute-force

Ce script fait tout ça en **une commande**.

---

## ✨ Ce qu'on peut faire avec ce VPS

| Domaine | Exemples concrets |
|---|---|
| **🤖 Automation** | Workflows n8n : audit GitHub quotidien, alertes Stripe/Tally, veille concurrentielle, diffusion réseaux, génération de devis |
| **🧠 IA privée** | Ollama + modèles locaux : résumé de pages web, descriptions automatiques de repos, analyse de documents, chatbot privé |
| **📊 Monitoring** | Netdata (temps réel), Uptime-Kuma (disponibilité), watchdog Telegram (15 min), journal quotidien automatique |
| **💾 Backups** | Sauvegarde Kopia vers un disque local ou second serveur — incrémental, chiffré |
| **🔧 DevOps** | Proxy Caddy + Let's Encrypt, Cloudflare DNS, fail2ban, Docker Compose, scripts systemd |
| **📈 Analytics** | Umami (auto-hébergé, respectueux de la vie privée) |
| **🌐 Scraping** | Browserless (Chromium headless) pour pages JS, PDF, screenshots |
| **📱 Alertes** | Bot Telegram : commandes (/status, /backup, /pause), alertes automatiques |

---

## 📦 Services installés

| Service | Rôle | Port exposé |
|---|---|---|
| **n8n** | Workflow automation (no-code + code) | 5678 (127.0.0.1) |
| **PostgreSQL 17** | Base de données pour n8n | Interne |
| **Ollama** | IA locale (Llama, Qwen, etc.) | 11434 (interne) |
| **Browserless** | Chromium headless pour scraping | 3100 (127.0.0.1) |
| **Uptime-Kuma** | Monitoring de disponibilité | 3001 (127.0.0.1) |
| **Netdata** | Monitoring temps réel (CPU, RAM, disque, réseau) | 19999 (127.0.0.1) |
| **FileBrowser** | Gestion de fichiers via navigateur | 8080 (127.0.0.1) |
| **Umami** | Analytics respectueux (remplace Google Analytics) | 3000 (127.0.0.1) |

Tous les services sont **accessibles uniquement en 127.0.0.1** et proxifiés par **Caddy** avec SSL Let's Encrypt automatique.

---

## 🚀 Installation

### Prérequis

- Un VPS **Ubuntu 24.04 ou 26.04** (4 vCPU, 8 Go RAM, 80 Go disque recommandés)
- Un nom de domaine pointant vers l'IP du VPS (Cloudflare recommandé)
- Accès **root** au VPS

### 1. Cloner

```bash
git clone https://github.com/Ruaudel-Emmanuel/install-vps.git
cd install-vps
```

### 2. Configurer

```bash
cp .env.example .env
nano .env
# → Remplir : domaines, mots de passe, tokens API
```

### 3. Installer

```bash
sudo bash install.sh
```

⏱️ Comptez **15 à 30 minutes** selon le débit du VPS (télécharge Docker + modèles Ollama).

### 4. Configurer le DNS

Ajoutez les sous-domaines dans votre zone DNS :
```
n8n.votredomaine.com → IP_DU_VPS
ollama.votredomaine.com → IP_DU_VPS
...
```

---

## 🔒 Sécurité incluse

| Mesure | Détail |
|---|---|
| **Pare-feu (UFW)** | 22/80/443 uniquement |
| **Anti-brute-force (fail2ban)** | SSH : 3 tentatives → banni 24h |
| **SSL automatique** | Let's Encrypt via Caddy |
| **Proxy Cloudflare** | Cache, DDoS protection, IP masquée |
| **Services isolés** | Docker, exposition locale uniquement |
| **Backups** | Kopia vers stockage externe |

---

## 📊 Stack technique

```
Ubuntu 26.04
├── Docker + Compose (10 conteneurs)
├── Caddy (proxy inverse, SSL auto)
├── Cloudflare (DNS, proxy, cache)
├── UFW + fail2ban (sécurité)
├── PostgreSQL 17 (base de données)
├── Ollama (IA locale)
└── Systemd timers (monitoring, backups, màj auto)
```

---

## 📁 Structure du repo

```
install-vps/
├── install.sh           ← Script principal
├── .env.example         ← Template de configuration
├── docker-compose.yml   ← Tous les services
├── Caddyfile            ← Configuration du proxy
└── docs/
    ├── services.md      ← Détail de chaque service
    └── security.md      ← Checklist sécurité
```

---


## 🤝 Ce projet, c'est aussi mon métier

**Emmanuel Ruaudel — Directeur de la Transformation Numérique pour TPE/PME.**
J'aide les dirigeants à libérer 5 à 10 h par semaine en automatisant leurs tâches
répetitives : audit des processus, cas d'usage IA à fort ROI, déploiement et
fiabilisation (n8n · Python · IA locale).

📧 [ruaudel.emmanuel@orange.fr](mailto:ruaudel.emmanuel@orange.fr) · 🌐 [rennesdev.fr](https://rennesdev.fr)

## 📝 Licence

MIT — Utilisation libre, modification, distribution.

---

*Inspiré de l'infrastructure réelle de rennesdev.fr — un VPS d'automatisation en production depuis 2025.*
