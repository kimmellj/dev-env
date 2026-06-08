#!/bin/bash

# Enforce strict error checking and help scripts fail fast when things go wrong
set -eux -o pipefail

# Verify the script is being run as sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as sudo" >&2
    exit 1
fi

DNF_OPTS="--nodocs --setopt=install_weak_deps=False"

# Install core dependencies
dnf install -y $DNF_OPTS dnf-plugins-core
dnf install -y $DNF_OPTS \
    ca-certificates curl gnupg2 jq \
    gcc gcc-c++ make patch which \
    openssl-devel zlib-devel bzip2-devel readline-devel sqlite-devel \
    ncurses-devel xz xz-devel tk-devel libffi-devel \
    pkgconf-pkg-config libxml2-devel libcurl-devel libpng-devel \
    oniguruma-devel libzip-devel libpq-devel \
    zsh git wget unzip ripgrep fd-find \
    lua luarocks

# Install Docker (DNF5 uses `addrepo --from-repofile`; DNF4 used `--add-repo`)
if dnf config-manager addrepo --help >/dev/null 2>&1; then
    dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
else
    dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
fi
dnf install -y $DNF_OPTS docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Configure Docker API version
mkdir -p /etc/docker
[ ! -f /etc/docker/daemon.json ] && echo '{}' > /etc/docker/daemon.json
tmp=$(mktemp)
jq '."min-api-version" = "1.24"' /etc/docker/daemon.json > "$tmp" && mv "$tmp" /etc/docker/daemon.json

# Fix Docker permissions permanently
mkdir -p /etc/systemd/system/docker.socket.d
cat <<EOF > /etc/systemd/system/docker.socket.d/override.conf
[Socket]
SocketMode=0666
EOF

systemctl daemon-reload
systemctl enable --now docker.socket
systemctl restart docker.socket

# Configure Zsh as the default shell
ZSH_BIN=$(command -v zsh)
if ! grep -q "^${ZSH_BIN}$" /etc/shells; then
    echo "${ZSH_BIN}" >> /etc/shells
fi

echo "Setting zsh as default shell for $USER"
chsh -s "${ZSH_BIN}" $USER
usermod --shell "${ZSH_BIN}" $USER

if [ -x "$(command -v zsh)" ]; then
    echo "Setting zsh as default shell for root"
    chsh -s "${ZSH_BIN}" root
    usermod --shell "${ZSH_BIN}" root
fi

# Install NeoVim
echo "Installing Neovim..."
cd /tmp
curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-arm64.appimage
chmod u+x nvim-linux-arm64.appimage
mv nvim-linux-arm64.appimage /usr/local/bin/nvim
echo "Neovim installed to /usr/local/bin/nvim"

# Install lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz"
tar xf lazygit.tar.gz lazygit
install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz
echo "lazygit installed"
