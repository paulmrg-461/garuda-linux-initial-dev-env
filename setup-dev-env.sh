#!/bin/bash

echo "🚀 Iniciando configuración de entorno de desarrollo para Garuda Linux"

# Verificar que se ejecuta como usuario (no como root)
if [ "$EUID" -eq 0 ]; then
  echo "❌ Este script NO debe ejecutarse como root. Ejecútalo con tu usuario normal."
  exit 1
fi

# Actualizar sistema
echo "🔄 Actualizando sistema..."
paru -Syu --noconfirm || {
  echo "📦 Instalando paru (AUR helper)..."
  sudo pacman -S --needed base-devel git --noconfirm
  git clone https://aur.archlinux.org/paru.git /tmp/paru
  (cd /tmp/paru && makepkg -si --noconfirm)
  rm -rf /tmp/paru
}

# Paquetes esenciales
echo "📦 Instalando paquetes esenciales..."
paru -S --noconfirm \
  git curl unzip xz zip \
  libglu1-mesa \
  cmake ninja clang extra-cmake-modules \
  nodejs npm \
  python python-pip \
  docker docker-compose

# Google Chrome
echo "🌐 Instalando Google Chrome..."
paru -S --noconfirm google-chrome

# Android Studio
echo "📱 Instalando Android Studio..."
paru -S --noconfirm android-studio

# Visual Studio Code
echo "💻 Instalando Visual Studio Code..."
paru -S --noconfirm visual-studio-code-bin

# Flutter SDK
FLUTTER_DIR="$HOME/development/flutter"
echo "🛠️ Instalando Flutter SDK en $FLUTTER_DIR..."
mkdir -p "$HOME/development"
if [ -d "$FLUTTER_DIR" ]; then
  rm -rf "$FLUTTER_DIR"
fi
git clone https://github.com/flutter/flutter.git "$FLUTTER_DIR" --branch stable

# Configurar Fish Shell
echo "🐟 Configurando Fish Shell..."

# Añadir Flutter al PATH
fish_add_path -g "$HOME/development/flutter/bin"

# Añadir Android SDK
ANDROID_SDK="$HOME/Android/Sdk"
mkdir -p "$ANDROID_SDK/cmdline-tools/latest"

# Si no tienes cmdline-tools, descárgalos
if [ ! -f "$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager" ]; then
  echo "📦 Descargando Android SDK Command-line Tools..."
  cd /tmp
  wget --user-agent="Mozilla/5.0" "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" -O cmdline-tools.zip
  unzip cmdline-tools.zip -d /tmp/cmdline-tools
  mkdir -p "$ANDROID_SDK/cmdline-tools/latest"
  mv /tmp/cmdline-tools/cmdline-tools/* "$ANDROID_SDK/cmdline-tools/latest/" 2>/dev/null || true
  rm -rf /tmp/cmdline-tools /tmp/cmdline-tools.zip
fi

# Variables de entorno
echo "🔧 Configurando ANDROID_HOME y PATH en Fish..."
echo "set -x ANDROID_HOME $ANDROID_SDK" >> ~/.config/fish/config.fish
echo "set -x PATH \$ANDROID_HOME/cmdline-tools/latest/bin \$PATH" >> ~/.config/fish/config.fish
echo "set -x PATH \$ANDROID_HOME/platform-tools \$PATH" >> ~/.config/fish/config.fish

# Recargar Fish
fish -c "source ~/.config/fish/config.fish"

# Habilitar y iniciar Docker
echo "🐳 Habilitando Docker..."
sudo systemctl enable docker.service --now
sudo usermod -aG docker $USER

# Mensaje final
echo "
✅ ¡Configuración completada!

Por favor:
1. Reinicia la terminal o ejecuta: source ~/.config/fish/config.fish
2. Cierra y vuelve a abrir la sesión si es necesario.
3. Ejecuta: flutter doctor
4. Acepta las licencias: flutter doctor --android-licenses

¡Listo para desarrollar con Flutter, Android, Docker, Node.js y más!
"

# Sugerir ejecutar flutter doctor
echo "💡 Ejecuta: flutter doctor"
