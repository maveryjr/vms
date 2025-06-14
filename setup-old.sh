#!/bin/bash

# Exit on any error
set -e

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_TYPE=$ID
else
    echo "❌ Cannot detect OS type"
    exit 1
fi

# Package manager functions
apt_install() {
    echo "📦 Using apt package manager..."
    sudo apt-get update
    sudo apt-get install -y zsh curl git nano python3 python3-pip
}

yum_install() {
    echo "📦 Using yum package manager..."
    sudo yum update -y
    sudo yum install -y zsh curl git nano python3 python3-pip
}

dnf_install() {
    echo "📦 Using dnf package manager..."
    sudo dnf update -y
    sudo dnf install -y zsh curl git nano python3 python3-pip
}

echo "🚀 Starting system setup..."

# Install packages based on OS
case $OS_TYPE in
    "ubuntu"|"debian")
        apt_install
        ;;
    "rhel"|"centos")
        if command -v dnf &> /dev/null; then
            dnf_install
        else
            yum_install
        fi
        ;;
    *)
        echo "❌ Unsupported OS: $OS_TYPE"
        exit 1
        ;;
esac

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
