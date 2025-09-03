#!/bin/bash

# Script de réparation CarPlay OS pour Raspberry Pi 5
# Corrige les problèmes d'installation les plus courants

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

echo -e "${BLUE}🔧 RÉPARATION CARPLAY OS RASPBERRY PI 5${NC}"
echo "=========================================="

# Vérifier qu'on n'est pas root
if [[ "$EUID" -eq 0 ]]; then
    print_error "Ne pas exécuter ce script en tant que root!"
    print_info "Utilisez: su - pi puis relancez le script"
    exit 1
fi

# 1. Installation des dépendances manquantes
echo -e "\n${BLUE}1. INSTALLATION DÉPENDANCES${NC}"

# Node.js et Yarn
if ! command -v node &> /dev/null; then
    print_warning "Installation de Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo npm install -g yarn
    print_status "Node.js et Yarn installés"
fi

# MongoDB
if ! systemctl is-active --quiet mongod; then
    print_warning "Démarrage de MongoDB..."
    sudo systemctl enable mongod
    sudo systemctl start mongod
    print_status "MongoDB démarré"
fi

# Interface graphique si manquante
if ! command -v openbox &> /dev/null; then
    print_warning "Installation interface graphique..."
    sudo apt install -y --no-install-recommends \
        xserver-xorg \
        x11-xserver-utils \
        xinit \
        openbox \
        chromium-browser \
        unclutter
    print_status "Interface graphique installée"
fi

# 2. Création de la structure CarPlay
echo -e "\n${BLUE}2. CRÉATION STRUCTURE CARPLAY${NC}"

mkdir -p ~/carplay-os/{backend,frontend/src/components,frontend/public}
cd ~/carplay-os

print_status "Structure de dossiers créée"

# 3. Création des fichiers backend
echo -e "\n${BLUE}3. CRÉATION FICHIERS BACKEND${NC}"

# backend/server.py
cat > backend/server.py << 'EOF'
from fastapi import FastAPI, APIRouter
from fastapi.middleware.cors import CORSMiddleware
import os
import uvicorn

# Create the main app without a prefix
app = FastAPI()

# Create a router with the /api prefix
api_router = APIRouter(prefix="/api")

# Add your routes to the router instead of directly to app
@api_router.get("/")
async def root():
    return {"message": "CarPlay OS Backend Running"}

@api_router.get("/health")
async def health():
    return {"status": "healthy"}

# Include the router in the main app
app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)
EOF

# backend/requirements.txt
cat > backend/requirements.txt << 'EOF'
fastapi==0.110.1
uvicorn[standard]==0.25.0
python-multipart>=0.0.9
EOF

# backend/.env
cat > backend/.env << 'EOF'
DB_NAME="carplay_database"
CORS_ORIGINS="http://localhost:3000,http://localhost"
EOF

print_status "Fichiers backend créés"

# 4. Installation dépendances backend
echo -e "\n${BLUE}4. INSTALLATION BACKEND${NC}"

cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cd ..

print_status "Backend installé"

# 5. Création des fichiers frontend
echo -e "\n${BLUE}5. CRÉATION FICHIERS FRONTEND${NC}"

# frontend/package.json
cat > frontend/package.json << 'EOF'
{
  "name": "carplay-os-frontend",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.8.0",
    "react-scripts": "5.0.1",
    "axios": "^1.6.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
EOF

# frontend/.env
cat > frontend/.env << 'EOF'
REACT_APP_BACKEND_URL=http://localhost:8001
WDS_SOCKET_PORT=3000
BROWSER=none
EOF

# frontend/public/index.html
cat > frontend/public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="CarPlay OS pour Raspberry Pi" />
    <title>CarPlay OS</title>
    <style>
      body {
        margin: 0;
        padding: 0;
        overflow: hidden;
        background: #000;
        font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
      }
    </style>
  </head>
  <body>
    <noscript>Vous devez activer JavaScript pour utiliser cette app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF

# frontend/src/index.js
cat > frontend/src/index.js << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

# frontend/src/index.css
cat > frontend/src/index.css << 'EOF'
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', 'Roboto', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background: linear-gradient(135deg, #0a0a0a 0%, #1a1a1a 100%);
  color: white;
  overflow: hidden;
  user-select: none;
  touch-action: manipulation;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New', monospace;
}

* {
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
  -webkit-tap-highlight-color: transparent;
}
EOF

# frontend/src/App.js
cat > frontend/src/App.js << 'EOF'
import React from "react";
import "./App.css";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import CarPlayHome from "./components/CarPlayHome";

