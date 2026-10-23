#!/bin/bash
# install.sh — Installation VPS d'automatisation (clé en main)
# Usage: sudo bash install.sh
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()  { echo -e "${GREEN}✅ $1${NC}"; }
info(){ echo -e "${YELLOW}ℹ️  $1${NC}"; }
err() { echo -e "${RED}❌ $1${NC}"; }

if [ "$(id -u)" -ne 0 ]; then err "Exécuter en root : sudo bash install.sh"; exit 1; fi

# Charger la config
DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$DIR/.env" ]; then
    set -a; source "$DIR/.env"; set +a
else
    err "Fichier .env manquant. Copier .env.example et remplir."
    exit 1
fi

DOMAIN="${DOMAIN:-example.com}"
EMAIL="${EMAIL:-admin@example.com}"

# ===== 1. SYSTÈME =====
info "Mise à jour système..."
apt update && apt upgrade -y

info "Paquets de base..."
apt install -y curl wget git ufw fail2ban htmx tmux ca-certificates gnupg

# ===== 2. DOCKER =====
if ! command -v docker &>/dev/null; then
    info "Installation Docker..."
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
fi
ok "Docker $(docker --version)"

docker compose version &>/dev/null || apt install -y docker-compose-plugin
ok "Docker Compose installé"

# ===== 3. RÉSEAU DOCKER =====
docker network create apps 2>/dev/null || true

# ===== 4. DÉPLOIEMENT =====
info "Déploiement des conteneurs..."
cd "$DIR"

# Générer la compose avec les variables
envsubst < docker-compose.yml > /tmp/docker-compose.yml
cp /tmp/docker-compose.yml ./docker-compose.yml

docker compose pull
docker compose up -d
ok "Conteneurs déployés"

# ===== 5. UFW =====
info "Configuration pare-feu..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment 'SSH'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw --force enable
ok "UFW : 22/80/443 uniquement"

# ===== 6. FAIL2BAN =====
cat > /etc/fail2ban/jail.local << 'F2B'
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5

[sshd]
enabled = true
port = 22
maxretry = 3
bantime = 24h
F2B
systemctl enable --now fail2ban
ok "fail2ban actif"

# ===== 7. CADDY =====
if ! command -v caddy &>/dev/null; then
    info "Installation Caddy..."
    apt install -y debian-keyring debian-archive-keyring
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
    apt update && apt install -y caddy
fi

# Générer Caddyfile avec le domaine
sed "s/{{DOMAIN}}/$DOMAIN/g; s/{{EMAIL}}/$EMAIL/g" Caddyfile > /etc/caddy/Caddyfile
systemctl enable --now caddy
ok "Caddy actif (SSL Let's Encrypt auto)"

# ===== 8. RÉSULTAT =====
echo ""
echo "═══════════════════════════════════════════════"
echo "  ✅ INSTALLATION TERMINÉE"
echo "═══════════════════════════════════════════════"
echo ""
docker ps --format '  └ {{.Names}} ({{.Image}})'
echo ""
echo "  Accès :"
echo "  └ https://n8n.$DOMAIN"
echo "  └ https://ollama.$DOMAIN"
echo "  └ https://netdata.$DOMAIN"
echo "  └ https://uptime.$DOMAIN"
echo "  └ https://filebrowser.$DOMAIN"
echo ""
echo "  Prochaines étapes :"
echo "  1. Configurer DNS (sous-domaines → IP du VPS)"
echo "  2. Ouvrir https://n8n.$DOMAIN et créer le compte admin"
echo "  3. Consulter les logs : journalctl -u caddy -f"
echo "  4. Ajouter des workflows n8n, des modèles Ollama..."
echo ""
