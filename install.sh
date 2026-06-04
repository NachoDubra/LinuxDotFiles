#!/usr/bin/env bash

# Configuración automatica de Desktop @NachoDubra.

set -Eeuo pipefail

trap 'echo "Error en línea $LINENO"' ERR
exec > >(tee -i install.log)
exec 2>&1

echo "=== Actualizando sistema ==="
sudo apt update
sudo apt upgrade -y

echo "=== Instalando paquetes base ==="
sudo apt install -y \
    git \
    curl \
    wget \
    zsh \
    unzip \
    nano \
    flatpak \
    fastfetch \
    kitty \
    gnupg \
    lsb-release \
    alacritty

echo "=== Ulauncher ==="
if [ ! -f ulauncher_5.15.15_all.deb ]; then
    wget https://github.com/Ulauncher/Ulauncher/releases/download/5.15.15/ulauncher_5.15.15_all.deb
fi
sudo apt install -y ./ulauncher_5.15.15_all.deb

echo "=== ksuperkey ==="
if [ ! -d /tmp/ksuperkey ]; then
    git clone https://github.com/hanschen/ksuperkey.git /tmp/ksuperkey
fi
(sudo apt-get install -y gcc make libx11-dev libxtst-dev pkg-config && cd /tmp && cd ksuperkey && make && sudo make install)

echo "=== Docker ==="
rm -f /etc/apt/sources.list.d/docker.*
rm -f /etc/apt/sources.list.d/docker.sources
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker "$USER"
echo "Debes cerrar sesión o reiniciar para usar Docker sin sudo."
sleep 3

echo "=== Flathub ==="
sudo flatpak remote-add --if-not-exists flathub \
https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak update -y

echo "=== Obsidian ==="

read -rp "¿Instalar Obsidian? [s/N]: " instalar_obsidian

if [[ "$instalar_obsidian" =~ ^[SsYy]$ ]]; then
    echo "Instalando Obsidian..."
if [ ! -f obsidian_1.12.7_amd64.deb ]; then
    wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.12.7/obsidian_1.12.7_amd64.deb
fi
    sudo apt install -y ./obsidian_1.12.7_amd64.deb
else
    echo "Saltando Obsidian."
fi

echo "=== GeoGebra ==="
read -rp "¿Instalar GeoGebra? [s/N]: " instalar_geo

if [[ "$instalar_geo" =~ ^[SsYy]$ ]]; then
    echo "Instalando GeoGebra..."
    flatpak install -y flathub io.github.kovzol.geogebra-discovery || echo "GeoGebra falló"
else
    echo "Saltando GeoGebra."
fi

echo "=== pgAdmin4 ==="

read -rp "¿Instalar pgAdmin4? [s/N]: " instalar_pgadmin

if [[ "$instalar_pgadmin" =~ ^[SsYy]$ ]]; then
    echo "Instalando pgAdmin4..."

    curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

    echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" | \
sudo tee /etc/apt/sources.list.d/pgadmin4.list >/dev/null


    sudo apt update
    sudo apt install -y pgadmin4-desktop
else
    echo "Saltando pgAdmin4."
fi


echo "=== Powerlevel10k ==="

if [ ! -d "$HOME/powerlevel10k" ]; then
    git clone --depth=1 \
    https://github.com/romkatv/powerlevel10k.git \
    "$HOME/powerlevel10k"
fi

echo "=== Zsh como shell predeterminado ==="
if sudo chsh -s "$(which zsh)" "$USER"; then
    echo "Shell cambiada a zsh"
else
    echo "No se pudo cambiar shell automáticamente"
fi

echo "=== Nerd Font (CaskaydiaCove) ==="

mkdir -p ~/.local/share/fonts

(cd /tmp && wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip && unzip -o CascadiaCode.zip -d ~/.local/share/fonts && fc-cache -fv) || echo "Error instalando fuente"

echo "=== Graphite GTK Theme ==="

if [ ! -d /tmp/Graphite-gtk-theme ]; then
    git clone --depth=1 https://github.com/vinceliuice/Graphite-gtk-theme.git /tmp/Graphite-gtk-theme
fi

mkdir -p ~/.themes

(cd /tmp/Graphite-gtk-theme && ./install.sh -t blue -c dark -s compact -l --round 15px)

echo "=== Tela Circle Icons ==="

if [ ! -d /tmp/Tela-circle-icon-theme ]; then
    git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git /tmp/Tela-circle-icon-theme 
fi

(cd /tmp/Tela-circle-icon-theme && ./install.sh blue)

echo "=== Bibata Modern Classic Cursor ==="

if [ ! -f /tmp/Bibata-Modern-Classic.tar.xz ]; then
   (cd /tmp && wget https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Classic.tar.xz)
fi
(cd /tmp && tar -xvf Bibata-Modern-Classic.tar.xz && mkdir -p ~/.icons && cp -r /tmp/Bibata-Modern-Classic  ~/.icons/)

echo "=== Aplicando config firefox ==="

mkdir -p ~/.mozilla/firefox

FIREFOX_PROFILE=$(find ~/.mozilla/firefox -maxdepth 1 -type d -name "*.default-release" | head -n1)

shopt -s nullglob
if [ -n "${FIREFOX_PROFILE:-}" ]; then
    mkdir -p "$FIREFOX_PROFILE/chrome"
    cp "${files[@]}" "$FIREFOX_PROFILE/chrome/"
fi

echo "=== Moviendo iconos y wallpaper ==="
mkdir -p ~/Imagenes
cp wallpaper.jpg ~/Imagenes && cp userIcon.svg ~/Imagenes
cp refresh.png switch.png ~/Imagenes

echo "=== Copiando Configs ==="
mkdir -p ~/.config
cp -rn .config/. ~/.config/
cp .zshrc .nanorc .p10k.zsh ~/

echo "=== Limpieza ==="
sudo apt autoremove -y

echo ""
echo "======================================="
echo "Instalación finalizada."
read -rp "¿Quieres reiniciar para aplicar todos los cambios? [s/N]: " reinicio

if [[ "$reinicio" =~ ^[SsYy]$ ]]; then
    echo "Reiniciando en 3 segundos..."
    sleep 3
    systemctl reboot
else
    echo "Espero lo disfrutes!!.."
fi
echo "======================================="
