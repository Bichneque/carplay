# Installation CarPlay OS sur Raspberry Pi 5

## 🛠️ Prérequis matériels

### Composants nécessaires :
- **Raspberry Pi 5** (4GB ou 8GB recommandé)
- **Écran tactile** 7" ou plus (résolution min. 1024x600)
- **Carte microSD** 32GB classe 10 minimum
- **Alimentation officielle** Pi 5 (5V 5A)
- **Boîtier avec ventilation** (optionnel mais recommandé)

### Écrans compatibles recommandés :
- Raspberry Pi Official 7" Touchscreen
- Waveshare 7" HDMI LCD (H) 1024×600
- Écran automobile 7-10" avec entrée HDMI/USB-C

## 📋 Installation étape par étape

### Étape 1: Préparation de la carte SD

```bash
# Télécharger Raspberry Pi OS Lite (64-bit)
# Utiliser Raspberry Pi Imager pour flasher la carte SD
# Activer SSH et configurer WiFi lors du flash
```

### Étape 2: Configuration initiale du Pi

```bash
# Connexion SSH au Pi
ssh pi@[IP_DU_PI]

# Mise à jour du système
sudo apt update && sudo apt upgrade -y

# Configuration de base
sudo raspi-config
# - Activer SSH, SPI, I2C
# - Configurer l'écran tactile
# - Ajuster le GPU memory split à 128MB
```

### Étape 3: Installation des dépendances

```bash
# Installation Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Installation Python 3.11+ et pip
sudo apt install python3 python3-pip python3-venv -y

# Installation MongoDB
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# Installation Yarn
npm install -g yarn

# Installation Git
sudo apt install git -y
```

### Étape 4: Configuration de l'écran tactile

```bash
# Pour écran officiel 7" Raspberry Pi
echo 'dtoverlay=rpi-display,rotate=180' | sudo tee -a /boot/config.txt

# Pour écran HDMI tactile
echo 'hdmi_group=2' | sudo tee -a /boot/config.txt
echo 'hdmi_mode=87' | sudo tee -a /boot/config.txt
echo 'hdmi_cvt 1024 600 60 6 0 0 0' | sudo tee -a /boot/config.txt

# Désactiver le curseur de souris
echo 'disable_splash=1' | sudo tee -a /boot/config.txt

# Configuration du tactile automatique
sudo apt install xserver-xorg-input-evdev xinput-calibrator -y
```

### Étape 5: Installation de l'interface graphique minimale

```bash
# Installation d'un environnement graphique léger
sudo apt install --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox chromium-browser -y

# Configuration de l'auto-login
sudo systemctl set-default multi-user.target
sudo systemctl enable getty@tty1.service

# Configuration .bashrc pour démarrage auto
echo '
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  startx
fi' >> ~/.bashrc
```

## 📁 Téléchargement et installation du code CarPlay

### Méthode 1: Via Git (Recommandée)

```bash
# Création du répertoire projet
mkdir -p ~/carplay-os
cd ~/carplay-os

# Clone depuis votre repository
git clone [VOTRE_REPO_URL] .
```

### Méthode 2: Téléchargement manuel

Créez les fichiers suivants sur votre Pi :

```bash
# Structure des dossiers
mkdir -p ~/carplay-os/{backend,frontend/src/components}
cd ~/carplay-os
```

## 🔧 Configuration spécifique Pi

### Configuration backend (.env)
```bash
# /home/pi/carplay-os/backend/.env
MONGO_URL="mongodb://localhost:27017"
DB_NAME="carplay_database"
CORS_ORIGINS="http://localhost:3000,http://localhost"
```

### Configuration frontend (.env)
```bash
# /home/pi/carplay-os/frontend/.env
REACT_APP_BACKEND_URL=http://localhost:8001
WDS_SOCKET_PORT=3000
```

## 🚀 Installation des packages et démarrage

```bash
# Installation backend
cd ~/carplay-os/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Installation frontend
cd ~/carplay-os/frontend
yarn install
yarn build

# Test de l'installation
cd ~/carplay-os/backend
source venv/bin/activate
python server.py &

cd ~/carplay-os/frontend
yarn start &
```

## ⚙️ Configuration du démarrage automatique

### Script de démarrage (/home/pi/start-carplay.sh)
```bash
#!/bin/bash
# Démarrage MongoDB
sudo systemctl start mongod

# Démarrage Backend
cd /home/pi/carplay-os/backend
source venv/bin/activate
python server.py &

# Démarrage Frontend
cd /home/pi/carplay-os/frontend
BROWSER=none yarn start &

# Attendre que les services démarrent
sleep 10

# Lancer Chromium en mode kiosk
chromium-browser --kiosk --disable-infobars --no-sandbox --disable-features=TranslateUI --disk-cache-dir=/tmp --disable-dev-shm-usage http://localhost:3000
```

### Configuration Openbox (~/.config/openbox/autostart)
```bash
# Créer le dossier config
mkdir -p ~/.config/openbox

# Configuration autostart
echo '#!/bin/bash
# Désactiver l'économiseur d'écran
xset s noblank
xset s off
xset -dpms

# Masquer le curseur après 1 seconde
unclutter -idle 1 &

# Démarrer CarPlay
/home/pi/start-carplay.sh &
' > ~/.config/openbox/autostart

chmod +x ~/.config/openbox/autostart
chmod +x ~/start-carplay.sh
```

## 🔧 Optimisations performance

### Configuration GPU/Mémoire
```bash
# /boot/config.txt optimisations
echo 'gpu_mem=128' | sudo tee -a /boot/config.txt
echo 'arm_freq=2400' | sudo tee -a /boot/config.txt
echo 'over_voltage=6' | sudo tee -a /boot/config.txt
echo 'disable_overscan=1' | sudo tee -a /boot/config.txt
```

### Services à désactiver
```bash
sudo systemctl disable bluetooth
sudo systemctl disable wifi-powersave
sudo systemctl disable cups
sudo systemctl disable triggerhappy
```

## 📱 Configuration réseau pour DeArCal

### Création d'un hotspot WiFi
```bash
sudo apt install hostapd dnsmasq -y

# Configuration hostapd
echo 'interface=wlan0
driver=nl80211
ssid=CarPlay-Pi5
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=CarPlay123
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP' | sudo tee /etc/hostapd/hostapd.conf
```

## 🏁 Finalisation

### Redémarrage et test
```bash
sudo reboot
```

Après redémarrage, votre Pi 5 devrait :
1. ✅ Démarrer automatiquement en mode CarPlay
2. ✅ Afficher l'interface tactile plein écran
3. ✅ Fonctionner sans clavier/souris
4. ✅ Être prêt pour intégration automobile

## 🚗 Intégration automobile

- **Alimentation** : Convertisseur 12V vers 5V 5A
- **Montage** : Support dashboard ou console centrale
- **Audio** : Connexion jack 3.5mm ou Bluetooth vers autoradio
- **Intégration DeArCal** : Connexion WiFi automatique

## 🛠️ Dépannage courant

### Écran tactile ne fonctionne pas
```bash
# Vérifier les drivers tactiles
ls /dev/input/
sudo apt install xserver-xorg-input-evdev -y
```

### Performance lente
```bash
# Vérifier la température
vcgencmd measure_temp
# Ajouter ventilation si > 70°C
```

### MongoDB ne démarre pas
```bash
sudo systemctl status mongod
sudo systemctl enable mongod
```

## 📞 Support

En cas de problème, vérifiez :
- Logs système : `sudo journalctl -f`
- Logs CarPlay : `tail -f ~/.pm2/logs/`
- Température CPU : `vcgencmd measure_temp`