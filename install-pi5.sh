#!/bin/bash

# Script d'installation automatique CarPlay OS pour Raspberry Pi 5
# Auteur: Assistant E1
# Version: 1.0

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'affichage coloré
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Vérification des prérequis
check_prerequisites() {
    print_header "Vérification des prérequis"
    
    # Vérifier si on est sur Raspberry Pi
    if [[ ! -f /proc/device-tree/model ]] || ! grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
        print_error "Ce script doit être exécuté sur un Raspberry Pi"
        exit 1
    fi
    
    # Vérifier la version du Pi
    if grep -q "Raspberry Pi 5" /proc/device-tree/model 2>/dev/null; then
        print_status "Raspberry Pi 5 détecté ✓"
    else
        print_warning "Raspberry Pi 5 non détecté. Le script peut ne pas fonctionner correctement."
    fi
    
    # Vérifier les droits sudo
    if ! sudo -n true 2>/dev/null; then
        print_error "Les droits sudo sont requis"
        exit 1
    fi
    
    print_status "Prérequis validés ✓"
}

# Mise à jour du système
update_system() {
    print_header "Mise à jour du système"
    sudo apt update
    sudo apt upgrade -y
    print_status "Système mis à jour ✓"
}

# Installation des dépendances système
install_system_dependencies() {
    print_header "Installation des dépendances système"
    
    # Dépendances de base
    sudo apt install -y \
        curl \
        wget \
        git \
        python3 \
        python3-pip \
        python3-venv \
        build-essential \
        pkg-config \
        libffi-dev \
        libssl-dev
    
    print_status "Dépendances système installées ✓"
}

# Installation de Node.js
install_nodejs() {
    print_header "Installation de Node.js"
    
    # Installation Node.js 18+
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    # Installation Yarn
    npm install -g yarn
    
    print_status "Node.js $(node --version) installé ✓"
    print_status "Yarn $(yarn --version) installé ✓"
}

# Installation de MongoDB
install_mongodb() {
    print_header "Installation de MongoDB"
    
    # Import de la clé GPG MongoDB
    wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
    
    # Ajout du repository MongoDB pour Ubuntu/Debian ARM64
    echo "deb [ arch=arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    
    sudo apt-get update
    sudo apt-get install -y mongodb-org
    
    # Activation du service MongoDB
    sudo systemctl enable mongod
    sudo systemctl start mongod
    
    print_status "MongoDB installé et démarré ✓"
}

# Installation de l'interface graphique légère
install_gui() {
    print_header "Installation interface graphique"
    
    sudo apt install -y --no-install-recommends \
        xserver-xorg \
        x11-xserver-utils \
        xinit \
        openbox \
        chromium-browser \
        unclutter \
        xserver-xorg-input-evdev \
        xinput-calibrator
    
    print_status "Interface graphique installée ✓"
}

# Configuration de l'écran tactile
configure_touchscreen() {
    print_header "Configuration écran tactile"
    
    # Sauvegarde du fichier config.txt
    sudo cp /boot/config.txt /boot/config.txt.backup
    
    # Configuration pour écran tactile
    echo "
# Configuration CarPlay OS
dtoverlay=vc4-kms-v3d
gpu_mem=128
disable_overscan=1
disable_splash=1

# Optimisations performance Pi 5
arm_freq=2400
over_voltage=6

# Configuration écran tactile (décommentez selon votre écran)
# Pour écran officiel 7\" Raspberry Pi :
# dtoverlay=rpi-display,rotate=180

# Pour écran HDMI tactile :
# hdmi_group=2
# hdmi_mode=87
# hdmi_cvt 1024 600 60 6 0 0 0
" | sudo tee -a /boot/config.txt
    
    print_status "Configuration écran tactile ajoutée ✓"
    print_warning "Décommentez les lignes appropriées dans /boot/config.txt selon votre écran"
}

# Création du projet CarPlay
setup_carplay_project() {
    print_header "Configuration du projet CarPlay"
    
    # Création du répertoire projet
    mkdir -p ~/carplay-os
    cd ~/carplay-os
    
    # Création de la structure des dossiers
    mkdir -p backend frontend/src/components frontend/public
    
    print_status "Structure de projet créée ✓"
}

# Copie des fichiers du projet (placeholder - l'utilisateur devra copier ses fichiers)
copy_project_files() {
    print_header "Copie des fichiers de projet"
    
    print_warning "ÉTAPE MANUELLE REQUISE:"
    print_warning "1. Copiez vos fichiers depuis le développement cloud vers ~/carplay-os/"
    print_warning "2. Structure attendue:"
    print_warning "   ~/carplay-os/backend/ (server.py, requirements.txt, .env)"
    print_warning "   ~/carplay-os/frontend/ (package.json, src/, public/)"
    
    read -p "Appuyez sur Entrée une fois les fichiers copiés..."
}

