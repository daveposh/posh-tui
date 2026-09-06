#!/bin/bash
# posh-tui installer
# Usage: curl -fsSL https://raw.githubusercontent.com/daveposh/posh-tui/82b725de83e2970b69dea680d81570fed6cc3e08/install.sh | bash

set -e

INSTALL_DIR="$HOME/.posh-tui"
BIN_DIR="$HOME/.local/bin"

echo "Installing posh-tui..."

# Download files directly
mkdir -p "$INSTALL_DIR"
curl -fsSL https://raw.githubusercontent.com/daveposh/posh-tui/master/posh_tui.py -o "$INSTALL_DIR/posh_tui.py"
curl -fsSL https://raw.githubusercontent.com/daveposh/posh-tui/master/README.md -o "$INSTALL_DIR/README.md"

# Install Python dependencies
echo "Installing dependencies..."
if command -v pip3 &>/dev/null; then
    pip3 install --quiet textual
elif command -v python3 &>/dev/null && python3 -m pip --version &>/dev/null; then
    python3 -m pip install --quiet textual
else
    echo "pip not found. Installing pip..."
    curl -fsSL https://bootstrap.pypa.io/get-pip.py | python3 --break-system-packages
    python3 -m pip install --quiet textual --break-system-packages
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
