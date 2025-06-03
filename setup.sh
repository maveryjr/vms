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
    # First remove curl-minimal if it exists
    sudo yum remove -y curl-minimal || true
    # Install packages with --allowerasing flag
    sudo yum install -y --allowerasing zsh git nano python3 python3-pip util-linux-user curl
}
dnf_install() {
    echo "📦 Using dnf package manager..."
    sudo dnf update -y
    # First remove both curl and curl-minimal if they exist
    sudo dnf remove -y curl curl-minimal || true
    # Install packages
    sudo dnf install -y zsh git nano python3 python3-pip util-linux-user
    # Install curl separately with allowerasing
    sudo dnf install -y --allowerasing curl
}

echo "🚀 Starting system setup..."

# Install packages based on OS
case $OS_TYPE in
    "ubuntu"|"debian"|"kali")
        apt_install
        ;;
    "rhel"|"centos"|"amzn")  # Added amzn for Amazon Linux
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
RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc || true

# Set Zsh as default shell
echo "🐚 Setting Zsh as default shell..."
if [ "$OS_TYPE" = "amzn" ]; then
    # Amazon Linux uses usermod
    sudo usermod -s $(which zsh) $USER || echo "⚠️ Could not change shell automatically"
else
    # Other distributions use chsh
    if command -v chsh >/dev/null 2>&1; then
        sudo chsh -s $(which zsh) $USER || echo "⚠️ Could not change shell automatically"
    else
        echo "⚠️ chsh not found - please change your default shell manually"
    fi
fi

# Install Oh My Zsh plugins
echo "🔌 Installing Oh My Zsh plugins..."
if [ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null || true
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null || true
    
    # Update .zshrc
    echo "⚙️ Configuring .zshrc..."
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
else
    echo "⚠️ Oh My Zsh plugins directory not found"
fi

# Install zoxide
echo "🚀 Installing zoxide..."
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Configure zoxide for zsh
echo "⚙️ Configuring zoxide..."
if [ -f ~/.zshrc ]; then
    # Add zoxide initialization to .zshrc if not already present
    if ! grep -q "zoxide init zsh" ~/.zshrc; then
        echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
    fi
    
    # Rebuild completions cache
    rm -f ~/.zcompdump*
    zsh -c "autoload -U compinit && compinit"
else
    echo "⚠️ ~/.zshrc not found"
fi

echo "✅ Setup complete! Please restart your terminal or run 'zsh' to start using your new shell."
