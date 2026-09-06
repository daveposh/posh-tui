#!/bin/bash
# posh-tui installer
# Usage: curl -fsSL https://raw.githubusercontent.com/daveposh/posh-tui/main/install.sh | bash

set -e

INSTALL_DIR="$HOME/.posh-tui"
VENV_DIR="$INSTALL_DIR/.venv"
BIN_DIR="$HOME/.local/bin"

echo "Installing posh-tui..."

# Download files
mkdir -p "$INSTALL_DIR"
curl -fsSL https://raw.githubusercontent.com/daveposh/posh-tui/main/posh_tui.py -o "$INSTALL_DIR/posh_tui.py"
curl -fsSL https://raw.githubusercontent.com/daveposh/posh-tui/main/README.md -o "$INSTALL_DIR/README.md"

# Create virtual environment
echo "Creating virtual environment..."
python3 -m venv "$VENV_DIR"

# Install dependencies in venv
echo "Installing dependencies..."
"$VENV_DIR/bin/pip" install --quiet --upgrade pip
"$VENV_DIR/bin/pip" install --quiet textual

# Create launcher script
echo "Creating launcher..."
mkdir -p "$BIN_DIR"
cat > "$BIN_DIR/posh-tui" << LAUNCHER
#!/bin/bash
exec "$VENV_DIR/bin/python" "$INSTALL_DIR/posh_tui.py" "\$@"
LAUNCHER
chmod +x "$BIN_DIR/posh-tui"

echo ""
echo "posh-tui installed successfully!"
echo "Run 'posh-tui' to start."
echo ""
echo "To update: run 'posh-tui update' or run this installer again"
echo "To uninstall: rm -rf $INSTALL_DIR && rm $BIN_DIR/posh-tui"
