#!/bin/bash
#
#
# WIP
#
#
#
#

# Enforce strict error checking and help scripts fail fast when things go wrong
set -eux -o pipefail

# Install Dot Files
# If path doesn't exist clone the repository
# if [ ! -d ~/dotfiles ]; then
#     git clone https://github.com/kimmellj/dotfiles ~/dotfiles
# fi

# cd ~/dotfiles
# git pull origin master

# chmod +x ./bootstrap.sh
# ./bootstrap.sh

cd ~/

# Install ASDF and Plugins
# If path doesn't exist clone the repository
if [ ! -d ~/.asdf ]; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
fi

# Add ASDF to bashrc and zshrc
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.zshrc
echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.zshrc

# Source ASDF in the current shell session
. "$HOME/.asdf/asdf.sh"

# Verify ASDF is working
if ! asdf --version >/dev/null 2>&1; then
    echo "ASDF initialization failed, trying alternative approach"
    export ASDF_DIR="$HOME/.asdf"
    export PATH="$ASDF_DIR/bin:$ASDF_DIR/shims:$PATH"
fi

# Install Node.js Plugin
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git

# Import Node.js release team keyring with proper error handling
if [ -f ~/.asdf/plugins/nodejs/bin/import-release-team-keyring ]; then
    bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring || echo "Keyring import failed, but continuing..."
else
    echo "Keyring import script not found, skipping..."
fi

# Install latest Node.js with retry logic
if ! asdf install nodejs latest; then
    echo "Node.js installation failed, trying specific version..."
    asdf install nodejs 20.0.0 || echo "Node.js installation failed completely"
fi

# Set global Node.js version
if [ -n "$(asdf list nodejs | tail -1)" ]; then
    asdf global nodejs $(asdf list nodejs | tail -1)
else
    echo "No Node.js versions available to set as global"
fi

# Install Java Plugin
asdf plugin-add java https://github.com/halcyon/asdf-java.git
asdf install java latest:adoptopenjdk
asdf global java $(asdf list java | tail -1)

# Install Python Plugin
asdf plugin-add python https://github.com/asdf-community/asdf-python.git
asdf install python latest
asdf global python $(asdf list python | tail -1)

# Install pip and Mistral Vibe
python -m ensurepip --upgrade
python -m pip install --upgrade pip
pip install mistral-vibe

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Backup existing Neovim config
echo "Backing up existing Neovim config (if any)..."
BACKUP_DIR="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
if [ -d "$HOME/.config/nvim" ]; then
    mv "$HOME/.config/nvim" "$BACKUP_DIR"
    echo "Backed up to $BACKUP_DIR"
fi

# Backup Neovim directories
[ -d "$HOME/.local/share/nvim" ] && mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.bak"
[ -d "$HOME/.local/state/nvim" ] && mv "$HOME/.local/state/nvim" "$HOME/.local/state/nvim.bak"
[ -d "$HOME/.cache/nvim" ] && mv "$HOME/.cache/nvim" "$HOME/.cache/nvim.bak"

# Install LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Configure Homebrew in zshrc
echo >> $HOME/.zshrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"' >> $HOME/.zshrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# Install GCC and Git Xet
brew install gcc
brew install git-xet
git xet install