function App() {
  return (
    <div className="App">
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<CarPlayHome />} />
        </Routes>
      </BrowserRouter>
    </div>
  );
}

export default App;
EOF

# frontend/src/App.css
cat > frontend/src/App.css << 'EOF'
.App {
  height: 100vh;
  width: 100vw;
  background: linear-gradient(135deg, #0a0a0a 0%, #1a1a1a 100%);
}

.carplay-container {
  height: 100vh;
  width: 100vw;
  display: flex;
  flex-direction: column;
  background: linear-gradient(135deg, #0a0a0a 0%, #1a1a1a 100%);
  position: relative;
  overflow: hidden;
}

.status-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 30px;
  background: rgba(0,0,0,0.3);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(255,255,255,0.1);
  z-index: 100;
}

.time {
  font-size: 24px;
  font-weight: 600;
  color: #ffffff;
}

.main-content {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
}

.welcome-message {
  text-align: center;
  color: white;
}

.welcome-message h1 {
  font-size: 48px;
  margin-bottom: 20px;
  background: linear-gradient(45deg, #007AFF, #FF2D92);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.welcome-message p {
  font-size: 24px;
  opacity: 0.8;
}
EOF

# frontend/src/components/CarPlayHome.js
cat > frontend/src/components/CarPlayHome.js << 'EOF'
import React, { useState, useEffect } from "react";

const CarPlayHome = () => {
  const [currentTime, setCurrentTime] = useState(new Date());

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  const formatTime = (date) => {
    return date.toLocaleTimeString('fr-FR', { 
      hour: '2-digit', 
      minute: '2-digit',
      hour12: false 
    });
  };

  return (
    <div className="carplay-container">
      <div className="status-bar">
        <div className="time">{formatTime(currentTime)}</div>
        <div>CarPlay OS Ready!</div>
      </div>
      
      <div className="main-content">
        <div className="welcome-message">
          <h1>🚗 CarPlay OS</h1>
          <p>Interface prête pour Raspberry Pi 5</p>
          <p>Version de base fonctionnelle</p>
        </div>
      </div>
    </div>
  );
};

export default CarPlayHome;
EOF

print_status "Fichiers frontend créés"

# 6. Installation dépendances frontend
echo -e "\n${BLUE}6. INSTALLATION FRONTEND${NC}"

cd frontend
yarn install
cd ..

print_status "Frontend installé"

# 7. Création du script de démarrage
echo -e "\n${BLUE}7. SCRIPT DE DÉMARRAGE${NC}"

cat > ~/start-carplay.sh << 'EOF'
#!/bin/bash

# Variables
export DISPLAY=:0
cd /home/pi/carplay-os

# Attendre que le système soit prêt
sleep 5

# Démarrage MongoDB
sudo systemctl start mongod

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
    --start-fullscreen \
    --window-position=0,0 \
    http://localhost:3000 &

echo $BACKEND_PID > /tmp/carplay-backend.pid
echo $FRONTEND_PID > /tmp/carplay-frontend.pid

wait
EOF

chmod +x ~/start-carplay.sh

print_status "Script de démarrage créé"

# 8. Configuration auto-démarrage
echo -e "\n${BLUE}8. CONFIGURATION AUTO-DÉMARRAGE${NC}"

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

# Configuration .bashrc si pas déjà fait
if ! grep -q "startx" ~/.bashrc; then
    echo '
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    startx
fi' >> ~/.bashrc
fi

print_status "Auto-démarrage configuré"

# 9. Test rapide
echo -e "\n${BLUE}9. TEST RAPIDE${NC}"

cd ~/carplay-os/backend
source venv/bin/activate
python server.py &
BACKEND_PID=$!
sleep 3

if curl -s http://localhost:8001/api/health > /dev/null; then
    print_status "Backend fonctionne!"
else
    print_error "Problème avec le backend"
fi

kill $BACKEND_PID 2>/dev/null || true

print_status "Installation réparée!"

echo -e "\n${GREEN}🎉 RÉPARATION TERMINÉE!${NC}"
echo "=================================="
print_info "1. Redémarrez le système: sudo reboot"
print_info "2. Le CarPlay OS devrait se lancer automatiquement"
print_info "3. Si problème, vérifiez les logs: tail -f ~/.pm2/logs/"
print_info ""
print_warning "Pour démarrage manuel: ~/start-carplay.sh"
print_warning "Pour diagnostic: ~/debug-pi5.sh"