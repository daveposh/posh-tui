#!/bin/bash
# posh-tui installer
# Usage: curl -fsSL https://raw.githubusercontent.com/daveposh/posh-tui/main/install.sh | bash

set -e

INSTALL_DIR="$HOME/.posh-tui"
BIN_DIR="$HOME/.local/bin"

echo "Installing posh-tui..."

# Download files directly
mkdir -p "$INSTALL_DIR"
curl -fsSL https://raw.githubusercontent.com/daveposh/posh-tui/main/posh_tui.py -o "$INSTALL_DIR/posh_tui.py"
curl -fsSL https://raw.githubusercontent.com/daveposh/posh-tui/main/README.md -o "$INSTALL_DIR/README.md"

# Install Python dependencies
echo "Installing dependencies..."

if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y -qq python3-pip
    pip3 install --quiet textual
elif command -v dnf &>/dev/null; then
    sudo dnf install -y python3-pip
    python3 -m pip install --quiet textual
elif command -v pacman &>/dev/null; then
    # Arch: pip exists but is externally-managed, use --break-system-packages
    sudo pacman -Sy --noconfirm python-pip
    pip install --break-system-packages --quiet textual
else
    # Try pip directly, fall back to get-pip.py
    if command -v pip3 &>/dev/null; then
        pip3 install --quiet textual
    elif command -v python3 &>/dev/null; then
        python3 -m pip install --quiet textual
    else
        echo "Installing pip..."
        curl -fsSL https://bootstrap.pypa.io/get-pip.py | python3
        python3 -m pip install --quiet textual
    fi
fi

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
