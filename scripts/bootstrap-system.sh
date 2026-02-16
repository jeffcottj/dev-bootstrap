#!/usr/bin/env bash
set -euo pipefail

# bootstrap-system.sh — system-level setup requiring sudo.
# Must be run as a regular user (not root) on Ubuntu 24.04.

if [[ "$(id -u)" -eq 0 ]]; then
  echo "ERROR: Do not run this script as root. Run as your normal user (sudo will be used where needed)."
  exit 1
fi

if ! command -v lsb_release &>/dev/null || [[ "$(lsb_release -rs)" != "24.04" ]]; then
  echo "ERROR: This script requires Ubuntu 24.04 (noble). Detected: $(lsb_release -rs 2>/dev/null || echo 'unknown')"
  exit 1
fi

if ! sudo -v; then
  echo "ERROR: sudo access is required."
  exit 1
fi

ARCH="$(dpkg --print-architecture)"

echo "==> Updating base system"
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

echo "==> Installing baseline packages"
sudo apt install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  wget \
  gnupg \
  software-properties-common \
  build-essential \
  unzip \
  zip \
  git \
  jq \
  ripgrep \
  fd-find \
  fzf \
  tmux \
  tree \
  htop \
  bat \
  pipx \
  python3-pip \
  python3-venv \
  flatpak \
  unattended-upgrades \
  ufw \
  tlp \
  zsh \
  zsh-autosuggestions \
  zsh-syntax-highlighting

echo "==> Enabling firewall (UFW)"
sudo ufw --force enable

echo "==> Enabling unattended upgrades"
sudo dpkg-reconfigure -f noninteractive unattended-upgrades || true

echo "==> Enabling TLP (laptop power management)"
sudo systemctl enable --now tlp || true

echo "==> Ensure keyrings directory exists"
sudo install -m 0755 -d /etc/apt/keyrings

echo "==> Adding Docker official repo"
if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
fi

if [[ ! -f /etc/apt/sources.list.d/docker.list ]]; then
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

echo "==> Adding Microsoft keyring (for Azure CLI / VS Code)"
if [[ ! -f /etc/apt/keyrings/microsoft.gpg ]]; then
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
  sudo chmod a+r /etc/apt/keyrings/microsoft.gpg
fi

echo "==> Adding Azure CLI repo"
if [[ ! -f /etc/apt/sources.list.d/azure-cli.sources ]]; then
  sudo tee /etc/apt/sources.list.d/azure-cli.sources > /dev/null <<'EOF'
Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: noble
Components: main
Architectures: amd64
Signed-by: /etc/apt/keyrings/microsoft.gpg
EOF
fi

echo "==> Adding VS Code repo"
if [[ ! -f /etc/apt/sources.list.d/vscode.sources ]]; then
  sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null <<EOF
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: ${ARCH}
Signed-By: /etc/apt/keyrings/microsoft.gpg
EOF
fi

if [[ "$ARCH" == "amd64" ]]; then
  echo "==> Adding Google Linux signing key"
  if [[ ! -f /etc/apt/keyrings/google-linux.gpg ]]; then
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /etc/apt/keyrings/google-linux.gpg
    sudo chmod a+r /etc/apt/keyrings/google-linux.gpg
  fi

  echo "==> Adding Google Chrome repo"
  if [[ ! -f /etc/apt/sources.list.d/google-chrome.list ]]; then
    sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null <<'EOF'
### THIS FILE IS AUTOMATICALLY CONFIGURED ###
# You may comment out this entry, but any other modifications may be lost.
deb [arch=amd64 signed-by=/etc/apt/keyrings/google-linux.gpg] https://dl.google.com/linux/chrome/deb/ stable main
EOF
  fi
else
  echo "==> Skipping Google Chrome repo: architecture '$ARCH' is not supported by google-chrome-stable"
fi

echo "==> Updating package lists for newly added repos"
sudo apt update

echo "==> Installing Docker (official packages) + Azure CLI + VS Code + GH CLI"
packages=(
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin \
  azure-cli \
  code \
  gh
)

if [[ "$ARCH" == "amd64" ]]; then
  packages+=(google-chrome-stable)
fi

sudo apt install -y "${packages[@]}"

echo "==> Enabling Docker services"
sudo systemctl enable --now containerd
sudo systemctl enable --now docker
sudo systemctl enable --now docker.socket

echo "==> Adding current user to docker group"
sudo usermod -aG docker "$USER"

echo "==> System-level setup complete."
