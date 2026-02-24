#!/bin/bash

# Enforce strict error checking and help scripts fail fast when things go wrong
set -eux -o pipefail

# Verify the script is being run as sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as sudo" >&2
    exit 1
fi

# Install Docker, Python, and various dependencies
apt-get update
apt-get install -y ca-certificates curl gnupg jq build-essential \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev \
    pkg-config libxml2-dev libsqlite3-dev libcurl4-openssl-dev libpng-dev libonig-dev \
    libzip-dev libpq-dev zsh git wget build-essential gcc make unzip ripgrep \
    fd-find nodejs npm lua5.1 luarocks

install -m 0755 -d /etc/apt/keyrings

# Install Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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
if ! grep -q "^/usr/bin/zsh" /etc/shells; then
    echo "/usr/bin/zsh" >> /etc/shells
fi

echo "Setting zsh as default shell for $USER"
chsh -s $(which zsh) $USER
usermod --shell $(which zsh) $USER

if [ -x "$(command -v zsh)" ]; then
    echo "Setting zsh as default shell for root"
    chsh -s $(which zsh) root
    usermod --shell $(which zsh) root
fi

# Install NeoVim
echo "Installing Neovim..."
cd /tmp
curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-arm64.appimage
chmod u+x nvim-linux-arm64.appimage
sudo mv nvim-linux-arm64.appimage /usr/local/bin/nvim
echo "Neovim installed to /usr/local/bin/nvim"

# Configure fd-find symlink
if [ -f /usr/bin/fdfind ] && [ ! -f /usr/local/bin/fd ]; then
    sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
    echo "Created fd symlink"
fi

# Install lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz
echo "lazygit installed"
