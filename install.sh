#!/bin/bash
# posh-tui installer
# Usage: curl -fsSL https://raw.githubusercontent.com/yourusername/posh-tui/main/install.sh | bash

set -e

REPO="https://github.com/yourusername/posh-tui"
INSTALL_DIR="$HOME/.posh-tui"
BIN_DIR="$HOME/.local/bin"

echo "Installing posh-tui..."

# Clone or update repo
if [ -d "$INSTALL_DIR" ]; then
    echo "Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull
else
    echo "Cloning repository..."
    git clone "$REPO" "$INSTALL_DIR"
fi

# Install Python dependencies
echo "Installing dependencies..."
pip install --quiet textual

# Create symlink
echo "Creating symlink..."
mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/posh_tui.py" "$BIN_DIR/posh-tui"

# Make executable
chmod +x "$INSTALL_DIR/posh_tui.py"

echo ""
echo "posh-tui installed successfully!"
echo "Run 'posh-tui' to start."
echo ""
echo "To update: run this installer again"
echo "To uninstall: rm -rf $INSTALL_DIR && rm $BIN_DIR/posh-tui"
