#!/bin/bash

# Script pour télécharger tous les fichiers CarPlay OS
# À exécuter sur votre ordinateur local pour récupérer les fichiers

echo "🚗 Téléchargement des fichiers CarPlay OS"
echo "========================================"

# Créer la structure de dossiers
mkdir -p carplay-os-pi5/{backend,frontend/src/components,frontend/public}
cd carplay-os-pi5

# URL de base de votre projet (remplacer par l'URL correcte)
BASE_URL="https://carplay-raspberry.preview.emergentagent.com"

echo "📁 Création de la structure..."

# BACKEND FILES
echo "🔧 Création des fichiers backend..."

# server.py
cat > backend/server.py << 'EOF'
from fastapi import FastAPI, APIRouter
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
import os
import logging
from pathlib import Path
from pydantic import BaseModel, Field
from typing import List
import uuid
from datetime import datetime


ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# MongoDB connection
mongo_url = os.environ['MONGO_URL']
client = AsyncIOMotorClient(mongo_url)
db = client[os.environ['DB_NAME']]

# Create the main app without a prefix
app = FastAPI()

# Create a router with the /api prefix
api_router = APIRouter(prefix="/api")


# Define Models
class StatusCheck(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    client_name: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)

class StatusCheckCreate(BaseModel):
    client_name: str

# Add your routes to the router instead of directly to app
@api_router.get("/")
async def root():
    return {"message": "Hello World"}

@api_router.post("/status", response_model=StatusCheck)
async def create_status_check(input: StatusCheckCreate):
    status_dict = input.dict()
    status_obj = StatusCheck(**status_dict)
    _ = await db.status_checks.insert_one(status_obj.dict())
    return status_obj

@api_router.get("/status", response_model=List[StatusCheck])
async def get_status_checks():
    status_checks = await db.status_checks.find().to_list(1000)
    return [StatusCheck(**status_check) for status_check in status_checks]

# Include the router in the main app
app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=os.environ.get('CORS_ORIGINS', '*').split(','),
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@app.on_event("shutdown")
async def shutdown_db_client():
    client.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
EOF

# requirements.txt
cat > backend/requirements.txt << 'EOF'
fastapi==0.110.1
uvicorn==0.25.0
python-dotenv>=1.0.1
motor==3.3.1
pydantic>=2.6.4
python-multipart>=0.0.9
EOF

# .env
cat > backend/.env << 'EOF'
MONGO_URL="mongodb://localhost:27017"
DB_NAME="carplay_database"
CORS_ORIGINS="http://localhost:3000,http://localhost"
EOF

echo "✅ Fichiers backend créés"

# FRONTEND FILES
echo "🎨 Création des fichiers frontend..."

# package.json
cat > frontend/package.json << 'EOF'
{
  "name": "carplay-os-frontend",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "react-router-dom": "^7.5.1",
    "react-scripts": "5.0.1",
    "axios": "^1.8.4"
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

# .env
cat > frontend/.env << 'EOF'
REACT_APP_BACKEND_URL=http://localhost:8001
WDS_SOCKET_PORT=3000
EOF

# public/index.html
mkdir -p frontend/public
cat > frontend/public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
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
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF

# src/index.js
mkdir -p frontend/src
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

# src/index.css
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
  background: #000;
  color: white;
  overflow: hidden;
  user-select: none;
  touch-action: manipulation;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New', monospace;
}

/* Disable text selection and highlighting */
* {
  -webkit-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
  -webkit-tap-highlight-color: transparent;
}
EOF

# Copier tous les autres fichiers (App.js, App.css, composants)
echo "📋 Copie des fichiers d'interface..."

# Les fichiers seront copiés depuis votre environnement de développement
echo "
⚠️  ÉTAPES MANUELLES REQUISES :
============================

1. Copiez les fichiers suivants depuis votre environnement de développement :
   - frontend/src/App.js
   - frontend/src/App.css
   - frontend/src/components/CarPlayHome.js
   - frontend/src/components/MapsApp.js
   - frontend/src/components/MusicApp.js
   - frontend/src/components/PhoneApp.js
   - frontend/src/components/MessagesApp.js
   - frontend/src/components/SettingsApp.js

2. Transférez ce dossier 'carplay-os-pi5' sur votre Raspberry Pi 5

3. Exécutez le script d'installation :
   chmod +x install-pi5.sh
   ./install-pi5.sh

📁 Structure créée avec succès !
"

ls -la
echo ""
echo "🎉 Fichiers de base créés dans le dossier carplay-os-pi5/"
echo "📋 Suivez les instructions ci-dessus pour compléter l'installation"