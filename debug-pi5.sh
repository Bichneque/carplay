#!/bin/bash

# Script de diagnostic CarPlay OS pour Raspberry Pi 5
# Permet d'identifier les problèmes d'installation

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_info() { echo -e "${BLUE}[i]${NC} $1"; }

echo -e "${BLUE}🔍 DIAGNOSTIC CARPLAY OS RASPBERRY PI 5${NC}"
echo "==========================================="

# 1. Vérifier l'utilisateur actuel
echo -e "\n${BLUE}1. VÉRIFICATION UTILISATEUR${NC}"
CURRENT_USER=$(whoami)
print_info "Utilisateur actuel: $CURRENT_USER"

if [[ "$CURRENT_USER" == "root" ]]; then
    print_warning "Vous êtes connecté en tant que root!"
    print_warning "CarPlay OS doit être installé avec l'utilisateur 'pi'"
    print_warning "Changez vers l'utilisateur pi: su - pi"
fi

# 2. Vérifier la structure des fichiers CarPlay
echo -e "\n${BLUE}2. VÉRIFICATION FICHIERS CARPLAY${NC}"

if [[ -d ~/carplay-os ]]; then
    print_status "Dossier ~/carplay-os trouvé"
    ls -la ~/carplay-os/
else
    print_error "Dossier ~/carplay-os MANQUANT"
fi

if [[ -f ~/start-carplay.sh ]]; then
    print_status "Script ~/start-carplay.sh trouvé"
else
    print_error "Script ~/start-carplay.sh MANQUANT"
fi

# 3. Vérifier les dépendances système
echo -e "\n${BLUE}3. VÉRIFICATION DÉPENDANCES${NC}"

# Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_status "Node.js installé: $NODE_VERSION"
else
    print_error "Node.js NON INSTALLÉ"
fi

# Yarn
if command -v yarn &> /dev/null; then
    YARN_VERSION=$(yarn --version)
    print_status "Yarn installé: $YARN_VERSION"
else
    print_error "Yarn NON INSTALLÉ"
fi

# Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    print_status "Python3 installé: $PYTHON_VERSION"
else
    print_error "Python3 NON INSTALLÉ"
fi

# MongoDB
if systemctl is-active --quiet mongod; then
    print_status "MongoDB service ACTIF"
else
    print_error "MongoDB service INACTIF"
fi

# 4. Vérifier la configuration d'auto-démarrage
echo -e "\n${BLUE}4. VÉRIFICATION AUTO-DÉMARRAGE${NC}"

if [[ -f ~/.config/openbox/autostart ]]; then
    print_status "Configuration openbox trouvée"
    print_info "Contenu:"
    cat ~/.config/openbox/autostart
else
    print_error "Configuration openbox MANQUANTE"
fi

# Vérifier .bashrc
if grep -q "startx" ~/.bashrc; then
    print_status "Configuration startx dans .bashrc trouvée"
else
    print_error "Configuration startx MANQUANTE dans .bashrc"
fi

# 5. Vérifier les processus en cours
echo -e "\n${BLUE}5. VÉRIFICATION PROCESSUS${NC}"

if pgrep -f "python.*server.py" > /dev/null; then
    print_status "Backend CarPlay en cours d'exécution"
else
    print_error "Backend CarPlay NON ACTIF"
fi

if pgrep -f "yarn.*start" > /dev/null; then
    print_status "Frontend CarPlay en cours d'exécution"
else
    print_error "Frontend CarPlay NON ACTIF"
fi

if pgrep chromium > /dev/null; then
    print_status "Chromium en cours d'exécution"
else
    print_error "Chromium NON ACTIF"
fi

# 6. Vérifier les logs
echo -e "\n${BLUE}6. VÉRIFICATION LOGS${NC}"

if [[ -f ~/carplay-install.log ]]; then
    print_status "Log d'installation trouvé"
    print_info "Dernières lignes du log:"
    tail -10 ~/carplay-install.log
else
    print_error "Log d'installation MANQUANT"
fi

# 7. Test de connectivité
echo -e "\n${BLUE}7. TEST CONNECTIVITÉ${NC}"

if curl -s http://localhost:8001/api/ > /dev/null; then
    print_status "Backend accessible sur port 8001"
else
    print_error "Backend INACCESSIBLE sur port 8001"
fi

if curl -s http://localhost:3000 > /dev/null; then
    print_status "Frontend accessible sur port 3000"
else
    print_error "Frontend INACCESSIBLE sur port 3000"
fi

# 8. Résumé et recommandations
echo -e "\n${BLUE}8. DIAGNOSTIC FINAL${NC}"
echo "=================================="

PROBLEMS_FOUND=0

if [[ ! -d ~/carplay-os ]]; then
    print_error "PROBLÈME MAJEUR: Fichiers CarPlay manquants"
    PROBLEMS_FOUND=$((PROBLEMS_FOUND + 1))
fi

if [[ "$CURRENT_USER" == "root" ]]; then
    print_error "PROBLÈME: Installation effectuée en tant que root"
    PROBLEMS_FOUND=$((PROBLEMS_FOUND + 1))
fi

if ! command -v node &> /dev/null; then
    print_error "PROBLÈME: Node.js non installé"
    PROBLEMS_FOUND=$((PROBLEMS_FOUND + 1))
fi

if ! systemctl is-active --quiet mongod; then
    print_error "PROBLÈME: MongoDB non démarré"
    PROBLEMS_FOUND=$((PROBLEMS_FOUND + 1))
fi

echo -e "\n${BLUE}RECOMMANDATIONS:${NC}"

if [[ $PROBLEMS_FOUND -gt 0 ]]; then
    print_warning "$PROBLEMS_FOUND problème(s) détecté(s)"
    
    if [[ ! -d ~/carplay-os ]]; then
        print_info "1. Re-téléchargez les fichiers CarPlay OS"
        print_info "2. Copiez-les dans ~/carplay-os/"
        print_info "3. Relancez l'installation avec l'utilisateur 'pi'"
    fi
    
    if [[ "$CURRENT_USER" == "root" ]]; then
        print_info "Changez vers l'utilisateur pi: su - pi"
    fi
    
    if ! systemctl is-active --quiet mongod; then
        print_info "Démarrez MongoDB: sudo systemctl start mongod"
    fi
else
    print_status "Système semble correct!"
    print_info "Tentez un redémarrage: sudo reboot"
fi

echo -e "\n${GREEN}Diagnostic terminé!${NC}"
echo "Sauvegardé dans ~/carplay-diagnostic.log"