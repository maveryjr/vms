#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting system setup..."

# Update package list and install necessary packages
echo "📦 Updating package list and installing packages..."
sudo apt-get update
sudo apt-get install -y zsh curl git nano python3 python3-pip

# Install Oh My Zsh
echo "🛠 Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
sudo chsh -s $(which zsh) $USER

# Install Oh My Zsh plugins
echo "🔌 Installing Oh My Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true

# Configure .zshrc
echo "⚙️ Configuring .zshrc..."
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

echo "✅ Setup complete! Please restart your terminal or run 'zsh' to start using your new shell."
