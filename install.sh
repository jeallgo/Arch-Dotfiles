#!/bin/bash

set -e

echo "=================================================="
echo "      INICIANDO CONFIGURACIÓN EN ARCH LINUX       "
echo "=================================================="

# 1. Instalar paquetes oficiales de Pacman
if [ -f "packages/pacman.txt" ]; then
    echo -e "\n[+] Instalando paquetes oficiales de Pacman..."
    sudo pacman -S --needed --noconfirm $(grep -v '^#' packages/pacman.txt | grep -v '^[[:space:]]*$' | tr '\n' ' ')
fi

# 2. Instalar un AUR Helper si no está presente (ej. yay)
if ! command -v yay &> /dev/null; then
    echo -e "\n[+] Instalando yay (AUR Helper)..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
    cd - && rm -rf /tmp/yay-bin
fi

# 3. Instalar paquetes del AUR
if [ -f "packages/aur.txt" ]; then
    echo -e "\n[+] Instalando paquetes del AUR..."
    yay -S --needed --noconfirm $(grep -v '^#' packages/aur.txt | grep -v '^[[:space:]]*$' | tr '\n' ' ')
fi

# 4. Instalar aplicaciones Flatpak
if [ -f "packages/flatpak.txt" ]; then
    echo -e "\n[+] Instalando aplicaciones Flatpak y configurando Flathub..."
    sudo pacman -S --needed --noconfirm flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    while IFS= read -r line; do
        [[ "$line" =~ ^# ]] || [[ -z "$line" ]] && continue
        if [[ "$line" == flatpak* ]]; then
            eval "$line" -y
        fi
    done < "packages/flatpak.txt"
fi

# 5. Configurar .bashrc para los aliases
echo -e "\n[+] Configurando aliases en .bashrc..."
BASHRC="$HOME/.bashrc"
ALIAS_LINE='[ -f ~/.config/shell/aliases ] && source ~/.config/shell/aliases'
if ! grep -qxF "$ALIAS_LINE" "$BASHRC" 2>/dev/null; then
    echo "$ALIAS_LINE" >> "$BASHRC"
fi

# 6. Configurar servicio de Nvidia (Power Limit)
if [ -f "services/nvidia-power-limit.service" ]; then
    echo -e "\n[+] Instalando y habilitando nvidia-power-limit.service..."
    sudo cp services/nvidia-power-limit.service /etc/systemd/system/nvidia-power-limit.service
    sudo systemctl daemon-reload
    sudo systemctl enable --now nvidia-power-limit.service
fi

# 7. Habilitar servicios de usuario de Systemd (Startpage)
echo -e "\n[+] Habilitando servicios de usuario..."
systemctl --user enable --now startpage.service || true

# 8. Copiar las configuraciones a ~/.config
echo -e "\n[+] Copiando configuraciones a ~/.config..."
mkdir -p "$HOME/.config"
if [ -d ".config" ]; then
    cp -r .config/* "$HOME/.config/"
    echo "Dotfiles aplicados con éxito"
fi

echo -e "\n=================================================="
echo "    ¡INSTALACIÓN Y CONFIGURACIÓN COMPLETADAS!     "
echo "=================================================="
