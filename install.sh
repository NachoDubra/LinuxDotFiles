#!/usr/bin/env bash

set -e

echo "=== Actualizando sistema ==="
sudo apt update
sudo apt upgrade -y

echo "=== Instalando paquetes base ==="
sudo apt install -y \
    git \
    curl \
    wget \
    zsh \
    nano \
    flatpak \
    fastfetch \
    kitty \
    alacritty

echo "=== Ulauncher ==="
wget https://github.com/Ulauncher/Ulauncher/releases/download/5.15.15/ulauncher_5.15.15_all.deb
sudo dpkg -i ulauncher_5.15.15_all.deb

echo "=== ksuperkey ==="
sudo apt-get install -y gcc make libx11-dev libxtst-dev pkg-config 
git clone https://github.com/hanschen/ksuperkey.git
cd ksuperkey
make
sudo make install

echo "=== Docker ==="
sudo apt update
sudo apt install ca-certificates curl
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

echo "=== Flathub ==="
sudo flatpak remote-add --if-not-exists flathub \
https://flathub.org/repo/flathub.flatpakrepo

echo "=== Obsidian ==="

read -rp "¿Instalar Obsidian? [s/N]: " instalar_obsidian

if [[ "$instalar_obsidian" =~ ^[SsYy]$ ]]; then
    echo "Instalando Obsidian..."
    wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.12.7/obsidian_1.12.7_amd64.deb
    sudo dpkg -i obsidian_1.12.7_amd64.deb
else
    echo "Saltando Obsidian."
fi

echo "=== GeoGebra ==="
read -rp "¿Instalar GeoGebra? [s/N]: " instalar_geo

if [[ "$instalar_geo" =~ ^[SsYy]$ ]]; then
    echo "Instalando GeoGebra..."
    flatpak install -y flathub org.geogebra.GeoGebra
else
    echo "Saltando GeoGebra."
fi
flatpak install -y flathub io.github.kovzol.geogebra-discovery

echo "=== pgAdmin4 ==="

read -rp "¿Instalar pgAdmin4? [s/N]: " instalar_pgadmin

if [[ "$instalar_pgadmin" =~ ^[SsYy]$ ]]; then
    echo "Instalando pgAdmin4..."

    curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

    sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmi4.list && apt update'

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

echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc

echo "=== Zsh como shell predeterminado ==="
chsh -s "$(which zsh)"

echo "=== Nerd Font (CaskaydiaCove) ==="

mkdir -p ~/.local/share/fonts

cd /tmp

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip

unzip -o CaskaydiaCove.zip -d ~/.local/share/fonts

fc-cache -fv

echo "=== Graphite GTK Theme ==="

mkdir -p ~/.themes

git clone --depth=1 \
https://github.com/vinceliuice/Graphite-gtk-theme.git \
/tmp/Graphite-gtk-theme

cd /tmp/Graphite-gtk-theme
./install.sh -t blue -c dark -l --round 15px

echo "=== Tela Circle Icons ==="
cd /tmp
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git
cd Tela-circle-icon-theme
./install.sh blue

echo "=== Bibata Modern Classic Cursor ==="

git clone --depth=1 \
https://github.com/ful1e5/Bibata_Cursor.git \
/tmp/Bibata_Cursor

mkdir -p ~/.icons
cp -r /tmp/Bibata_Cursor/Bibata-Modern-Classic ~/.icons/ || true

echo "=== Limpieza ==="
sudo apt autoremove -y

echo ""
echo "======================================="
echo "Instalación finalizada."
echo "Reinicia la sesión."
echo "Ejecuta: p10k configure"
echo "======================================="