# Installation des dépendances du projet
install_project_dependencies() {
    print_header "Installation des dépendances du projet"
    
    cd ~/carplay-os
    
    # Installation dépendances backend
    if [[ -f backend/requirements.txt ]]; then
        cd backend
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
        cd ..
        print_status "Dépendances backend installées ✓"
    else
        print_error "Fichier backend/requirements.txt non trouvé"
    fi
    
    # Installation dépendances frontend
    if [[ -f frontend/package.json ]]; then
        cd frontend
        yarn install
        print_status "Dépendances frontend installées ✓"
    else
        print_error "Fichier frontend/package.json non trouvé"
    fi
}

# Configuration du démarrage automatique
configure_autostart() {
    print_header "Configuration du démarrage automatique"
    
    # Création du script de démarrage
    cat > ~/start-carplay.sh << 'EOF'
#!/bin/bash

# Attendre que le réseau soit prêt
sleep 5

# Démarrage MongoDB
sudo systemctl start mongod

# Variables d'environnement
export DISPLAY=:0
cd /home/pi/carplay-os

# Démarrage Backend
cd backend
source venv/bin/activate
python server.py &
BACKEND_PID=$!

# Démarrage Frontend
cd ../frontend
BROWSER=none yarn start &
FRONTEND_PID=$!

# Attendre que les services démarrent
sleep 15

# Lancer Chromium en mode kiosk
chromium-browser \
    --kiosk \
    --disable-infobars \
    --no-sandbox \
    --disable-features=TranslateUI \
    --disk-cache-dir=/tmp \
    --disable-dev-shm-usage \
    --disable-web-security \
    --disable-features=VizDisplayCompositor \
    --start-fullscreen \
    --window-position=0,0 \
    --window-size=1024,600 \
    http://localhost:3000 &

# Sauvegarde des PIDs pour arrêt propre
echo $BACKEND_PID > /tmp/carplay-backend.pid
echo $FRONTEND_PID > /tmp/carplay-frontend.pid

wait
EOF
    
    chmod +x ~/start-carplay.sh
    
    # Configuration Openbox
    mkdir -p ~/.config/openbox
    cat > ~/.config/openbox/autostart << 'EOF'
#!/bin/bash

# Désactiver l'économiseur d'écran
xset s noblank
xset s off
xset -dpms

# Masquer le curseur
unclutter -idle 1 &

# Démarrer CarPlay
/home/pi/start-carplay.sh &
EOF
    
    chmod +x ~/.config/openbox/autostart
    
    # Configuration auto-login et startx
    echo '
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    startx
fi' >> ~/.bashrc
    
    print_status "Démarrage automatique configuré ✓"
}

# Optimisations système
optimize_system() {
    print_header "Optimisations système"
    
    # Désactivation des services non nécessaires
    sudo systemctl disable bluetooth 2>/dev/null || true
    sudo systemctl disable cups 2>/dev/null || true
    sudo systemctl disable triggerhappy 2>/dev/null || true
    
    # Configuration de la swappiness
    echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
    
    print_status "Optimisations appliquées ✓"
}

# Script de désinstallation
create_uninstall_script() {
    cat > ~/uninstall-carplay.sh << 'EOF'
#!/bin/bash
echo "Désinstallation CarPlay OS..."

# Arrêt des services
pkill -f "python server.py" 2>/dev/null || true
pkill -f "yarn start" 2>/dev/null || true
pkill chromium-browser 2>/dev/null || true

# Suppression des fichiers
rm -rf ~/carplay-os
rm -f ~/start-carplay.sh
rm -rf ~/.config/openbox

# Restauration de la configuration
if [[ -f /boot/config.txt.backup ]]; then
    sudo cp /boot/config.txt.backup /boot/config.txt
fi

# Réactivation des services
sudo systemctl enable bluetooth 2>/dev/null || true

echo "Désinstallation terminée. Redémarrez le système."
EOF
    
    chmod +x ~/uninstall-carplay.sh
    print_status "Script de désinstallation créé: ~/uninstall-carplay.sh"
}

# Fonction principale
main() {
    print_header "Installation CarPlay OS pour Raspberry Pi 5"
    print_status "Début de l'installation..."
    
    check_prerequisites
    update_system
    install_system_dependencies
    install_nodejs
    install_mongodb
    install_gui
    configure_touchscreen
    setup_carplay_project
    copy_project_files
    install_project_dependencies
    configure_autostart
    optimize_system
    create_uninstall_script
    
    print_header "Installation terminée !"
    print_status "Votre CarPlay OS est maintenant installé sur le Raspberry Pi 5"
    print_warning "PROCHAINES ÉTAPES:"
    print_warning "1. Redémarrez le système: sudo reboot"
    print_warning "2. Configurez votre écran tactile dans /boot/config.txt"
    print_warning "3. Testez l'interface CarPlay"
    print_warning ""
    print_status "En cas de problème, consultez ~/carplay-install.log"
    print_status "Pour désinstaller: ~/uninstall-carplay.sh"
}

# Exécution avec logging
main 2>&1 | tee ~/carplay-install.log